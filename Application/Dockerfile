FROM python:3.10-slim

WORKDIR /app

# Install system deps + Node.js for frontend build
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application code
COPY . .
COPY statuspage/statuspage/configuration_example.py /app/statuspage/statuspage/configuration.py

# Build frontend assets
WORKDIR /app/statuspage/project-static
RUN yarn install && yarn bundle

# Back to app root
WORKDIR /app/statuspage

# Create media dir and collect static files into the image at build time
RUN mkdir -p media && python manage.py collectstatic --no-input

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
