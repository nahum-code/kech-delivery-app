# Database Schema (PostgreSQL) — MVP

This document defines the **MVP PostgreSQL schema** for the Kech Delivery App. It is designed to support the workflows and policies in `README.md`:
- channel-based pricing (Customer vs Sales)
- admin-only cancellation
- driver approval + document uploads
- restaurant opening hours enforcement
- order-level financial snapshots: `delivery_fee`, `driver_payout`, `platform_fee`

> Implementation note: In Django, you can implement enums as `TextChoices` or Postgres enums; this schema documents them as enums for clarity.

## 1) Enumerations

### `user_role`
- `customer`
- `driver`
- `sales_agent`
- `admin`

### `user_status`
- `active`
- `suspended`
- `deleted`

### `driver_approval_status`
- `registered`
- `docs_submitted`
- `under_review`
- `approved`
- `rejected`
- `suspended`

### `restaurant_status`
- `active`
- `inactive`

### `order_status`
- `draft` (sales only)
- `placed`
- `payment_pending`
- `payment_confirmed`
- `searching_driver`
- `assigned`
- `accepted`
- `picked_up`
- `delivered`
- `completed`
- `cancelled`
- `payment_failed`
- `payment_refunded`

### `payment_provider`
- `chapa`

### `payment_status`
- `initiated`
- `pending`
- `confirmed`
- `failed`
- `refunded`

### `delivery_event_type`
Minimum set (extendable):
- `order_created`
- `payment_initiated`
- `payment_confirmed`
- `payment_failed`
- `driver_assigned`
- `driver_accepted`
- `picked_up`
- `delivered`
- `completed`
- `cancelled`
- `customer_unreachable`
- `admin_note`

### `notification_channel`
- `push`
- `in_app`

### `pricing_channel`
- `customer`
- `sales`

## 2) Tables and Fields

### 2.1 `users`
Core authentication and role identity table (**single role per user in MVP**).

Fields:
- `id` (uuid, pk)
- `phone` (text, unique, not null)
- `email` (text, unique, null)
- `password_hash` (text, not null)
- `role` (`user_role`, not null)
- `status` (`user_status`, not null, default `active`)
- `last_login_at` (timestamptz, null)
- `created_at` (timestamptz, not null)
- `updated_at` (timestamptz, not null)

Indexes:
- unique: `(phone)`
- unique: `(email)` where email is not null
- index: `(role, status)`

### 2.2 `customer_profiles`
Fields:
- `id` (uuid, pk)
- `user_id` (uuid, fk → `users.id`, unique, not null)
- `full_name` (text, null)
- `default_address_id` (uuid, fk → `addresses.id`, null)
- `created_at`, `updated_at` (timestamptz)

Constraints:
- 1:1 with `users` via unique `user_id`

### 2.3 `driver_profiles`
Fields:
- `id` (uuid, pk)
- `user_id` (uuid, fk → `users.id`, unique, not null)
- `vehicle_type` (text, null)  (e.g., bike, motorbike, car)
- `approval_status` (`driver_approval_status`, not null, default `registered`)
- `rating_avg` (numeric(3,2), null)
- `rating_count` (int, not null, default 0)
- `is_online` (boolean, not null, default false)
- `last_seen_at` (timestamptz, null)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(approval_status)`
- index: `(is_online)`

### 2.4 `driver_documents`
Stores driver KYC documents metadata (files live in Firebase Storage).

Fields:
- `id` (uuid, pk)
- `driver_profile_id` (uuid, fk → `driver_profiles.id`, not null)
- `doc_type` (text, not null) (e.g., national_id, license, profile_photo)
- `file_url` (text, not null)
- `status` (text, not null, default `submitted`) (simple MVP: submitted/approved/rejected)
- `submitted_at` (timestamptz, not null)
- `reviewed_by_user_id` (uuid, fk → `users.id`, null)
- `reviewed_at` (timestamptz, null)

Indexes:
- index: `(driver_profile_id, doc_type)`

### 2.5 `addresses`
Saved customer addresses (and can be re-used for Sales-created orders via snapshots).

Fields:
- `id` (uuid, pk)
- `user_id` (uuid, fk → `users.id`, not null)
- `label` (text, null) (e.g., Home, Work)
- `address_text` (text, not null)
- `formatted_address` (text, null)
- `latitude` (numeric(9,6), null)
- `longitude` (numeric(9,6), null)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(user_id, created_at desc)`
- index: `(latitude, longitude)` (optional)

