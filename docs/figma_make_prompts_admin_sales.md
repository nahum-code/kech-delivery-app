# Kech Delivery — Figma Make Prompts (Admin + Sales)

Use the following prompts directly in Figma Make.

---

## Prompt 1 — Admin Dashboard UI (Kech Delivery)

Design a **professional web admin dashboard UI** for a delivery company called **Kech Delivery**.

### Context
- Product type: Operations and management dashboard for food delivery operations.
- Primary users: **Admin / Operations Manager**.
- Brand: Use **Burgundy** as the primary color across key actions, highlights, and chart accents.
- Logo: Include a top-left logo slot named **“Kech Delivery”** (I will attach the logo).
- Tone: Clean, data-rich, modern B2B SaaS style, with high readability and clear action hierarchy.
- Platform: Desktop-first web app with responsive behavior down to tablet width.

### Information architecture
Create a left sidebar + top header layout with these menu items (exactly):
1. Dashboard
2. Orders Monitor
3. Driver Approval
4. Restaurant Management
5. Menu Management
6. Analytics

### Global UI requirements
- Include: search, filters, status chips, table sorting, pagination, date range picker, and export button where relevant.
- Include component states: empty, loading/skeleton, and error.
- Use role-appropriate microcopy and operational wording.
- Use clear status colors while keeping Burgundy as the primary brand color.
- Accessibility: good contrast, keyboard-focus visibility, clear labels, and minimum tap/click targets.

### Domain language and statuses (use exactly)
- Order statuses: **Draft, PaymentPending, PaymentFailed, PaymentConfirmed, SearchingDriver, Assigned, Accepted, PickedUp, Delivered, Completed, Cancelled**.
- Driver onboarding statuses: **Registered, DocsSubmitted, UnderReview, Approved, Rejected, Suspended**.
- Financial labels: **Delivery Fee, Driver Payout, Platform Fee**.

### Screen requirements

#### 1) Dashboard
Create an executive overview page with:
- KPI cards: total orders (today), active deliveries, unassigned orders, completion rate, cancellation rate, total platform fee.
- Trend chart: orders over time.
- Donut or stacked chart: orders by status.
- “Needs Attention” panel: stuck SearchingDriver orders, rejected driver docs, inactive restaurants.
- Recent activity feed (order/driver/restaurant events).

#### 2) Orders Monitor
Design a control-room style screen:
- Main table columns: order number, customer, restaurant, assigned driver, status, payment state, created time, distance, fees.
- Filters: status, payment state, city/zone, date/time, assigned/unassigned.
- Row quick actions: view details, assign/reassign driver, cancel order (admin action), contact driver/customer.
- Right-side details drawer: order timeline with status history + pricing breakdown (delivery fee, driver payout, platform fee) + pickup/dropoff summary.

#### 3) Driver Approval
Design a moderation workflow:
- Queue tabs by status (DocsSubmitted, UnderReview, Approved, Rejected, Suspended).
- Driver card/table with: full name, phone, vehicle type, submitted date, current status, online flag.
- Driver profile panel with document previews (license/ID placeholders), notes field, and decision buttons.
- Actions: Approve, Reject (with required reason), Suspend, Reactivate.

#### 4) Restaurant Management
Design CRUD management screen:
- Table/list columns: restaurant name, phone, location, opening hours, status, menu count, last updated.
- Actions: add restaurant, edit, activate/deactivate, view menus.
- Restaurant detail/edit form sections: basic info, contact, location map pin, schedule, operational status.

#### 5) Menu Management
Design category + item administration:
- Two-pane layout: left categories, right menu items.
- Category controls: create/edit/reorder/activate.
- Item table/cards with: name, category, price, availability, image thumbnail.
- Item editor: name, description, price, availability toggle, image uploader placeholder.

#### 6) Analytics
Design an operations + financial analytics page:
- Date range and quick presets.
- Metrics: order volume, assignment time, delivery time, completion/cancellation, platform fee totals, payout totals.
- Charts: trend lines, status distribution, top restaurants by volume/revenue.
- Summary table export block.

### Interaction guidance
- Prioritize fast operational decision-making and reduced click depth.
- Keep important alert states visible (especially SearchingDriver delays).
- Use consistent drawer/modal patterns and confirmation dialogs for destructive actions.

### MVP boundary (important)
- Keep scope to MVP admin needs only.
- Do **not** introduce phase-2/phase-3 concepts such as advanced live map playback, automated payout workflows, or highly complex forecasting modules.

