FROM python:3.10-slim
WORKDIR /app

# Install system dependencies, Node.js, and Yarn
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

#  Install Python dep s
COPY requirements.txt .
RUN pip install -r requirements.txt && pip install gunicorn

# Copy application codee
COPY . .
COPY statuspage/statuspage/configuration_example.py /app/statuspage/statuspage/configuration.py

# Build frontend assets
WORKDIR /app/statuspage/project-static
RUN yarn install && yarn bundle
# Verify frontend build produced output
RUN test -f dist/statuspage.js && test -f dist/statuspage.css \
    && echo "Frontend build verified." \
    || (echo "ERROR: Frontend build failed — dist/ is missing files" && exit 1)

# Back to app root
WORKDIR /app/statuspage

# Collect static files into the image at build time
RUN python manage.py collectstatic --no-input

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