### 2.6 `restaurants`
Fields:
- `id` (uuid, pk)
- `name` (text, not null)
- `description` (text, null)
- `phone` (text, null)
- `address_text` (text, null)
- `latitude` (numeric(9,6), not null)
- `longitude` (numeric(9,6), not null)
- `status` (`restaurant_status`, not null, default `active`)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(status)`
- index: `(latitude, longitude)` (for nearby queries)

### 2.7 `restaurant_images`
Fields:
- `id` (uuid, pk)
- `restaurant_id` (uuid, fk → `restaurants.id`, not null)
- `image_url` (text, not null)
- `sort_order` (int, not null, default 0)
- `created_at` (timestamptz)

### 2.8 `opening_hours`
Per-day restaurant schedule (recommended). If you want MVP-simple, you can store one opening time on `restaurants`.

Fields:
- `id` (uuid, pk)
- `restaurant_id` (uuid, fk → `restaurants.id`, not null)
- `day_of_week` (smallint, not null) (0=Sun..6=Sat)
- `open_time` (time, not null)
- `close_time` (time, not null)
- `is_closed` (boolean, not null, default false)

Constraints:
- unique: `(restaurant_id, day_of_week)`

### 2.9 `menu_categories`
Fields:
- `id` (uuid, pk)
- `restaurant_id` (uuid, fk → `restaurants.id`, not null)
- `name` (text, not null)
- `sort_order` (int, not null, default 0)
- `is_active` (boolean, not null, default true)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(restaurant_id, sort_order)`

