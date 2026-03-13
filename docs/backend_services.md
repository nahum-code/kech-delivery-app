# Backend Services (Django Apps) — Day 2

This document defines the **logical backend services** as **Django apps** (not microservices), derived from `README.md` plus your chosen stack (DRF, Channels, Celery, Redis).

## Service List (Logical Modules)

| Service (Django app) | Primary responsibility | Key models / data | Key API surfaces (examples) |
|---|---|---|---|
| **identity** | Auth, login, JWT, role claims | tokens/claims | `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/me` |
| **users** | Customer profiles + addresses | `CustomerProfile`, `Address` | `/customers/me`, `/customers/addresses` |
| **drivers** | Driver onboarding + docs + approval status + availability | `DriverProfile`, `DriverDocument` | `/drivers/register`, `/drivers/docs`, `/drivers/availability` |
| **restaurants** | Restaurant CRUD + activation + opening hours | `Restaurant`, `OpeningHours` | `/restaurants`, `/restaurants/{id}` |
| **menus** | Categories/items CRUD + images + availability | `MenuCategory`, `MenuItem` | `/restaurants/{id}/menu` |
| **orders** | Order creation/validation + snapshots + cancellation rules | `Order`, `OrderItem` | `/orders`, `/orders/{id}`, `/orders/{id}/cancel` |
| **dispatch** | Manual assign + driver self-accept + eligibility | assignment records | `/orders/available`, `/orders/{id}/assign`, `/orders/{id}/accept` |
| **tracking** | Status transitions + immutable event timeline | `DeliveryEvent` | `/orders/{id}/events`, `/orders/{id}/status` |
| **payments** | Chapa init + webhook verify + payment ledger | `Payment`, webhook logs | `/payments/init`, `/payments/webhook/chapa` |
| **pricing** | Fee estimate (distance-based) + financial snapshot helpers | pricing config | `/pricing/estimate` |
| **notifications** | Push + in-app notifications pipeline | `Notification`, device tokens | `/notifications`, `/devices/register` |
| **analytics** | Revenue, payouts, platform profit rollups | aggregates/views | `/analytics/revenue`, `/analytics/driver-payouts`, `/analytics/profit` |
| **config** | Admin-managed operational configs (dynamic) | `OperationalConfig` | `/config`, `/config/{key}` |
| **media** (optional) | Storage abstraction + signed uploads | media metadata | `/media/upload-url` |

## Recommended Django App Structure

```
backend/
  manage.py
  config/                 # settings, urls, asgi/wsgi
  apps/
    identity/
    users/
    drivers/
    restaurants/
    menus/
    orders/
    dispatch/
    tracking/
    payments/
    pricing/
    notifications/
    analytics/
    config/
    media/
  shared/
    permissions/
    utils/
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

- `orders` owns order creation and cart validation.
- `pricing` computes estimates and produces pricing snapshots consumed by `orders`.
- `payments` is the only module allowed to mark payment confirmed (after webhook verification).
- `dispatch` manages assignment and driver accept flows.
- `tracking` manages the event timeline and validates allowed state transitions.

