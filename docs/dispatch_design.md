# Dispatch design (MVP)

This document specifies **dispatch and assignment logic** for Phase 1 (MVP): driver availability, a **fixed dispatch radius**, eligibility checks, **manual assignment** versus **driver self-accept** with **first-accept-wins** server-side locking, timeouts, auditing, notifications, and edge cases.

It aligns with:

- MVP order lifecycle and policies in [`README.md`](../README.md) (Section 6 — workflows, Section 8 — operational policies, Section 12 — dispatch pointer).
- Backend boundaries in [`backend_services.md`](backend_services.md) (`dispatch` app: publish, self-accept, manual assign; `orders` owns state machine; `payments` confirms payment).
- Architecture in [`architecture.md`](architecture.md) (MVP: **FCM push**; **realtime / WebSockets deferred** to Stage 2).

---

## 1) Definitions (terminology)

| Term | Meaning (MVP) |
|------|----------------|
| **Driver availability** | Driver is **approved**, **online** (`is_online = true`), **not suspended**, has a **recent location**, and has **no active delivery** on another order. |
| **Dispatch radius** | A single operational distance **`dispatch_radius_km`** (kilometers), read from admin-managed config (e.g. JSON in `operational_configs`), applied as **great-circle (haversine) or equivalent** distance from the driver’s **current** position to the order’s **pickup** point. |
| **Eligible driver** | A driver who satisfies **all** MVP eligibility rules in Section 3 (availability + radius + freshness; **vehicle type** and other constraints are **Phase 2+** unless explicitly added to config later). |
| **Offer window** | The time window during which eligible drivers may **self-accept** an order that is in **`searching_driver`**. Bounded by config (e.g. `accept_window_seconds`). May be **re-opened** (re-broadcast) by policy. |
| **Manual assignment** | **Admin** or **Sales** sets (or changes) the assigned driver without going through the competitive self-accept race, subject to rules in Section 7. |
| **Self-accept broadcast** | Server computes eligible drivers, notifies them (push in MVP), and the **first successful accept** wins — enforced with **DB-level atomicity** (Section 5). |

**Order status naming (product vs implementation):**

- Product lifecycle ([`README.md`](../README.md) §6.1): `SearchingDriver`, `Assigned`, `Accepted`, etc.
- This document uses **implementation-oriented snake_case** where helpful (e.g. `searching_driver`, `assigned_driver_id`). Implementations should map enums consistently.

---

## 2) Required inputs (data contracts)

### 2.1 From `orders`

| Field / concept | Use in dispatch |
|-----------------|----------------|
| `order.id` | Correlation for offers, accepts, notifications, audit. |
| `order.status` | Must be **`searching_driver`** for self-accept; transitions on assign/accept guarded atomically. |
| Pickup coordinates | **`pickup_lat` / `pickup_lng`** (or equivalent snapshot fields on `Order`; must match finalized pickup after payment/geocoding). |
| `assigned_driver_id` / `assigned_driver_user_id` | Nullable until assignment; set by manual assign or winning accept (single source of truth in schema). |

### 2.2 From driver / profile (`drivers` app)

| Field / concept | Use in dispatch |
|-----------------|----------------|
| `driver_profiles.approval_status` | Must be **`approved`**. |
| `driver_profiles.is_online` | Must be **`true**` to receive broadcast and to accept. |
| `driver_profiles` suspension / rejection | Suspended or non-approved drivers never eligible. |
| **Current location** | `driver_lat`, `driver_lng` (or dedicated location table/cache); **freshness** via `last_seen_at` vs configured `location_max_age_minutes`. |

### 2.3 From operational config (`pricing` / admin-managed JSON — see [`README.md`](../README.md) §8)

| Key (suggested) | Purpose |
|-----------------|--------|
| `dispatch_radius_km` | Max distance from driver to **pickup** (Section 1). |
| `driver_wait_minutes` | Customer wait at drop-off ([`backend_services.md`](backend_services.md)); not dispatch geometry but referenced for delivery policy. |
| `location_max_age_minutes` | Location considered stale beyond this threshold → driver **ineligible** until location refresh. |
| `accept_window_seconds` | Duration of one offer wave before timeout/re-broadcast escalation (Section 6). |
| *(optional MVP)* `max_rebroadcast_cycles` | Cap automated re-offers before **manual queue** escalation. |

All keys should be validated on write (ranges, positivity) via Admin/configuration APIs.

---

## 3) Eligibility rules (MVP)

A driver is **eligible** for a given order’s broadcast **only if**:

1. **Approved**: `approval_status = approved`.
2. **Online**: `is_online = true`.
3. **Not blocked**: Not **suspended** and not rejected in a state that forbids deliveries.
4. **Fresh location**: `last_seen_at` within **`location_max_age_minutes`** (config); if missing, treat as ineligible.
5. **Within radius**: Distance from driver `(lat, lng)` to order pickup `(pickup_lat, pickup_lng)` ≤ **`dispatch_radius_km`**.
6. **No conflicting active delivery**: Driver is **not** already assigned/accepted/picked-up on **another** order for which delivery is not yet **delivered** / **completed** / **cancelled** (exact status set to match product rules; see invariants below).

**Deferred (not MVP unless added to scope):**

- Vehicle type / capacity matching.
- Load balancing, scoring, or “best driver” ranking ([`README.md`](../README.md) Phase 3).

---

## 4) Dispatch flow (state machine + invariants)

### 4.1 Entry into dispatch

- **Precondition**: Order has left payment flow and is **payment confirmed** (only `payments` / webhook path marks this per [`backend_services.md`](backend_services.md)).
- **Transition**: `payment_confirmed` → **`searching_driver`**.
- **Invariant**: While in `searching_driver`, **`assigned_driver_id` is null** until a valid assignment occurs.

### 4.2 Path A — Self-accept broadcast

1. Order enters `searching_driver`.
2. **`dispatch`** computes **eligible drivers** (Section 3).
3. Server creates an **offer window** (timestamps + optional `offer_generation` id for idempotency).
4. **Notify** eligible drivers via **FCM** ([`architecture.md`](architecture.md)); in-app list refresh / polling on clients is acceptable for MVP.
5. Driver calls **accept** endpoint; server runs **atomic first-accept-wins** (Section 5).
6. On success: order moves to **`assigned`** then **`accepted`** per product flow (see note below); driver app shows active delivery.

**Note on `Assigned` vs `Accepted`:** [`README.md`](../README.md) lists both. MVP implementation may collapse to a single backend transition (`assigned` includes implicit accept) **or** use two steps if the UI requires explicit “Accepted” tap after notification. Regardless, **only one driver** may hold the assignment, and concurrency rules in Section 5 apply at the moment of grab.

### 4.3 Path B — Manual assignment (Admin / Sales)

1. Authorized actor (**Admin** full; **Sales** per MVP permissions — [`README.md`](../README.md) §4) selects a driver while order is **`searching_driver`** (and optionally limited other states — Section 7).
2. **`dispatch`** validates target driver satisfies **eligibility** (Section 3) **or** documents an explicit policy override (“force assign”) if product allows; MVP default is **eligible-only** to avoid bad assignments.
3. Server sets `assigned_driver_id`, transitions order to **`assigned`**, records **`DeliveryEvent`** (or `OrderEvent` timeline entry), and notifies driver + customer.

### 4.4 Invariants (must always hold)

- At most **one** `assigned_driver_id` per order when not cancelled.
- A driver has **at most one** “active” delivery order at a time (define “active” = from `assigned`/`accepted` through `picked_up` until terminal state).
- Eligibility is evaluated **at broadcast time** and **again at accept time** (driver may go offline or move out of radius).

---

## 5) Concurrency & locking (critical)

**First-accept-wins** must be enforced **inside the database** (transaction + conditional update), not only in application memory.

### 5.1 Accept transaction (pseudo-logic)

In a single **database transaction**:

1. `SELECT ... FROM orders WHERE id = :order_id FOR UPDATE`.
2. Verify `status = 'searching_driver'` AND `assigned_driver_id IS NULL` (unless product allows overwriting — **not** MVP default).
3. Re-verify **accepting driver** eligibility (Section 3) against **current** row data.
4. `UPDATE orders SET assigned_driver_id = :driver_id, status = 'assigned', updated_at = now() WHERE id = :order_id AND status = 'searching_driver' AND assigned_driver_id IS NULL`.
5. If **`UPDATE`** affects **zero rows**, another actor won → return **409** / domain error **`ORDER_ALREADY_TAKEN`** with safe message (“Order already taken”).
6. Insert timeline row: **`DeliveryEvent`**/`OrderEvent` with type `driver_assigned` or `driver_accepted`, `actor_role = driver`, `actor_id`.

### 5.2 Suggested safeguards

| Mechanism | Purpose |
|-----------|--------|
| **Unique partial index** | e.g. one active assignment per driver: unique on `(assigned_driver_user_id)` **where** status in active subset — **if** modeled as columns; alternatively enforce in transaction by checking **no other active order** for driver. |
| **Idempotent accept** | If same driver retries accept after success, return **200** with current state (no double events). |
| **Rate limit** | Throttle accept endpoint per driver to reduce accidental spam. |

### 5.3 Manual assign vs race

Manual assign must use the **same** `FOR UPDATE` pattern: if order is no longer `searching_driver`, return a clear error (already assigned, cancelled, etc.).

---

## 6) Timeouts and fallback