### 2.10 `menu_items`
Fields:
- `id` (uuid, pk)
- `category_id` (uuid, fk → `menu_categories.id`, not null)
- `name` (text, not null)
- `description` (text, null)
- `price` (numeric(12,2), not null)
- `currency` (text, not null, default `ETB`)
- `is_available` (boolean, not null, default true)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(category_id, is_available)`

### 2.11 `menu_item_images`
Fields:
- `id` (uuid, pk)
- `menu_item_id` (uuid, fk → `menu_items.id`, not null)
- `image_url` (text, not null)
- `sort_order` (int, not null, default 0)
- `created_at` (timestamptz)

### 2.12 `orders`
Stores the order **and** the order-level snapshot fields needed for history, pricing, and analytics.

Fields:
- `id` (uuid, pk)
- `order_number` (bigserial, unique, not null) (human-readable reference)
- `created_by_user_id` (uuid, fk → `users.id`, not null)
- `created_by_role` (`user_role`, not null) (customer or sales_agent)
- `customer_user_id` (uuid, fk → `users.id`, not null)
- `restaurant_id` (uuid, fk → `restaurants.id`, not null)

- `status` (`order_status`, not null)
- `cancellation_reason` (text, null)
- `cancelled_by_user_id` (uuid, fk → `users.id`, null) (admin only in MVP)
- `cancelled_at` (timestamptz, null)

- `assigned_driver_user_id` (uuid, fk → `users.id`, null)
- `assigned_at` (timestamptz, null)
- `accepted_at` (timestamptz, null)
- `picked_up_at` (timestamptz, null)
- `delivered_at` (timestamptz, null)
- `completed_at` (timestamptz, null)

Pricing + delivery snapshot:
- `pricing_channel` (`pricing_channel`, not null) (customer/sales)
- `distance_km` (numeric(8,3), not null)
- `duration_min` (numeric(8,2), null)

- `pickup_name` (text, null) (restaurant name snapshot optional)
- `pickup_address_text` (text, null)
- `pickup_latitude` (numeric(9,6), not null)
- `pickup_longitude` (numeric(9,6), not null)

- `dropoff_address_text` (text, not null)
- `dropoff_formatted_address` (text, null)
- `dropoff_latitude` (numeric(9,6), not null)
- `dropoff_longitude` (numeric(9,6), not null)

Financial snapshot fields (MVP):
- `delivery_fee` (numeric(12,2), not null)
- `driver_payout` (numeric(12,2), not null)
- `platform_fee` (numeric(12,2), not null)
- `currency` (text, not null, default `ETB`)

Order notes:
- `customer_note` (text, null)
- `internal_note` (text, null) (admin/sales)

Timestamps:
- `created_at` (timestamptz, not null)
- `updated_at` (timestamptz, not null)

Indexes:
- unique: `(order_number)`
- index: `(customer_user_id, created_at desc)`
- index: `(restaurant_id, created_at desc)`
- index: `(assigned_driver_user_id, status, created_at desc)`
- index: `(status, created_at desc)`
- index: `(pricing_channel, created_at desc)`

### 2.13 `order_items`
Snapshot menu item data at order time (so history doesn’t break if menu changes).

Fields:
- `id` (uuid, pk)
- `order_id` (uuid, fk → `orders.id`, not null)
- `menu_item_id` (uuid, fk → `menu_items.id`, null) (nullable to allow deleted items later)

Snapshot fields:
- `item_name` (text, not null)
- `unit_price` (numeric(12,2), not null)
- `quantity` (int, not null)
- `line_total` (numeric(12,2), not null)
- `currency` (text, not null, default `ETB`)

Indexes:
- index: `(order_id)`

### 2.14 `payments`
Payment attempts/ledger. Multiple rows per order supports retries.

Fields:
- `id` (uuid, pk)
- `order_id` (uuid, fk → `orders.id`, not null)
- `provider` (`payment_provider`, not null, default `chapa`)
- `status` (`payment_status`, not null)
- `amount` (numeric(12,2), not null)
- `currency` (text, not null, default `ETB`)

- `provider_reference` (text, not null) (unique id from Chapa, or your generated tx ref)
- `checkout_url` (text, null)

- `initiated_at` (timestamptz, not null)
- `confirmed_at` (timestamptz, null)
- `raw_webhook_payload` (jsonb, null) (optional but useful in MVP)

Constraints:
- unique: `(provider, provider_reference)`

Indexes:
- index: `(order_id, initiated_at desc)`
- index: `(status, initiated_at desc)`

### 2.15 `delivery_events`
Immutable order timeline (audit-friendly).

Fields:
- `id` (uuid, pk)
- `order_id` (uuid, fk → `orders.id`, not null)
- `event_type` (`delivery_event_type`, not null)
- `actor_role` (`user_role`, null)
- `actor_user_id` (uuid, fk → `users.id`, null)
- `message` (text, null)
- `metadata` (jsonb, null)
- `created_at` (timestamptz, not null)

Indexes:
- index: `(order_id, created_at asc)`
- index: `(event_type, created_at desc)`

### 2.16 `device_tokens`
Required for FCM push notifications.

Fields:
- `id` (uuid, pk)
- `user_id` (uuid, fk → `users.id`, not null)
- `platform` (text, not null) (`android`, `ios`, `web`)
- `token` (text, not null)
- `is_active` (boolean, not null, default true)
- `last_seen_at` (timestamptz, null)
- `created_at` (timestamptz, not null)

Constraints:
- unique: `(token)`

Indexes:
- index: `(user_id, is_active)`

### 2.17 `notifications`
Store notifications for audit/in-app inbox (even if MVP UI is minimal).

Fields:
- `id` (uuid, pk)
- `user_id` (uuid, fk → `users.id`, not null)
- `channel` (`notification_channel`, not null)
- `title` (text, not null)
- `body` (text, not null)
- `data` (jsonb, null)
- `is_read` (boolean, not null, default false)
- `sent_at` (timestamptz, null)
- `created_at` (timestamptz, not null)

Indexes:
- index: `(user_id, created_at desc)`
- index: `(user_id, is_read, created_at desc)`

### 2.18 `pricing_configs`
Stores channel-based pricing settings (admin-managed, versioned).

Fields:
- `id` (uuid, pk)
- `channel` (`pricing_channel`, not null)
- `base_fee` (numeric(12,2), not null)
- `per_km_rate` (numeric(12,2), not null)
- `service_charge` (numeric(12,2), not null, default 0)
- `min_fee` (numeric(12,2), not null, default 0) (supports “per-km + minimum”)
- `currency` (text, not null, default `ETB`)
- `is_active` (boolean, not null, default true)
- `effective_from` (timestamptz, not null)
- `created_by_user_id` (uuid, fk → `users.id`, null)
- `created_at` (timestamptz, not null)

Constraints:
- index-only rule: only one active config per channel at a time (enforce in app logic or partial unique index)

Indexes:
- index: `(channel, is_active, effective_from desc)`

### 2.19 `operational_configs`
Simple dynamic configuration store for non-pricing policies (driver wait minutes, cancellation rules, etc.).

Fields:
- `id` (uuid, pk)
- `key` (text, unique, not null)
- `value` (text, not null)
- `value_type` (text, not null) (`int`, `decimal`, `bool`, `time`, `json`, `string`)
- `updated_by_user_id` (uuid, fk → `users.id`, null)
- `updated_at` (timestamptz, not null)

Examples:
- `driver_wait_minutes = 30`
- `customer_can_cancel = false` (MVP)

## 3) Relationships Summary

```
users 1—1 customer_profiles (only when users.role=customer)
users 1—1 driver_profiles (only when users.role=driver)
users 1—many addresses

