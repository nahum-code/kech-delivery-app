# Frontend Migration Runbook (Dashboard -> Web/Admin + Web/Sales)

## Objective

Migrate generated Figma frontend code to separated applications while preserving a stable auth integration path to the Django backend.

## Safety Rules

- Keep migration in a dedicated feature branch.
- Commit in small slices (scaffold, import, wiring, cleanup).
- Do not delete `dashboard/` until both new apps pass lint/build and auth smoke tests.

## Required Env

For each app, create `.env.local` from `.env.local.example` and set:

- `NEXT_PUBLIC_API_URL=http://127.0.0.1:8000`

Backend CORS must allow frontend origins.

## Verification Gates

Run for each app (`web/admin`, `web/sales`):

```powershell
npm install
npm run lint
npm run build
```

Auth smoke tests per app:

1. Sign in with valid role account
2. Confirm `/dashboard` loads profile from `/api/v1/auth/me`
3. Refresh browser and confirm session refresh behavior
4. Logout and confirm redirect to `/login`
5. Attempt login with wrong role and confirm access denied

## Cutover

1. Merge branch after both apps pass gates.
2. Remove legacy `dashboard/` in a separate commit.
3. Update deployment pipeline to build/deploy `web/admin` and `web/sales`.
