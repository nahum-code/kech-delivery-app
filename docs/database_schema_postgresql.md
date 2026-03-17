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

### `driver_document_status`
- `submitted`
- `approved`
- `rejected`

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
- `rating_avg` (numeric(3,2) CHECK (rating_avg >= 1.0 AND rating_avg <= 5.0), null)
- `rating_count` (int, not null, default 0)
- `is_online` (boolean, not null, default false)
- `last_seen_at` (timestamptz, null)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(approval_status)`
- index: `(is_online)`

Rating invariant (recommended):
- Keep `rating_avg` **NULL** when `rating_count = 0` (unknown/no ratings yet). Do not store `0.00` as a sentinel.
- When a new rating is added, update both `rating_count` and `rating_avg` in the same transaction.

### 2.4 `driver_documents`
Stores driver KYC documents metadata (files live in Firebase Storage).

Fields:
- `id` (uuid, pk)
- `driver_profile_id` (uuid, fk → `driver_profiles.id`, not null)
- `doc_type` (text, not null) (e.g., national_id, license, profile_photo)
- `file_url` (text, not null)
- `status` (`driver_document_status`, not null, default `submitted`)
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
- `latitude` (numeric(9,6) CHECK (latitude >= -90 AND latitude <= 90), null)
- `longitude` (numeric(9,6) CHECK (longitude >= -180 AND longitude <= 180), null)
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
- `latitude` (numeric(9,6) CHECK (latitude >= -90 AND latitude <= 90), not null)
- `longitude` (numeric(9,6) CHECK (longitude >= -180 AND longitude <= 180), not null)
- `location` (geography(Point,4326), not null) (PostGIS point; derived from latitude/longitude)
- `status` (`restaurant_status`, not null, default `active`)
- `created_at`, `updated_at` (timestamptz)

Indexes:
- index: `(status)`
- spatial index (recommended): GiST index on `location` for radius/KNN queries

PostGIS note:
- Enable PostGIS with: `CREATE EXTENSION IF NOT EXISTS postgis;`
- Prefer distance queries using `location` (e.g., `ST_DWithin`, `ST_Distance`, and KNN operator `<->`) rather than B-tree `(latitude, longitude)`.

Example spatial index:

```sql
CREATE INDEX idx_restaurants_location_gist
ON restaurants
USING gist (location);
```

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
- `day_of_week` (smallint CHECK (day_of_week >= 0 AND day_of_week <= 6), not null) (0=Sun..6=Sat)
- `open_time` (time, not null)
- `close_time` (time, not null)
- `is_closed` (boolean, not null, default false)

Constraints:
- unique: `(restaurant_id, day_of_week)`
- check: `(is_closed = true) OR (close_time > open_time)`

Overnight-hours note:
- If you plan to support overnight spans (e.g., `22:00 → 02:00`), revise the time-range rule (common options: add a `spans_midnight` flag, or store full timestamps per day window).

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
- `price` (numeric(12,2) CHECK (price >= 0), not null)
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
- `distance_km` (numeric(8,3) CHECK (distance_km >= 0), not null)
- `duration_min` (numeric(8,2) CHECK (duration_min >= 0), null)

- `pickup_name` (text, null) (restaurant name snapshot optional)
- `pickup_address_text` (text, null)
- `pickup_latitude` (numeric(9,6) CHECK (pickup_latitude >= -90 AND pickup_latitude <= 90), not null)
- `pickup_longitude` (numeric(9,6) CHECK (pickup_longitude >= -180 AND pickup_longitude <= 180), not null)

- `dropoff_address_text` (text, not null)
- `dropoff_formatted_address` (text, null)
- `dropoff_latitude` (numeric(9,6) CHECK (dropoff_latitude >= -90 AND dropoff_latitude <= 90), not null)
- `dropoff_longitude` (numeric(9,6) CHECK (dropoff_longitude >= -180 AND dropoff_longitude <= 180), not null)

Financial snapshot fields (MVP):
- `delivery_fee` (numeric(12,2) CHECK (delivery_fee >= 0), not null)
- `driver_payout` (numeric(12,2) CHECK (driver_payout >= 0), not null)
- `platform_fee` (numeric(12,2) CHECK (platform_fee >= 0), not null)
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
- `unit_price` (numeric(12,2) CHECK (unit_price >= 0), not null)
- `quantity` (int CHECK (quantity > 0), not null)
- `line_total` (numeric(12,2) CHECK (line_total >= 0), not null)
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
- `amount` (numeric(12,2) CHECK (amount >= 0), not null)
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

Immutability enforcement (recommended):
- Treat this table as **append-only**: allow `INSERT`, block `UPDATE`/`DELETE` at the DB level.

Example PostgreSQL safeguard:

```sql
-- 1) Reduce accidental modification via privileges (default is already limited,
--    but being explicit prevents surprises in shared environments).
REVOKE UPDATE, DELETE ON TABLE delivery_events FROM PUBLIC;

