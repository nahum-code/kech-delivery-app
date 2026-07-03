#!/bin/sh
set -e

# Named volumes (media, celerybeat, staticfiles) are created as root; the app
# runs as appuser, so fix ownership before collectstatic / uploads.
for dir in /app/media /app/celerybeat /app/staticfiles; do
  mkdir -p "$dir"
  chown -R appuser:appuser "$dir" 2>/dev/null || chmod -R a+rwX "$dir" 2>/dev/null || true
done

# Idempotent release tasks. Both default ON so a single-container deploy (e.g.
# Render) migrates + collects static out of the box. In compose these are split:
# a one-shot 'migrate' service runs migrations (+ admin bootstrap), the web
# service collects static, and workers/beat skip both (RUN_*=0) — so nothing is
# coupled to the web container and there is no concurrent-migration race.
run_release_tasks() {
  runner="$1"
  if [ "${RUN_MIGRATIONS:-1}" = "1" ]; then
    $runner python manage.py migrate --noinput
    $runner python manage.py createsuperuser --noinput || true
  fi
  if [ "${RUN_COLLECTSTATIC:-1}" = "1" ]; then
    $runner python manage.py collectstatic --noinput
  fi
}

if [ "$(id -u)" = "0" ]; then
  run_release_tasks "gosu appuser"
  exec gosu appuser "$@"
fi

run_release_tasks ""
exec "$@"