### Deliverables expected from Figma Make
Produce:
1. High-fidelity desktop screens for all 6 admin pages.
2. Reusable component set (buttons, chips, table rows, KPI cards, filters, form controls).
3. Variants for key statuses and state screens (loading/empty/error).
4. Basic responsive adaptation guidance (desktop to tablet).

---

## Prompt 2 — Sales Dashboard UI (Kech Delivery)

Design a **professional web sales operations dashboard UI** for **Kech Delivery** focused on order intake and dispatch support.

### Context
- Product type: Sales agent web dashboard for creating and managing orders.
- Primary users: **Sales Agent**.
- Brand: **Burgundy** primary color; keep visual style consistent with Admin but simplified for faster workflows.
- Logo: include top-left **Kech Delivery** logo placeholder (I will attach logo).
- Goal: speed + clarity for call-center style order handling.
- Platform: Desktop-first web app with tablet responsiveness.

### Information architecture
Create a left sidebar + top header layout with these menu items (exactly):
1. Create Order
2. Assign Driver
3. Monitor Orders

### Scope boundaries
- Sales can: create order, monitor order, assign/reassign driver before pickup, and perform policy-limited edits/cancellation.
- Sales cannot: manage restaurants globally, approve drivers, edit system pricing rules, or access full admin governance pages.

### Domain language and statuses (use exactly)
- Order statuses: **Draft, PaymentPending, PaymentFailed, PaymentConfirmed, SearchingDriver, Assigned, Accepted, PickedUp, Delivered, Completed, Cancelled**.
- Driver assignment eligibility hints: **Approved, Online, Not Busy, Within Radius**.
- Financial labels: **Delivery Fee, Driver Payout, Platform Fee**.

### Screen requirements

#### 1) Create Order
Design a step-based order creation workflow optimized for speed:
- Step A: customer lookup by phone (and create customer if not found).
- Step B: pickup source (restaurant) + dropoff address with map pin placeholder + address text.
- Step C: item selection from menu (quantity controls, notes/instructions, unavailable item state).
- Step D: pricing summary with fee breakdown (delivery fee, driver payout, platform fee) and channel context for sales-created orders.
- Step E: payment status handling (pending/confirmed/failed) and final submit.

Include field-level validation patterns:
- required fields,
- invalid phone/address,
- restaurant closed,
- unavailable menu items,
- clear inline error messages.

#### 2) Assign Driver
Design a driver assignment workspace:
- Left panel: unassigned / needs-assignment orders with urgency indicators.
- Right panel: eligible driver list with filters (distance, vehicle type, online status, rating).
- Driver row data: name, distance to restaurant, current availability, recent completion stats.
- Actions: assign, reassign (only before pickup), and release to self-accept pool.
- Show reason tags for ineligible drivers (busy, offline, out of radius, suspended).

#### 3) Monitor Orders
Design a live operations monitor for sales-owned workflows:
- Main table columns: order number, customer, restaurant, driver, status, payment state, created at, ETA.
- Filters: status, payment state, assigned/unassigned, time window.
- Row actions: open details, assign/reassign driver, policy-limited cancel/edit.
- Order details drawer: status timeline, event log, fee summary, and contact shortcuts.
- Highlight cards at top: active orders, searching driver count, delayed orders, completed today.

### Interaction guidance
- Prioritize minimal steps and rapid processing for phone-based order entry.
- Keep high-risk states prominent: payment failed, long SearchingDriver time, reassignment needed.
- Use consistent quick-action patterns from list rows and detail drawers.

### MVP boundary (important)
- Keep this strictly to MVP sales operations.
- Do **not** add advanced future capabilities (full real-time map command center, complex commission engines, or predictive dispatch AI).

### Deliverables expected from Figma Make
Produce:
1. High-fidelity desktop screens for all 3 sales pages.
2. Reusable components aligned with admin design language.
3. Form and table states (loading, empty, validation error, success).
4. Responsive adaptation guidance (desktop to tablet).

---

## Optional note to include in Figma Make input
"Use realistic Ethiopian urban delivery context labels and practical operations copy. Keep layouts production-ready for handoff to Next.js dashboard implementation."

---

## Prompt 3 — Customer Mobile UI (Kech Delivery)

Design a **professional, modern mobile customer app UI** for **Kech Delivery** (Kech means **on-time** in Amharic), focused on fast ordering, clear status visibility, and trust.

### Context
- Platform: mobile-first app screens (Android and iOS friendly), portrait layout.
- User role: **Customer**.
- Brand: use **Burgundy** as the primary color for CTAs, active states, and key highlights.
- Tone: simple, warm, dependable, and efficient; clean spacing and high readability.
- Logo: I will attach the logo image later; for now create a clean logo placeholder area labeled **Kech Delivery** and generate complementary icon/shape concepts in Figma Make (time/on-time motion cues, route path, location-pin motifs).