| Event | MVP behavior |
|-------|----------------|
| **No accept within `accept_window_seconds`** | Policy choice (config-driven): **(a)** extend window and **re-broadcast** to eligible drivers, and/or **(b)** escalate to **Admin manual assignment queue** (dashboard view of “unassigned”). |
| **Max rebroadcasts** | Optional `max_rebroadcast_cycles`; after cap → force **manual-only** resolution. |
| **Driver SLA after pickup** | Post-accept pickup delays and **customer unreachable** follow [`README.md`](../README.md) operational/driver wait policies; reassignment thresholds are **future** unless specified in config — document as extension point only. |

Celery (see [`architecture.md`](architecture.md)) should drive scheduled **timeout checks** and re-broadcast jobs; workers must repeat eligibility queries, not stale cached lists.

---

## 7) Manual assignment rules (Admin / Sales)

| Rule | MVP |
|------|-----|
| **Who may assign** | **Admin**: full assignment/reassignment. **Sales**: assign while monitoring orders ([`README.md`](../README.md) §7). |
| **When reassignment allowed** | **Before `picked_up`**: preferred default; avoids accounting and liability confusion. Post-pickup reassignment requires explicit product/ops policy (**defer** unless approved). |
| **Eligibility** | Target driver **must pass** Section 3 checks unless an explicit audited **override** exists (recommended **off** for MVP). |
| **Cancellation** | **Admin-only** cancellation per MVP ops policy ([`backend_services.md`](backend_services.md)). |
| **Audit** | Every assign/reassign emits **`DeliveryEvent`** (actor role, actor id, timestamp, previous driver if any). |

---

## 8) Edge cases

| Scenario | Handling |
|---------|----------|
| **Order cancelled** while `searching_driver` | Invalidate offer window; send **cancellation** pushes to notified drivers optional; release any reservations. Accept attempts after cancel → **`ORDER_CANCELLED`** error. |
| **Order cancelled** after assign/accept | Follow cancellation policy + notifications; driver app clears active job. |
| **Driver goes offline** after accepting | Dispatcher / Admin visibility; eventual **manual reassign** if driver cannot proceed; timeline events (`driver_offline_note`) if supported. |
| **Driver declines / ignores** | No state change on order beyond optional metrics; eligibility can exclude drivers who exceeded decline threshold (**future**). |
| **Stale location at accept** | Re-check freshness at accept; reject with **`LOCATION_STALE`** or similar. |
| **Two devices same driver** | Idempotent accept; still one DB winner. |
| **Customer unreachable** | Use existing **`driver_wait_minutes`** and operational procedures ([`README.md`](../README.md) §7 driver edge cases); emits delivery events / admin visibility. |

---

## 9) Notifications (MVP)

Per [`architecture.md`](architecture.md), MVP relies on **FCM push** (no websocket requirement).

| Recipient | Trigger |
|-----------|---------|
| **Eligible drivers** | New dispatch offer: order id, pickup summary, SLA hint. |
| **Assigned driver** | Manual assign confirmation; reassignment notices. |
| **Customer / Sales / Admin** | Assignment success, cancellation, major status changes (align with `notifications` app responsibilities in [`backend_services.md`](backend_services.md)). |

Notification failures should **not** block core DB assignment; retries via Celery are recommended.

---

## 10) Metrics (MVP)

Baseline operational KPIs (**analytics** app / aggregates):

| Metric | Definition |
|--------|------------|
| **Time-to-assign** | Timestamp `searching_driver` → first successful assign/accept. |
| **Acceptance rate** | Accepts ÷ broadcasts (per driver cohort optional). |
| **Cancellation rate** | Cancels ÷ confirmed orders while in dispatch states. |
| **Driver response latency** | Notification sent → accept click (histogram). |

Expose via internal analytics endpoints ([`backend_services.md`](backend_services.md)) for Admin dashboards.

---

## API surface reference (logical)

Concrete routes live under DRF versioning; **`dispatch`** should own:

| Method / path | Role |
|---------------|------|
| `GET /orders/available` (driver) | List orders driver may accept (**filtered server-side**, not trusting client). |
| `POST /orders/{id}/accept` (driver) | First-accept-wins transactional accept. |
| `POST /orders/{id}/assign` (Admin/Sales) | Manual assignment with audit. |

(Exact prefixes may follow `dispatch` namespaces in your URL config.)

---

## Summary

**MVP dispatch** combines **manual assignment** from Admin/Sales with a **broadcast + self-accept** path under a **fixed `dispatch_radius_km`**. **Eligibility** is strict **approved + online + fresh location + radius + no active delivery**. **Correctness depends on transactional, conditional updates** so only the first accept wins under concurrency. Timeouts rebroadcast or escalate to manual assignment; notifications use **FCM** with Stage 2 websockets deferred.
