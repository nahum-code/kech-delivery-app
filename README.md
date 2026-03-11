# Kech Delivery App - MVP Scope (Phase 1)

This document defines the implementation scope for Phase 1 (MVP). It also lists features explicitly deferred to Phase 2 to keep delivery focused, testable, and launch-ready.

## Table of Contents
- [1. Product Scope and Assumptions](#1-product-scope-and-assumptions)
- [2. MVP vs Phase 2 Boundaries](#2-mvp-vs-phase-2-boundaries)
- [3. System Modules (MVP)](#3-system-modules-mvp)
- [4. Roles and Permissions (MVP)](#4-roles-and-permissions-mvp)
- [5. Core Data Model (MVP)](#5-core-data-model-mvp)
- [6. Key Workflows (MVP)](#6-key-workflows-mvp)
- [7. User Flows by Role (MVP)](#7-user-flows-by-role-mvp)
- [8. MVP Cut Lines (Explicitly Out of Scope)](#8-mvp-cut-lines-explicitly-out-of-scope)

## 1. Product Scope and Assumptions
- **Applications**
  - One shared mobile app (Customer/Driver mode selected at login)
  - One Admin web dashboard
  - One Sales web dashboard
- **Pricing Formula**
  - Estimated delivery fee = `max(minFee, perKmRate * distanceKm)`
  - Configurable by Admin
- **Payments**
  - Chapa online payment integration
  - Payment status tracking and basic reconciliation
- **Dispatch Model**
  - Manual assignment supported (Sales/Admin)
  - Driver self-accept from available requests
- **Maps and Distance**
  - Distance computed from pickup to drop-off coordinates
  - Address geocoding required

## 2. MVP vs Phase 2 Boundaries

### Included in MVP (Phase 1)
- In-app order lifecycle tracking
- Driver delivery history (for operations visibility)
- In-app notifications only
- Basic analytics and operational reporting
- Simplified financial fields for each order:
  - `delivery_fee`
  - `driver_payout`
  - `platform_fee`

### Deferred to Phase 2
- Rating and feedback system (`Rating(orderId, customerId, driverId, score, comment)`)
- Driver earnings summary dashboard (beyond basic delivery history)
- Advanced notifications (Push + SMS/Email fallback)
- Reorder flow from order history
- Audit log system
- Commission/profit engine with configurable commission percentages and payout rules

## 3. System Modules (MVP)

### 3.1 Mobile App (Shared Binary)

#### Auth and Role Selection
- Customer registration/login
- Driver registration/login (with separate onboarding flow)
- Role-based navigation

#### Customer Mode
- Profile management (name, phone, email)
- Saved addresses
- Restaurant discovery (list/search/filter)
- Restaurant details and menu browsing
- Cart and checkout (items, quantity, notes)
- Delivery fee estimation
- Chapa payment checkout and confirmation
- Order status tracking
- Order history (view only in MVP)

#### Driver Mode
- Driver onboarding (profile + document upload)
- Availability toggle (online/offline)
- Delivery requests (accept/decline)
- Active delivery view (pickup/drop-off details)
- Status updates (`accepted -> pickedUp -> delivered`)
- Delivery history (MVP)

### 3.2 Web Dashboards

#### Sales Dashboard
- Create order on behalf of customer (lookup/create)
- Select restaurant and menu items
- Enter delivery address and pickup notes
- View delivery estimate and place order
- Monitor orders and perform policy-limited modify/cancel
- Manual driver assignment

#### Admin Dashboard
- User management (customers/drivers/sales)
- Driver approval workflow and suspensions
- Restaurant CRUD and activation
- Menu categories/items CRUD, images, availability
- Orders monitoring, assignment/reassignment, cancellation/modification
- System configuration: `perKmRate`, `minFee`
- Basic financial reporting using `delivery_fee`, `driver_payout`, `platform_fee`

### 3.3 Backend Services
- Identity and access (JWT/session, role claims)
- User profiles (customer, driver, sales)
- Driver verification (document storage + approval states)
- Restaurant/menu service
- Ordering service (cart validation, order snapshot)
- Dispatch/assignment service (publish, self-accept, manual assign)
- Tracking/status service (state transitions, event timeline)
- Payments service (Chapa intent/init, webhook verification, payment ledger)
- Pricing service (distance calculation + fee computation)
- Notifications service (in-app notifications only for MVP)
- Analytics/reporting service (MVP operational and financial aggregates)

## 4. Roles and Permissions (MVP)

| Role | Permissions (MVP) |
|---|---|
| Customer | Browse restaurants/menus, place and pay orders, track order status, view order history |
| Driver | Register and submit documents, await approval, go online/offline, accept delivery requests, update delivery status, view delivery history |
| Sales Agent | Create customer orders, monitor orders, policy-limited modify/cancel, manually assign drivers |
| Administrator | Manage users, approve/suspend drivers, manage restaurants/menus, manage orders/assignment, configure pricing, view MVP analytics |

## 5. Core Data Model (MVP)
- **User**(id, phone/email, passwordHash/otp, roleClaims, status)
- **CustomerProfile**(userId, name, defaultAddressId, ...)
- **DriverProfile**(userId, vehicleType?, docs[], approvalStatus, ...)
- **Address**(id, userId, label, text, lat, lng)
- **Restaurant**(id, name, location(lat/lng), openHours?, isActive, images[])
- **MenuCategory**(id, restaurantId, name, sortOrder)
- **MenuItem**(id, categoryId, name, price, isAvailable, imageUrl)
- **Order**(id, createdByRole, customerId, restaurantId, pickupLocationSnapshot, dropoffAddressSnapshot, pricingSnapshot, status, assignedDriverId?, timestamps...)
- **OrderItem**(orderId, menuItemSnapshot, qty, unitPrice)
- **Payment**(id, orderId, provider=Chapa, amount, currency, status, providerRef, webhookLog)
- **DeliveryEvent**(orderId, type, actorRole, actorId, at)
- **PricingConfig**(perKmRate, minFee, effectiveAt)

### Financial Fields Stored per Order (MVP)
- `delivery_fee`
- `driver_payout`
- `platform_fee`

## 6. Key Workflows (MVP)

### 6.1 Order Status Lifecycle
- `Draft` (Sales only) -> `Placed` -> `PaymentPending`/`PaymentConfirmed` -> `SearchingDriver` -> `Assigned` -> `Accepted` -> `PickedUp` -> `Delivered` -> `Completed`
- `Cancelled` (with reason + actor) from limited states
- `PaymentFailed` and `PaymentRefunded` only if supported in the first release implementation

### 6.2 Driver Approval Lifecycle
- `Registered` -> `DocsSubmitted` -> `UnderReview` -> `Approved | Rejected | Suspended`

## 7. User Flows by Role (MVP)

### Customer
- Register/login -> set profile -> save address
- Browse restaurants -> select menu items -> checkout -> fee estimate -> Chapa payment -> confirmation
- Track order through status timeline
- View order history
- Edge cases: payment failure, restaurant inactive, item unavailable, cancellation policy, driver reassignment

### Driver
- Register -> upload docs -> pending approval
- Go online -> view requests -> accept request
- Pickup -> mark picked up -> deliver -> mark delivered
- View delivery history
- Edge cases: order cancelled after accept, customer unreachable, failed delivery, reassignment

### Sales Agent
- Create/lookup customer -> build order -> estimate fee -> place order
- Assign driver manually or allow self-accept flow
- Monitor and policy-limited modify/cancel

### Administrator
- Approve/reject/suspend drivers
- Manage restaurants and menus
- Monitor orders and manage assignment/reassignment
- Configure pricing (`perKmRate`, `minFee`)
- View operational and basic financial reports

## 8. MVP Cut Lines (Explicitly Out of Scope)
The following are intentionally excluded from Phase 1 and will be considered in Phase 2:
- Ratings and customer feedback
- Reorder capability
- Driver earnings summary module
- Push notifications and SMS/Email notification fallback
- Audit logging module
- Commission engine, profit engine, and payout rules configuration