### UX and design principles
- Keep flows short and predictable; reduce cognitive load.
- Use clear visual hierarchy and one primary action per screen.
- Include proper accessibility (contrast, readable typography, touch targets, visible focus).
- Include loading, empty, offline, and error states across major screens.

### Domain rules and logic (must be reflected in UI)
- Customer flow: register/login -> profile/address -> browse restaurants -> menu/cart -> checkout -> delivery fee estimate -> Chapa payment -> order tracking timeline -> order history.
- Customers **cannot cancel after placement** in MVP; show policy message clearly.
- Restaurant closed/inactive should block ordering with clear feedback.
- Unavailable items must be visibly disabled with explanation.
- Payment success is confirmed by backend/webhook; after return from payment show pending confirmation state until confirmed.
- Order status vocabulary to display in timeline (exact values): **Placed, PaymentPending, PaymentFailed, PaymentConfirmed, SearchingDriver, Assigned, Accepted, PickedUp, Delivered, Completed, Cancelled**.
- MVP note: no advanced live map playback; use timeline + periodic updates + in-app notifications style.

### Information architecture and required screens (complete)

#### 0) App launch and onboarding
1. Splash screen (brand + subtle motion).
2. Intro/onboarding carousel (3–4 slides): on-time delivery promise, live order updates, easy payment.
3. Role entry selector screen: **Continue as Customer** / **Continue as Driver** (Customer path selected here).

#### 1) Authentication and account setup
4. Customer Login screen (phone/email + password, forgot password, sign up CTA).
5. Customer Registration screen.
6. OTP/verification screen (if applicable).
7. Complete profile screen (name, phone, email).

#### 2) Address setup and home discovery
8. Address permission + map pin intro.
9. Add address screen (label, address text, map pin preview, save).
10. Saved addresses list (Home/Work/custom, default selector, edit/delete).
11. Home/Discovery screen:
	- greeting + current delivery address
	- search bar
	- category chips
	- restaurant list cards (open/closed badges, ETA, fee hint)
	- promotional banner slot

#### 3) Restaurant and menu browsing
12. Restaurant results/search screen with filters/sort.
13. Restaurant detail screen:
	- cover image, name, status (open/closed), delivery info
	- menu categories tabs
	- menu item cards with image, price, availability
14. Item detail bottom sheet/page:
	- item info, quantity stepper, special instructions, add to cart
	- unavailable state variant

#### 4) Cart and checkout
15. Cart screen:
	- selected items, quantity controls, note per item
	- pricing summary (items subtotal + estimated delivery fee)
	- change address action
16. Checkout screen:
	- delivery address confirmation
	- order note field
	- fee breakdown labels: **Delivery Fee, Driver Payout, Platform Fee**
	- payment method (Chapa)
	- place order CTA
17. Payment redirect/loading screen (opening Chapa).
18. Post-payment return state:
	- **PaymentPending** waiting screen with polling behavior and clear message
	- **PaymentFailed** retry/change action state
	- **PaymentConfirmed** success confirmation state

#### 5) Order tracking and lifecycle
19. Active order tracking screen:
	- status timeline component with all order stages
	- order number, restaurant, dropoff address summary
	- key event feed (driver assigned, picked up, delivered)
	- in-app notification entry points
20. Searching driver state emphasis screen variant (when **SearchingDriver** takes longer).
21. Delivered/completed success screen with receipt summary.
22. Cancelled state screen (admin-cancelled messaging + reason placeholder).

#### 6) History and profile
23. Order history list screen (filter by status/date).
24. Order history detail screen (items snapshot, fee breakdown, timeline summary).
25. Profile and account settings screen.
26. Notification center screen (in-app updates).
27. Help/support placeholder screen (simple MVP contact/help entry).

### Required components and states
- Bottom navigation for customer mode: Home, Orders, Notifications, Profile.
- Reusable components: app bars, address selector, restaurant cards, menu cards, chips, steppers, timeline, banners, status pills, toasts, modal confirmations.
- State coverage: loading skeletons, empty orders, no internet, payment error, restaurant closed, item unavailable.

