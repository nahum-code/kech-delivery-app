# Dispatch Design (MVP)

This document defines the **dispatch logic** for the Kech Delivery App MVP. Even though dispatch is implemented later, the rules and flow must be defined early because they affect:
- order state transitions
- driver eligibility and availability
- concurrency/locking guarantees (first-accept-wins)
- manual override rules (Admin/Sales)
- notification events (driver request offers and order updates)

This design is aligned with:
- order lifecycle in [`README.md`](../README.md)
- backend modules in [`docs/backend_services.md`](backend_services.md)
- architecture decisions in [`docs/architecture.md`](architecture.md)

## 1. Goals (MVP)
- Assign an available driver to an order quickly and safely.
- Support two assignment paths:
  - **Manual assignment** by Admin/Sales
  - **Driver self-accept** from a pool of eligible drivers (broadcast, first accept wins)
- Prevent double assignment and race conditions.

## 2. Key Decisions (MVP)
- **Dispatch radius model**: single fixed radius in kilometers (configurable).
- **Offer model**: broadcast to all eligible drivers; **first accept wins** (server-side lock).

## 3. Definitions

### 3.1 Driver availability
A driver is considered **available** if all are true:
- **Approved**: `driver_profiles.approval_status = approved`
- **Online**: `driver_profiles.is_online = true`
- **Not suspended**: driver account not suspended
- **Not busy**: driver has **no active delivery**
  - Active delivery means any order in: `assigned`, `accepted`, `picked_up`, and `delivered`; drivers become available again only after `completed`.
- **Fresh location**: driver has a recent location update (e.g., `last_seen_at` within X minutes)

### 3.2 Dispatch radius
- A driver is eligible only if their current location is within:
  - `dispatch_radius_km` of the order **pickup** location (restaurant)
- The distance check is based on coordinates and should use a consistent method:
  - MVP recommendation: Haversine or PostGIS distance if enabled (see `docs/database_schema_postgresql.md`)

### 3.3 Eligible driver
A driver is **eligible** for a given order if:
- driver is **available** (Section 3.1)
- driver is **within radius** (Section 3.2)
- driver is allowed by any future constraints (vehicle type, zone restrictions). (Out of scope for MVP; design remains extensible.)

## 4. Configuration (Operational Config)

The following values should be configurable by Admin in the dashboard (stored via `operational_configs`):
- **`dispatch_radius_km`**: numeric (e.g., `5`)
- **`driver_location_freshness_minutes`**: int (e.g., `5`)
- **`offer_window_seconds`**: int (e.g., `30`) — how long an offer remains open before re-broadcast/escalation
- **`max_broadcast_rounds`**: int (e.g., `3`) — optional cap before escalation to manual queue

## 5. Order States Used by Dispatch (MVP)

Dispatch operates primarily over these order states (see `README.md` lifecycle):
- `payment_confirmed` → `searching_driver` → `assigned` → `accepted` → `picked_up` → `delivered` → `completed`

Dispatch invariants:
- An order can be assigned to **at most one** driver at a time.
- A driver can have **at most one** active delivery at a time.

## 6. Dispatch Flow (End-to-End)

### 6.1 Entry point
When an order becomes eligible for dispatch:
- **Customer channel**: after Chapa confirmation: `payment_confirmed`
- **Sales/Admin channel**: after creation/confirmation (based on policy), then `searching_driver`

System transitions order to:
- `searching_driver`

### 6.2 Branch A — Manual assignment (Admin/Sales)
Manual assignment is permitted when:
- order is `searching_driver` or `assigned` (for reassignment), and
- order is not yet `picked_up`

Manual assignment action:
- must run as an **atomic check-and-set transaction** (same atomicity guarantee as Section 7 self-accept):
  - verify order is still assignable (`searching_driver` or `assigned` for reassignment), and not `picked_up`
  - verify driver is still eligible/not busy at commit time
  - perform assignment update (`assigned_driver_user_id`, `assigned_at`, `status = assigned`) and append `delivery_events.driver_assigned` in the same transaction
  - use row lock (`SELECT ... FOR UPDATE`) or optimistic compare-and-set (e.g., guarded `status`/`updated_at`/`version` condition)
