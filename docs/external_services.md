# External Services Integration Plan — Day 2

This document lists external dependencies for the MVP and defines the required integration flows.

## Google Maps API

### Uses (MVP)
- **Geocoding**: address → coordinates (lat/lng)
- **Distance calculation**: pickup → dropoff distance for delivery pricing estimate
- (Optional) **Autocomplete**: improve address UX in Flutter

### APIs
- **Geocoding API**
- **Distance Matrix API** (or Routes API)

### Backend approach
- Prefer a single backend endpoint:
  - `POST /pricing/estimate`
  - Input: pickup coordinates + dropoff coordinates (or dropoff address for server-side geocoding)
  - Output: `distance_km`, `duration_min` (optional), `delivery_fee`, breakdown, config version

### Failure handling (MVP)
- If Maps fails: return “cannot estimate fee” and block checkout.

## Chapa Payment Gateway

### Uses (MVP)
- Online payment checkout for customer orders
- Payment verification using **webhooks** (source of truth)

### Important flows

#### 1) Create payment intent
1. Backend creates `Order` in `PaymentPending`
2. Backend creates `Payment` record (status `INITIATED`)
3. Backend calls Chapa init endpoint and returns `checkout_url`

#### 2) Redirect to Chapa (client)
- Flutter opens `checkout_url` (WebView or external browser)

#### 3) Webhook confirmation
1. Chapa calls backend: `POST /payments/webhook/chapa`
2. Backend verifies signature/secret and validates reference
3. Backend marks:
   - `Payment` → `CONFIRMED`
   - `Order` → `PaymentConfirmed` and proceeds to dispatch

### Failure handling (MVP)
- Payment failed → mark `Payment=FAILED`, order `PaymentFailed` (admin handles resolution).
- Webhook retries/replays → make handler **idempotent**.
- Client “return URL” is not authoritative; show “pending confirmation” until webhook lands.

## Firebase Cloud Messaging (FCM)

### Uses
- New delivery request to drivers
- Order status updates to customers/sales/admin

### Integration approach
- Store device tokens per user:
  - `POST /devices/register`
- Send notifications via Celery tasks (recommended).

## Firebase Storage

### Uses
- Driver documents (KYC)
- Restaurant and menu images

### Integration approach (recommended)
- Backend issues signed upload URLs (or uploads via server SDK)
- Store resulting file URLs in DB.