### Animation and motion requirements (professional + simple)
- Onboarding: soft horizontal card transitions and subtle illustration parallax.
- Home: gentle content fade/slide-in for cards on first load.
- Cart interactions: quantity change micro-animation and add-to-cart confirmation pulse.
- Payment and order states: progress/transition animation between PaymentPending -> PaymentConfirmed.
- Tracking timeline: smooth step activation animation as status advances.
- Notification badge and success states: restrained micro-interactions (no flashy effects).
- Motion rules: 150–300ms for micro-interactions, consistent easing, no motion overload.

### Deliverables expected from Figma Make
1. High-fidelity complete customer flow from onboarding/login to order completion/history.
2. Mobile design system components + variants.
3. State screens (loading/empty/error/offline/policy restrictions).
4. Annotated interaction/motion notes for handoff.  

---

## Prompt 4 — Driver Mobile UI (Kech Delivery)

Design a **professional, operationally clear mobile driver app UI** for **Kech Delivery** (Kech = on-time), optimized for fast acceptance, reliable execution, and low-distraction delivery workflow.

### Context
- Platform: mobile-first app screens (Android and iOS friendly), portrait layout.
- User role: **Driver**.
- Brand: use **Burgundy (bergendi)** as primary color for key actions and active status indicators.
- Tone: focused, practical, confident; task-first interface with strong legibility.
- Logo: I will attach logo image later; keep logo placeholder and generate matching icon/shape concepts in Figma Make aligned to punctuality, route direction, and trust.

### UX and design principles
- Prioritize speed: accept, navigate context, update status in minimal taps.
- Keep critical information persistent: pickup/dropoff summaries, status, timers.
- Use clear warning feedback for high-risk states (order cancelled, customer unreachable, reassignment).
- Include accessibility, large touch targets, and one primary action per state.

### Domain rules and logic (must be reflected in UI)
- Driver lifecycle: register -> upload documents -> pending review -> approved/rejected/suspended handling.
- Driver approval statuses (exact): **Registered, DocsSubmitted, UnderReview, Approved, Rejected, Suspended**.
- Delivery execution statuses shown/updated by driver: **Accepted -> PickedUp -> Delivered**.
- Driver can go online/offline only after approval.
- Driver request eligibility context should visually communicate: Approved, Online, Not Busy, Within Radius.
- If another driver accepts first, show "order already taken" outcome.
- Order can be cancelled/reassigned before pickup; show clear interruption screens.
- Edge workflows must exist: customer unreachable report, failed delivery/report issue, assignment cancelled.
- MVP note: no advanced live route playback; keep simple map context + task timeline.

### Information architecture and required screens (complete)

#### 0) App launch and onboarding
1. Splash screen (brand + subtle motion).
2. Driver onboarding carousel (3–4 slides): earn by delivering, flexible online/offline, real-time request alerts.
3. Role entry selector screen: **Continue as Driver** / **Continue as Customer** (Driver path selected here).

#### 1) Authentication and onboarding/verification
4. Driver Login screen (phone/email + password, forgot password, sign up).
5. Driver Registration screen.
6. OTP/verification screen (if applicable).
7. Driver profile setup screen (name, phone, vehicle type).
8. Document upload hub:
	- required document cards (ID, license, profile photo placeholders)
	- upload progress states
	- submit documents CTA
9. Review status screens:
	- **DocsSubmitted/UnderReview** waiting state
	- **Rejected** state with reason + resubmit flow
	- **Suspended** blocked state with support CTA
	- **Approved** success state leading to driver home

#### 2) Driver home and availability
10. Driver home dashboard:
	- online/offline toggle (primary control)
	- today summary (completed deliveries, current task status)
	- current assignment card or waiting state
11. Offline empty state screen (prompt to go online).

#### 3) Delivery request intake
12. Incoming request card/full-screen sheet:
	- order id, pickup and dropoff summaries, distance hint, payout highlight
	- countdown timer and actions: Accept / Decline
13. Request conflict state (another driver accepted first -> "Order already taken").
14. Request queue list screen (if multiple offers appear sequentially).

#### 4) Active delivery workflow
15. Accepted order detail screen:
	- customer name/contact shortcut, pickup info, dropoff info, key notes
	- status CTA: **Mark as PickedUp**
16. Picked-up in-progress screen:
	- delivery info and final step CTA: **Mark as Delivered**
17. Delivered confirmation screen (summary + next order CTA).
18. Active task timeline screen variant (Accepted -> PickedUp -> Delivered visual progression).

#### 5) Exceptions and interruptions
19. Order cancelled/assignment cancelled screen (clear stop-work guidance).
20. Reassignment notice screen (new assignment details or back to queue).
21. Customer unreachable report flow:
	- quick action button
	- wait-time policy message (up to 30 minutes)
	- submit report event state
