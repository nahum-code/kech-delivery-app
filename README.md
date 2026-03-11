## Kech Delivery App – MVP Plan

## Scope and assumptions (MVP)
- **Apps**: one shared mobile app (Customer/Driver selected at login), one Admin web dashboard, one Sales web dashboard.
- **Pricing**: **estimated delivery fee = max(minFee, perKmRate × distanceKm)** (configurable by Admin).
- **Payments**: **Chapa** for online payments; include payment status + reconciliation basics.
- **Dispatch**: start with **manual assignment supported** (Sales/Admin), plus **driver self-accept** from available requests.
- **Maps/Geo**: distance computed from pickup→dropoff using coordinates (geocoding required for addresses).

## System modules (logical)
### 1) Mobile app modules (shared binary)
- **Auth & Role Selection**
  - Customer registration/login
  - Driver registration/login (separate onboarding)
  - Role-based navigation, feature flags by role
- **Customer mode**
  - **Profile** (name/phone/email), saved addresses
  - **Restaurant discovery** (list/search/filter), restaurant details
  - **Menu browsing** (categories/items, availability)
  - **Cart & checkout** (items, quantities, notes)
  - **Delivery fee estimate** (distance + pricing)
  - **Payment** (Chapa checkout, confirmation)
  - **Order tracking** (statuses)
  - **Order history + reorder**
  - **Ratings/feedback** (rate driver, delivery feedback)
- **Driver mode**
  - **Driver onboarding** (profile + docs upload)
  - **Availability/online toggle** (ready to receive requests)
  - **Delivery requests** (list, accept/decline)
  - **Active delivery** (pickup/dropoff details, call customer/restaurant)
  - **Status updates** (accepted → pickedUp → delivered)
  - **Earnings summary** + delivery history

### 2) Web dashboards modules
- **Sales dashboard**
  - Create order on behalf of customer (customer lookup/create)
  - Select restaurant + menu items
  - Enter delivery address, optional custom pickup notes
  - See delivery estimate, place order
  - Monitor orders, modify/cancel (policy-limited)
  - Manual driver assignment
- **Admin dashboard**
  - User management (customers/drivers/sales)
  - Driver approval workflow + suspensions
  - Restaurant CRUD + activation
  - Menu categories/items CRUD + images + availability
  - Orders monitoring + manual assignment + cancel/modify
  - Analytics (revenue, driver payouts, commissions, profit)
  - **System configuration**: perKmRate, minFee, commission %, payout rules

### 3) Backend (services/modules)
- **Identity & Access**: JWT/session, password/OTP policy, role claims
- **User Profiles**: customer profile, driver profile, sales profile
- **Driver Verification**: documents storage, approval state machine
- **Restaurant/Menu**: restaurants, categories, items, availability, images
- **Ordering**: cart validation, order creation, order items snapshot
- **Dispatch/Assignment**: publish order to eligible drivers, accept, manual assign
- **Tracking/Status**: order status transitions, event log
- **Payments (Chapa)**: payment intent/init, webhook verification, payment ledger
- **Pricing**: distance calculation + fee computation, config versioning
- **Ratings/Feedback**: driver ratings per completed order
- **Analytics/Reporting**: aggregates for dashboards
- **Notifications**: push + SMS/email (at least push for MVP); fallback to in-app
- **Admin Config/Audit**: audit logs for edits/cancellations

## User roles and permissions (MVP)
- **Customer**
  - Browse restaurants/menus, place/pay orders, track orders, history/reorder, rate driver
- **Driver**
  - Register + upload docs, wait approval, go online/offline, view/accept requests, update delivery status, see earnings/history
- **Sales Agent**
  - Create orders for customers, monitor/modify/cancel under rules, manually assign drivers
- **Administrator**
  - Full management: users, drivers approval, restaurants/menus, orders, pricing config, analytics

## Core entities (data model outline)
- **User**(id, phone/email, passwordHash/otp, roleClaims, status)
- **CustomerProfile**(userId, name, defaultAddressId, …)
- **DriverProfile**(userId, vehicleType?, docs[], approvalStatus, ratingAvg, …)
- **Address**(id, userId, label, text, lat, lng)
- **Restaurant**(id, name, location(lat/lng), openHours?, isActive, images[])
- **MenuCategory**(id, restaurantId, name, sortOrder)
- **MenuItem**(id, categoryId, name, price, isAvailable, imageUrl)
- **Order**(id, createdByRole, customerId, restaurantId, pickupLocationSnapshot, dropoffAddressSnapshot, pricingSnapshot, status, assignedDriverId?, timestamps…)
- **OrderItem**(orderId, menuItemSnapshot, qty, unitPrice)
- **Payment**(id, orderId, provider=Chapa, amount, currency, status, providerRef, webhookLog)
- **DeliveryEvent**(orderId, type, actorRole, actorId, at)
- **Rating**(orderId, customerId, driverId, score, comment)
- **PricingConfig**(perKmRate, minFee, effectiveAt)

## Key workflows (state machines)
### Order status (minimal)
- Draft (sales only) → Placed → PaymentPending/PaymentConfirmed → SearchingDriver → Assigned → Accepted → PickedUp → Delivered → Completed
- Cancelled (with reason + actor) from limited states
- PaymentFailed / PaymentRefunded (if supported in MVP)

### Driver approval
- Registered → DocsSubmitted → UnderReview → Approved | Rejected | Suspended

## User flows to document (what I will produce)
### Customer flows
- Register/login → set profile → save address
- Browse → restaurant detail → add items → checkout → fee estimate → Chapa pay → confirmation
- Track order (status timeline)
- Order history → reorder
- Rate driver + feedback
- Edge cases: payment failure, restaurant inactive, item unavailable, cancellation policy, driver reassigned

### Driver flows
- Register → upload docs → pending approval
- Go online → view requests → accept
- Navigate to pickup → mark picked up → deliver → mark delivered
- View history + earnings
- Edge cases: order cancelled after accept, customer unreachable, failed delivery, reassignment

### Sales flows
- Create customer (or lookup) → build order → estimate fee → place order
- Assign driver manually or let drivers accept
- Monitor + modify/cancel (with audit)

### Admin flows
- Approve drivers
- Manage restaurants/menus
- Monitor orders, assign/reassign drivers, cancel/modify
- Configure pricing + commissions
- View analytics + payout reports

## Deliverables (what you’ll get next)
- A **module decomposition** with clear boundaries and APIs between modules
- A **role/permission matrix** (MVP)
- **Mermaid diagrams** for: auth/role selection, order lifecycle, dispatch/assignment
- Detailed **happy-path + edge-case flows** for each role
- MVP cut-lines: what’s explicitly **out of scope** for v1 and why
