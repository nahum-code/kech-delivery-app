FROM python:3.14-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
	&& pip install --no-cache-dir -r requirements.txt
RUN groupadd --system appuser \
	&& useradd --system --gid appuser --create-home appuser \
	&& chown -R appuser:appuser /app
COPY . /app
USER appuser
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]