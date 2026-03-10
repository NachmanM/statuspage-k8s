# Build stage: frontend assets
FROM node:20-alpine AS frontend-builder
WORKDIR /build/statuspage/project-static

COPY statuspage/project-static/package.json statuspage/project-static/yarn.lock* ./
RUN yarn install --frozen-lockfile 2>/dev/null || npm install

COPY statuspage/project-static/ .
RUN yarn bundle 2>/dev/null || npm run bundle

# Runtime stage: Django application
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

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
COPY statuspage/ ./statuspage/

# Copy built frontend assets from builder
COPY --from=frontend-builder /build/statuspage/project-static/dist ./statuspage/project-static/dist

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app/statuspage

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--threads", "2", "--timeout", "120", "--pythonpath", "/app/statuspage", "statuspage.wsgi:application"]
