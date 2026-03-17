FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install -r requirements.txt && pip install gunicorn

# Copy application code
COPY . .
COPY statuspage/statuspage/configuration_example.py /app/statuspage/statuspage/configuration.py
# Build frontend assets
WORKDIR /app/statuspage/project-static
RUN yarn install && yarn bundle

# Back to app root
WORKDIR /app/statuspage

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
