FROM python:3.10-slim

WORKDIR /app

# Install system deps for psycopg2 (runtime + build)
COPY requirements.txt .
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libpq-dev \
    gcc \
    && pip install --no-cache-dir -r requirements.txt whitenoise \
    && apt-get purge -y libpq-dev gcc \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . . 

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--threads", "2", "--timeout", "120", "--pythonpath", "/app/statuspage", "statuspage.wsgi:application"]