-- Optional: if you use a dedicated application role, grant only what you need.
-- GRANT SELECT, INSERT ON TABLE delivery_events TO app_role;
-- REVOKE UPDATE, DELETE ON TABLE delivery_events FROM app_role;

-- 2) Enforce immutability even for roles that still have UPDATE/DELETE privileges.
CREATE OR REPLACE FUNCTION prevent_delivery_events_modification()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'delivery_events is append-only (UPDATE/DELETE not allowed)';
END;
$$;

CREATE TRIGGER delivery_events_immutable_trg
BEFORE UPDATE OR DELETE ON delivery_events
FOR EACH ROW
EXECUTE FUNCTION prevent_delivery_events_modification();
```

Bypass note:
- Only the **table owner / database superuser / dedicated migration role** should be able to bypass this (e.g., during data migrations or legally required corrections). For operational admin users, keep the table append-only and store corrections as new `delivery_events` rows (e.g., `admin_note`) rather than edits.

### 2.16 `device_tokens`
Required for FCM push notifications.

Fields:
- `id` (uuid, pk)
- `user_id` (uuid, fk → `users.id`, not null)
- `platform` (text, not null) (`android`, `ios`, `web`)
Verify each finding against the current code and only fix it if needed.

In @docs/database_schema_postgresql.md around lines 85 - 430, The doc is missing explicit ON DELETE/ON UPDATE rules for FK relationships; update the schema docs to list cascade behavior for each FK (e.g., orders.customer_user_id and orders.assigned_driver_user_id → ON DELETE RESTRICT or note soft-delete via users.status='deleted'; order_items.order_id, payments.order_id, delivery_events.order_id → ON DELETE CASCADE; customer_profiles.default_address_id → ON DELETE SET NULL; driver_documents.driver_profile_id → ON DELETE CASCADE; addresses.user_id → ON DELETE CASCADE/RESTRICT as agreed), and state whether ON UPDATE CASCADE is used for uuid primary key changes; add a short rationale line per FK and a summary table of the chosen rules next to the existing field definitions (refer to specific columns like orders.id, order_items.order_id, payments.order_id, delivery_events.order_id, customer_profiles.default_address_id, driver_documents.driver_profile_id, addresses.user_id, users.id).- `token` (text, not null)
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
- only one active config per channel at a time (enforced via partial unique index)

Indexes:
- index: `(channel, is_active, effective_from desc)`
- unique partial index: `idx_pricing_configs_one_active_per_channel` on `(channel)` where `(is_active = true)`

Example PostgreSQL enforcement:

```sql
CREATE UNIQUE INDEX idx_pricing_configs_one_active_per_channel
ON pricing_configs (channel)
WHERE (is_active = true);
```

### 2.19 `operational_configs`
Simple dynamic configuration store for non-pricing policies (driver wait minutes, cancellation rules, etc.).

Fields:
- `id` (uuid, pk)
- `key` (text, unique, not null)
- `value` (jsonb, not null) (typed storage; store the native JSON type: number/bool/string/object)
- `updated_by_user_id` (uuid, fk → `users.id`, null)
- `updated_at` (timestamptz, not null)

Examples:
- `driver_wait_minutes = 30`
- `customer_can_cancel = false` (MVP)

Query note:
- Using `jsonb` enables safe typed reads and querying (e.g., `(value->>''driver_wait_minutes'')::int` if stored as an object, or direct casts if stored as a scalar).

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