- notify driver + customer (push/in-app)

### 6.3 Branch B — Driver self-accept (broadcast)

High-level steps:
1. Compute eligible drivers for the order.
2. Broadcast an offer notification to all eligible drivers.
3. The first driver who accepts successfully wins the assignment.

Offer broadcast:
- Notify drivers via FCM (MVP) with payload containing:
  - `order_id`, pickup summary, approximate distance (optional), and an accept action route
- Drivers fetch order details from API and tap Accept.

Accept request (driver → API):
- Driver sends `POST /orders/{id}/accept`
- Backend must atomically assign the order (Section 7).

Success outcome:
- order transitions **atomically** from `searching_driver` directly to `accepted` (single-step state change to avoid race windows)
- append `delivery_events`: `driver_assigned`, `driver_accepted` in the same transaction
- notify customer/sales/admin

Failure outcome:
- If another driver already accepted, return:
  - HTTP 409 (Conflict): “Order already taken”

## 7. Concurrency & Locking (First-Accept-Wins)

This is the most important safety requirement: prevent multiple drivers accepting the same order.

### 7.1 Atomic accept rule
The accept operation must be a single transaction that:
- verifies the order is still in a dispatchable state (`searching_driver`)
- verifies the driver is still eligible (approved/online/not busy)
- assigns the driver and updates the status

### 7.2 Implementation pattern (recommended)
Use a database transaction with one of:
- row-level lock on `orders` (`SELECT ... FOR UPDATE`), or
- single guarded update:
  - `UPDATE orders SET assigned_driver_user_id = ..., status = 'accepted' WHERE id = ... AND status = 'searching_driver' AND assigned_driver_user_id IS NULL`

If the affected row count is 0, the accept must fail (already taken or not dispatchable).

### 7.3 Driver “one active order” guard
To prevent assigning two active orders to one driver:
- Check for existing active order for the driver inside the same transaction, or
- Enforce via a partial unique index later (Phase 2): unique `(assigned_driver_user_id)` where status in active states.

## 8. Timeouts, Re-broadcast, Escalation

### 8.1 Offer window
If no driver accepts within `offer_window_seconds`:
- Recompute eligible drivers (drivers may come online/offline)
- Re-broadcast up to `max_broadcast_rounds`

### 8.2 Escalation
If still unassigned after max rounds:
- Keep order in `searching_driver`
- Surface in Admin/Sales dashboard as “Needs manual assignment”
- Optionally notify ops/admin group

## 9. Manual Reassignment Rules (MVP)

Reassignment is allowed when:
- order is `assigned` or `accepted`, and
- not yet `picked_up`

Rules:
- Always append `delivery_events` for assignment changes.
- Notify both old driver (cancellation of assignment) and new driver (new assignment).

## 10. Edge Cases (MVP)

- **Order cancelled while searching/assigned**:
  - Immediately stop offers and notify the assigned driver (if any).
- **Driver goes offline after accept**:
  - Order remains assigned; Admin may reassign if driver doesn’t proceed within an operational threshold.
- **Customer unreachable**:
  - Driver records event `customer_unreachable`; Admin resolves per policy.

## 11. Notifications (MVP)

Minimum events to notify:
- Driver: `new_delivery_request`, `assignment_confirmed`, `assignment_cancelled`
- Customer/Sales/Admin: `driver_assigned`, key status transitions (`picked_up`, `delivered`)

Transport:
- MVP: FCM push + polling.
- Phase 2+: WebSockets/Channels for realtime updates.

## 12. Metrics (MVP)

Track for operations and iteration:
- time-to-first-offer
- time-to-assign (from `searching_driver` → `assigned/accepted`)
- acceptance rate per driver / overall
- reassignment rate
- cancellation rate (admin cancels)
