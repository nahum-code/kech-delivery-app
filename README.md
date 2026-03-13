# Kech Delivery App - MVP Scope (Phase 1)

This document defines the implementation scope for Phase 1 (MVP). It includes functional boundaries, operational policies, and financial handling rules required for a focused, testable, and launch-ready first release.

## Table of Contents
- [1. Product Scope and Assumptions](#1-product-scope-and-assumptions)
- [2. Roadmap Boundaries (MVP, Phase 2, Phase 3)](#2-roadmap-boundaries-mvp-phase-2-phase-3)
- [3. System Modules (MVP)](#3-system-modules-mvp)
- [4. Roles and Permissions (MVP)](#4-roles-and-permissions-mvp)
- [5. Core Data Model (MVP)](#5-core-data-model-mvp)
- [6. Key Workflows (MVP)](#6-key-workflows-mvp)
- [7. User Flows by Role (MVP)](#7-user-flows-by-role-mvp)
- [8. Operational Policies (MVP)](#8-operational-policies-mvp)
- [9. Order Financial Breakdown (MVP)](#9-order-financial-breakdown-mvp)
- [10. Postponed Features by Release Phase](#10-postponed-features-by-release-phase)

## 1. Product Scope and Assumptions
- **Applications**
  - One shared mobile app (Customer/Driver mode selected at login)
  - One Admin web dashboard
  - One Sales web dashboard
- **Pricing and Distance**
  - Distance is computed from pickup to drop-off coordinates
  - Address geocoding is required
  - Pricing is role/channel-based and configurable by Admin (Customer app pricing and Sales dashboard pricing)
- **Payments**
  - Chapa online payment integration
  - Payment status tracking and basic reconciliation
- **Dispatch Model**
  - Manual assignment supported (Sales/Admin)
  - Driver self-accept from available requests

## 2. Roadmap Boundaries (MVP, Phase 2, Phase 3)

### Included in MVP (Phase 1)
- In-app order lifecycle tracking
- Driver delivery history (for operations visibility)
- In-app notifications only
- Basic analytics and operational reporting
- Platform profit tracking using order financial snapshot fields:
  - `delivery_fee`
  - `driver_payout`
  - `platform_fee`

### Deferred to Phase 2
- Basic real-time driver tracking
- Enhanced notification system (Push + Email/SMS fallback)
- Driver earnings dashboard (Driver App)
- Order re-ordering
- Ratings and reviews system (`Rating(orderId, customerId, driverId, score, comment)`)
- Audit log system (basic)
- Commission/profit engine with configurable commission percentages and payout rules

### Deferred to Phase 3
- Advanced analytics dashboard (driver performance, restaurant performance, delivery success rates, customer retention, geographic demand)
- Automated driver payout system
- Smart dispatch optimization (driver ranking, best-driver auto-selection, demand-based dispatch)
- Advanced real-time delivery route tracking
- Advanced audit logs

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
- System configuration for dynamic operational policies and pricing rules
- Basic financial reporting and platform profit tracking using `delivery_fee`, `driver_payout`, `platform_fee`

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
- Configuration service (dynamic Admin-managed operational parameters)

## 4. Roles and Permissions (MVP)

| Role | Permissions (MVP) |
|---|---|
| Customer | Browse restaurants/menus, place and pay orders, track order status, view order history |
| Driver | Register and submit documents, await approval, go online/offline, accept delivery requests, update delivery status, view delivery history |
| Sales Agent | Create customer orders, monitor orders, policy-limited modify/cancel, manually assign drivers |
| Administrator | Manage users, approve/suspend drivers, manage restaurants/menus, manage orders/assignment, cancel orders, configure pricing and operational policies, view MVP analytics |

## 5. Core Data Model (MVP)
- **User**(id, phone/email, passwordHash/otp, roleClaims, status)
- **CustomerProfile**(userId, name, defaultAddressId, ...)
- **DriverProfile**(userId, vehicleType?, docs[], approvalStatus, ...)
- **Address**(id, userId, label, text, lat, lng)
- **Restaurant**(id, name, location(lat/lng), openHours?, isActive, images[])
- **MenuCategory**(id, restaurantId, name, sortOrder)
- **MenuItem**(id, categoryId, name, price, isAvailable, imageUrl)
- **Order**(id, created_by_user_id, created_by_role, customerId, restaurantId, pickupLocationSnapshot, dropoffAddressSnapshot, pricingSnapshot, status, assignedDriverId?, timestamps...)
- **OrderItem**(orderId, menuItemSnapshot, qty, unitPrice)
- **Payment**(id, orderId, provider=Chapa, amount, currency, status, providerRef, webhookLog)
- **DeliveryEvent**(orderId, type, actorRole, actorId, at)
- **OperationalConfig**(key, value, effectiveAt, updatedBy)

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
- Configure pricing and operational policies
- View operational and basic financial reports

## 8. Operational Policies (MVP)

The following operational policies define initial platform behavior for pricing, cancellations, driver waiting time, and restaurant availability.

All values must be configurable by Administrator users in the Admin Dashboard so future adjustments can be made without application code changes.

### 8.1 Delivery Pricing Policy

#### Customer App Orders
Delivery fee formula:

`delivery_fee = baseFee + (perKmRate × distanceKm) + serviceCharge`

Initial configuration:

| Parameter | Value |
|---|---|
| baseFee | 50 ETB |
| perKmRate | 25 ETB per km |
| serviceCharge | 10 ETB |

Example:
- Distance = 2 km
- `delivery_fee = 50 + (25 × 2) + 10`
- `delivery_fee = 110 ETB`

#### Sales Agent Orders
Orders created by Sales Agents through the Sales Dashboard use a separate pricing configuration.

Initial configuration:

| Parameter | Value |
|---|---|
| baseFee | 50 ETB |
| perKmRate | 10 ETB per km |

Example:
- Distance = 2 km
- `delivery_fee = 50 + (10 × 2)`
- `delivery_fee = 70 ETB`

### 8.2 Cancellation Policy
- Customers cannot cancel orders after placement in MVP.
- Only Administrators can cancel orders.
- Every cancellation must include:
  - cancellation reason
  - actor (`Admin`)

### 8.3 Driver Wait Policy
- If a driver arrives and the customer is unavailable, the driver waits up to 30 minutes.
- If the customer remains unreachable, the driver can report `Customer Unreachable`.
- Final action is handled through Admin review.

### 8.4 Restaurant Opening Policy
- Restaurants have defined opening hours.

Initial configuration:

| Parameter | Value |
|---|---|
| Opening Time | 08:30 AM |

- Restaurants cannot receive new orders before opening time.
- Restaurant hours are configurable by Admin.

### 8.5 Sales Agent Performance Tracking
- Every order created through the Sales Dashboard must capture the Sales Agent identity.
- This enables Admin reporting for:
  - number of orders created per Sales Agent
  - order performance metrics
  - operational accountability

Example order fields:
- `created_by_user_id`
- `created_by_role = sales_agent`

### 8.6 Admin Configuration Requirement
All operational policy values are stored as dynamic configuration values managed through the Admin Dashboard.

Configurable parameters include:
- base delivery fee
- per km rate
- service charge
- sales agent pricing rules
- driver wait time
- restaurant opening hours
- cancellation permissions

This ensures the platform can adapt to operational changes without requiring new deployments.

## 9. Order Financial Breakdown (MVP)

Each order must store a financial snapshot that records how the total delivery fee is distributed between the driver and the platform.

All financial fields are stored directly in the Order record to preserve historical accuracy even when pricing rules change.

### 9.1 Financial Fields Stored per Order

| Field | Description |
|---|---|
| `delivery_fee` | Total delivery fee charged to the customer |
| `driver_payout` | Amount paid to the driver |
| `platform_fee` | Amount kept by the platform |

Example order record:
- `delivery_fee = 110 ETB`
- `driver_payout = 100 ETB`
- `platform_fee = 10 ETB`

### 9.2 Financial Calculation Example

Example order:
- Distance = 2 km
- Customer pricing configuration:
  - `baseFee = 50`
  - `perKmRate = 25`
  - `serviceCharge = 10`

Delivery fee calculation:
- `delivery_fee = 50 + (25 × 2) + 10`
- `delivery_fee = 110 ETB`

Financial distribution example:
- `driver_payout = 100 ETB`
- `platform_fee = 10 ETB`

### 9.3 Why Financial Snapshots Are Stored
Financial values are stored at order creation time to ensure:
- historical accuracy
- correct driver payouts
- reliable financial reporting
- protection against pricing rule changes

Even when Admin users update pricing rules later, existing orders must keep their original financial values.

### 9.4 Admin Reporting (MVP)
The Admin Dashboard generates financial reports from stored order-level values.

Examples:
- Platform Revenue: `sum(platform_fee)`
- Driver Payout Report: `sum(driver_payout)` grouped by driver
- Total Delivery Revenue: `sum(delivery_fee)`

These reports provide baseline operational and financial visibility for MVP.

### 9.5 Future Financial System (Phase 2+)
Future phases may extend financial capabilities with:
- configurable commission percentages
- automated driver payout calculations
- payout schedules
- refunds and adjustments
- settlement reports

These capabilities are explicitly out of scope for MVP.

## 10. Postponed Features by Release Phase

The following capabilities are intentionally excluded from Phase 1 (MVP) and planned for future phases.

### Phase 2
- Basic real-time driver tracking
- Enhanced notification system (Push + Email/SMS fallback)
- Driver earnings dashboard (Driver App)
- Order re-ordering
- Ratings and reviews
- Audit log system (basic)
- Commission and profit engine with payout rules

### Phase 3
- Advanced analytics dashboard (driver performance metrics, restaurant performance, delivery success rates, customer retention, geographic demand analysis)
- Automated driver payout system
- Smart dispatch optimization (performance-based ranking, automatic best-driver selection, demand-based dispatch)
- Advanced real-time delivery route tracking
- Advanced audit logs
