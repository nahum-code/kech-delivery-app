# Data Model Overview (MVP)

This document lists the **core entities** for the MVP, extracted from `README.md` and the system architecture decisions.

## Core Entities (MVP)

```
User
CustomerProfile
DriverProfile
DriverDocument
Address
Restaurant
RestaurantImage
OpeningHours
MenuCategory
MenuItem
MenuItemImage
Order
OrderItem
Payment
DeliveryEvent
Notification
DeviceToken
PricingConfig
OperationalConfig
```

Notes:
- MVP stores **order snapshots**: menu item name/price and pricing breakdown at order creation time.
- MVP pricing is **channel-based** (Customer channel vs Sales channel).
- Uploads are **direct client → Firebase Storage**, so database stores file URLs + metadata (not blobs).