22. Report issue / failed delivery placeholder flow (MVP simple reporting form).

#### 6) History and profile
23. Delivery history list screen (date/status grouping).
24. Delivery history detail screen (status timestamps, payout summary, addresses).
25. Driver profile/settings screen.
26. Notification center screen (new request, assignment updates, admin decisions).

### Required components and states
- Driver-mode bottom navigation: Home, Tasks/History, Notifications, Profile.
- Reusable components: online toggle, request cards, urgency badges, countdown timer, status timeline, action sheets, confirmation dialogs, alert banners.
- State coverage: loading, empty queue, offline/no internet, upload failure, approval blocked, assignment interrupted.

### Animation and motion requirements (professional + simple)
- Onboarding: smooth page transitions with restrained icon motion.
- Availability toggle: immediate animated state feedback (online/offline).
- Incoming request: subtle attention animation (pulse/slide) that remains readable and non-distracting.
- Status transitions: clear motion between **Accepted -> PickedUp -> Delivered** to reinforce progression.
- Completion feedback: calm success confirmation animation.
- Motion rules: 150–300ms micro-interactions, consistent easing, avoid heavy effects during high-focus tasks.

### Deliverables expected from Figma Make
1. High-fidelity complete driver flow from onboarding/login through delivery completion and history.
2. Driver-focused reusable component set and status variants.
3. Edge-case states (rejected/suspended/cancelled/unreachable/offline/errors).
4. Annotated interaction/motion notes for implementation handoff.

---

## Typography Tokens (Ready to Paste into Figma Make)

Use this typography system for **Customer Mobile UI** and **Driver Mobile UI**. Keep the style professional, simple, and highly readable.

### Global typography standards
- Use a clean sans-serif family with strong Ethiopic + Latin support.
- Font weights used in UI: **Regular 400**, **Medium 500**, **SemiBold 600**.
- Body minimum for core readable content: **14px**.
- Use **12px only for non-critical metadata** (timestamps, helper text, badges).
- Line-height ratio:
	- Headings: ~1.25x
	- Body text: 1.4x to 1.5x
- Keep letter spacing neutral (0 to 0.2) for mobile readability.

### Shared mobile type scale (base tokens)
1. **Display / Hero** — 32 / 40, SemiBold
2. **Screen Title** — 24 / 32, SemiBold
3. **Section Title** — 20 / 28, SemiBold
4. **Card Title / Emphasis** — 18 / 24, Medium
5. **Body Primary** — 16 / 24, Regular
6. **Body Secondary** — 14 / 20, Regular
7. **Caption / Meta** — 12 / 16, Regular
8. **Button Label (Default)** — 16 / 20, Medium
9. **Chip / Tab Label** — 14 / 18, Medium
10. **Bottom Nav Label** — 12 / 16, Medium

### Customer UI typography usage
- Primary reading content (restaurant details, menu descriptions, checkout details): **Body Primary 16/24**.
- Supporting content (address subtitle, delivery hints, status helper text): **Body Secondary 14/20**.
- Restaurant/item names and key card titles: **Card Title 18/24**.
- Main screen headings: **Screen Title 24/32**.
- CTA buttons (Add to Cart, Place Order, Retry Payment): **Button Label 16/20, Medium**.
- Small metadata only (time, order id snippet, tiny notes): **Caption 12/16**.

### Driver UI typography usage (operational emphasis)
- Keep base scale, but increase critical action clarity:
	- **Primary action labels** (Accept, Mark as PickedUp, Mark as Delivered): **17 / 22, SemiBold**.
	- **Task status headers** (Accepted, PickedUp, Delivered): **20 / 28, SemiBold**.
	- **Key operational values** (ETA, payout, distance): **18 / 24, SemiBold**.
- Standard task detail text remains: **Body Primary 16/24**.
- Secondary operational notes (pickup/dropoff subtext, helper copy): **Body Secondary 14/20**.
- Non-critical labels/timestamps: **Caption 12/16**.

### Accessibility and consistency rules
- Maintain WCAG-friendly contrast on all text sizes; avoid low-contrast burgundy text on tinted backgrounds.
- Never use all-caps for long labels; use sentence/title case for legibility.
- Limit a single screen to 3–4 text levels to reduce visual noise.
- Ensure tap-target context: larger type for high-frequency actions and time-sensitive decisions.

### Figma token naming (recommended)
- `type.display`
- `type.title.screen`
- `type.title.section`
- `type.title.card`
- `type.body.primary`
- `type.body.secondary`
- `type.caption`
- `type.button.default`
- `type.button.driverPrimary`
- `type.nav.label`
