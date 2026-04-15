# Web Frontends (Admin + Sales)

This folder contains two independent Next.js applications:

- `web/admin`
- `web/sales`

Each app is production-structured as:

- `src/app` (App Router routes)
- `src/components` (shared layout/UI wrappers)
- `src/features` (Figma pages + UI components, feature-scoped)
- `src/hooks` (auth guards)
- `src/lib` (token storage + public API facade)
- `src/services` (HTTP/auth service layer)
- `src/styles` (theme/tailwind imports)

Both apps integrate with backend auth endpoints:

- `POST /api/v1/auth/token/`
- `POST /api/v1/auth/token/refresh/`
- `POST /api/v1/auth/logout`
- `GET /api/v1/auth/me`

## Local Run

Admin:

```powershell
cd web/admin
npm install
Copy-Item .env.local.example .env.local
npm run dev
```

Sales:

```powershell
cd web/sales
npm install
Copy-Item .env.local.example .env.local
npm run dev
```

## Auth and Role Separation

- Admin app allows only `role=admin`
- Sales app allows only `role=sales`
- Protected routes are guarded in `src/app/(protected)/layout.tsx` per app.