driver_profiles 1—many driver_documents

restaurants 1—many menu_categories 1—many menu_items
restaurants 1—many restaurant_images
restaurants 1—many opening_hours

orders 1—many order_items
orders 1—many payments
orders 1—many delivery_events

users 1—many device_tokens
users 1—many notifications

pricing_configs (channel-based) used to compute order snapshots
operational_configs used to enforce policies and defaults
```

## 4) Workflow Validation Against MVP Requirements

### Customer flow: register → browse → order → pay → track
- Register/login: `users`, `customer_profiles`
- Save address: `addresses` (lat/lng + text)
- Browse menus: `restaurants`, `opening_hours`, `menu_categories`, `menu_items`
- Create order: `orders` + `order_items` snapshots + `pricing_channel=customer`
- Pay: `payments` (provider_reference unique) + Chapa webhook support
- Track: `orders.status` + `delivery_events` timeline + `notifications` (optional inbox) + `device_tokens` (push)

### Driver flow: approve → accept order → pickup → deliver
- Register: `users(role=driver)` + `driver_profiles`
- Upload docs: `driver_documents(file_url)` (Firebase Storage)
- Approval: `driver_profiles.approval_status` transitions + admin reviewer fields on docs
- Accept/complete: `orders.assigned_driver_user_id`, timestamps + `delivery_events`
- Unreachable/wait: `delivery_events(event_type=customer_unreachable)` + `operational_configs(driver_wait_minutes)`

### Sales flow: create customer order → pricing channel → manual assignment
- Sales agent account: `users(role=sales_agent)`
- Create order on behalf: `orders.created_by_user_id` + `created_by_role=sales_agent` + `pricing_channel=sales`
- Manual assignment: `orders.assigned_driver_user_id` + assignment events

### Admin flow: manage restaurants/menus, assign drivers, cancel orders
- Manage restaurants/menus: restaurant/menu tables + activation fields
- Assign/reassign: `orders.assigned_driver_user_id`, `delivery_events`
- Cancel (admin-only): `orders.cancelled_by_user_id`, `cancellation_reason`, `cancelled_at` + event
- Analytics: `orders.delivery_fee/driver_payout/platform_fee` snapshot fields enable rollups

