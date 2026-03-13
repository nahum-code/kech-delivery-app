# Backend Services (Django Apps) — Day 2 (Refined)

This document defines the **backend service architecture** as **Django apps** (not microservices), aligned to the MVP scope in `README.md` and your refined backend layout recommendation.

## Service List (Logical Modules)

| Service (Django app) | Responsibility | Key models / data | Key API surfaces (examples) |
|---|---|---|---|
| **accounts** | Authentication, user model, JWT issuance/refresh, role claims | `User`, tokens/claims | `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/me` |
| **drivers** | Driver profiles, documents, approval workflow, availability | `DriverProfile`, `DriverDocument` | `/drivers/register`, `/drivers/docs`, `/drivers/availability` |
| **restaurants** | Restaurants CRUD, activation, opening hours, images metadata | `Restaurant`, `OpeningHours` | `/restaurants`, `/restaurants/{id}` |
| **menus** | Menu categories/items CRUD, item availability, images metadata | `MenuCategory`, `MenuItem` | `/restaurants/{id}/menu` |
| **orders** | Orders + state machine + event timeline + snapshots + cancel/modify rules | `Order`, `OrderItem`, `OrderEvent` | `/orders`, `/orders/{id}`, `/orders/{id}/cancel`, `/orders/{id}/events` |
| **dispatch** | Driver assignment: manual assign + driver self-accept, eligibility filters | assignment records/events | `/orders/available`, `/orders/{id}/assign`, `/orders/{id}/accept` |
| **payments** | Chapa integration: init checkout, webhook verification, payment ledger | `Payment`, webhook logs | `/payments/init`, `/payments/webhook/chapa` |
| **pricing** | Distance-based fee estimate + channel-based pricing configs + financial snapshot helpers | `OperationalConfig` (pricing/policy) | `/pricing/estimate`, (admin) `/pricing/config` |
| **notifications** | Device tokens + push notification pipeline (FCM) | `DeviceToken`, `Notification` | `/devices/register`, `/notifications` |
| **analytics** | Revenue, driver payout summaries, platform profit reports | aggregates/views | `/analytics/revenue`, `/analytics/driver-payouts`, `/analytics/profit` |

Notes:
- The previous `tracking` app is folded into **`orders`** for MVP (order events + allowed state transitions). You can split it later if it grows.
- Operational config storage from the previous `config` app is folded into **`pricing`** to match the refined layout (still admin-managed, dynamic).
- File storage flows are **direct client → Firebase Storage**, so no dedicated `media` app is required in MVP (backend only stores URLs/metadata).

## Recommended Django App Structure (Refined)

```text
backend/
  manage.py

  config/
    settings/
    urls.py
    asgi.py
    wsgi.py

  apps/
    accounts/        # authentication + user model
    drivers/         # driver profiles + approval
    restaurants/     # restaurants CRUD
    menus/           # menu categories + items
    orders/          # orders + state machine (+ event timeline)
    dispatch/        # driver assignment logic
    payments/        # chapa integration
    pricing/         # delivery fee calculation + operational pricing config
    notifications/   # push notifications
    analytics/       # reports & metrics

  shared/
    permissions/
    utils/
    constants/
    exceptions/
    validators/
```

## Cross-Cutting Rules (from README.md)

- **Order financial snapshot fields (MVP)** stored on Order:
  - `delivery_fee`, `driver_payout`, `platform_fee`
- **Channel-based pricing configs**:
  - Customer channel pricing
  - Sales channel pricing
- **Admin-only cancellation** in MVP (customer cannot cancel after placement).
- **Restaurant opening hours enforcement** (no new orders before opening time).
- **Driver wait policy** (e.g., 30 minutes) is configurable; driver can emit “customer unreachable” event.

## Ownership Boundaries

- `orders` owns order creation and cart validation, and enforces allowed state transitions.
- `pricing` computes estimates and produces pricing snapshots consumed by `orders`.
- `payments` is the only module allowed to mark payment confirmed (after webhook verification).
- `dispatch` manages assignment and driver accept flows.

