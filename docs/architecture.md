# System Architecture (Day 2)

This document defines the **high-level platform architecture** for the Kech Delivery App MVP, based on the MVP scope in `README.md`.

## Architecture Layers (MVP)

- **Mobile App (Flutter)**: Shared binary with role selection at login (Customer / Driver)
- **Web Dashboards (Next.js)**: Admin dashboard + Sales dashboard
- **Backend API (Django + DRF)**: Single backend deployment, organized as Django apps (not microservices)
- **Database (PostgreSQL)**: Primary system of record

## External Services (MVP)

- **Google Maps API**: geocoding + distance computation for delivery pricing and routing context
- **Chapa Payment Gateway**: online payment checkout + webhook verification
- **Firebase Cloud Messaging (FCM)**: push notifications
- **Firebase Storage**: store uploaded media (restaurant images, menu images, driver documents)

## High-Level Architecture Diagram

```mermaid
flowchart TB
  subgraph clientApps [Client_Apps]
    Mobile[CustomerDriverMobileApp_Flutter]
    WebDash[AdminSalesDashboard_Nextjs]
  end

  subgraph backend [Backend]
    API[Django_DRF_API]
    Channels[DjangoChannels_Realtime]
    Worker[Celery_Workers]
    Broker[Redis_BrokerCache]
    DB[(PostgreSQL)]
  end

  subgraph external [External_Services]
    Maps[GoogleMapsAPI]
    Chapa[ChapaPayments]
    FCM[FirebaseCloudMessaging]
    Storage[FirebaseStorage]
  end

  Mobile -->|HTTPS_REST_JWT| API
  WebDash -->|HTTPS_REST_JWT| API

  API --> DB
  API --> Broker
  Channels --> Broker
  Worker --> Broker
  Worker --> DB

  API -->|Geocoding_Distance| Maps
  API -->|Checkout_Init| Chapa
  Chapa -->|Webhook_Callback| API

  API -->|SendPush| FCM
  API -->|Upload_ReadMedia| Storage
```

## Communication Patterns

- **Mobile/Web → Backend**: HTTPS REST API (DRF) using JWT auth.
- **Backend async**: Celery tasks via Redis (notifications, webhook post-processing, rollups).
- **Realtime (Phase 2+)**: Django Channels via Redis for live updates. For MVP, keep realtime optional; rely on polling + push.

## Core Data Ownership (PostgreSQL)

- Users and role claims
- Driver verification status + documents metadata
- Restaurants, menus, availability, opening hours
- Orders, order items (snapshots), delivery events
- Payments ledger + webhook logs
- Operational configs (pricing, wait time, cancellation rules)
- Analytics rollups (simple aggregates)

## Security Boundaries

- Enforce **role-based access** at DRF layer (not only UI).
- Verify **Chapa webhooks** server-side before marking payments confirmed.
- Use backend-controlled uploads or signed URLs for Firebase Storage.

