FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app

# Pillow (ImageField) needs JPEG/zlib; gosu drops root after fixing volume permissions.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends libjpeg62-turbo-dev zlib1g-dev gosu \
	&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
	&& pip install --no-cache-dir -r requirements.txt

RUN groupadd --system appuser \
	&& useradd --system --gid appuser --create-home appuser

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh \
	&& chmod +x /docker-entrypoint.sh \
	&& chown -R appuser:appuser /app

COPY . /app
RUN chown -R appuser:appuser /app

# Entrypoint runs as root to chown mounted volumes, then gosu → appuser.
USER root
ENTRYPOINT ["/docker-entrypoint.sh"]
# Production WSGI server. Worker count follows WEB_CONCURRENCY (Render sets it to
# 1 on the free tier); the VPS compose overrides this command with more workers.
CMD ["sh", "-c", "gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8000} --workers ${WEB_CONCURRENCY:-3} --timeout 120"]
