# Local Development Setup (Windows)

This guide gets the project running on a fresh Windows machine.

## 1) Install required tools

- Docker Desktop (with WSL2 backend enabled)
- Git for Windows
- VS Code
- Node.js 22 LTS (for `dashboard/`)
- Flutter SDK (for `mobile/`, optional if you only work on backend/dashboard)

Verify installs in PowerShell:

```powershell
docker --version
docker compose version
git --version
node --version
npm --version
flutter --version
```

## 2) Clone and open repo

```powershell
git clone <your-repo-url>
cd kech-delivery-app
```

## 3) Configure backend environment

Create a backend env file from the template (from the repo root, `kech-delivery-app`):

```powershell
Copy-Item .\.env.example .\backend\.env
```

If needed, edit `backend/.env` and update secrets/passwords.

### Python virtual environment (optional — host-side `manage.py`)

If you run Django on Windows outside Docker (not required if you only use `docker compose exec web`):

```powershell
cd backend
py -m venv .venv
```

Activate the venv:

```powershell
.\.venv\Scripts\Activate.ps1
```

**If PowerShell reports “running scripts is disabled”** for `Activate.ps1`, use one of:

1. **Process scope (recommended; applies only to the current window):**  
   `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`  
   then run `.\.venv\Scripts\Activate.ps1` again.

2. **Command Prompt:** open `cmd.exe`, `cd` to `backend`, run `.\.venv\Scripts\activate.bat`.

3. **Skip activation:** call the interpreter directly (no script policy on `python.exe`):  
   `.\.venv\Scripts\python.exe -m pip install -r requirements.txt`  
   `.\.venv\Scripts\python.exe manage.py migrate`

## 4) Start backend stack in Docker

```powershell
cd backend
docker compose --env-file .env up --build -d
docker compose ps
```

Run migrations and create an admin user:

```powershell
docker compose --env-file .env exec web python manage.py migrate
docker compose --env-file .env exec web python manage.py createsuperuser
```

**Host vs Docker `DATABASE_URL`:** If you run `python manage.py migrate` **on Windows** (outside the container), a URL like `...@db:5432/...` will fail with `failed to resolve host 'db'` because `db` only exists on Docker’s network. Use one of:

1. **Recommended:** always run migrations inside the `web` container (commands above).
2. **Host-side Django:** point Postgres at the published port from `docker-compose.yml` (this repo maps **`5433:5432`**), e.g. `postgresql://USER:PASSWORD@127.0.0.1:5433/kech_delivery`. Do not use hostname `db` on the host.

Useful URLs:

- API: http://localhost:8000
- Django admin: http://localhost:8000/admin

Useful logs:

```powershell
docker compose --env-file .env logs -f web
docker compose --env-file .env logs -f worker
docker compose --env-file .env logs -f beat
```

Stop stack:

```powershell
docker compose --env-file .env down
```

## 5) Run dashboard (Next.js)

In a new terminal:

```powershell
cd dashboard
npm install
npm run dev
```

Dashboard URL: http://localhost:3000

## 6) Run mobile app (Flutter, optional)

```powershell
cd mobile
flutter pub get
flutter run
```

## 7) First-day troubleshooting

- Docker not starting: ensure Docker Desktop is running and WSL2 is enabled.
- Port conflict (`8000` or `5433`): free the port or change mappings in `backend/docker-compose.yml`.
- DB auth errors: verify `POSTGRES_*` and `DB_*` values match in `backend/.env`.
- Missing migrations state: run `docker compose --env-file .env exec web python manage.py migrate`.