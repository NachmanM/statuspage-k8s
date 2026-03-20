#!/bin/bash
set -e

cd /app/statuspage

# Ensure media upload directory exists (may be a mounted volume)
mkdir -p media

echo "==> Running database migrations..."
python manage.py migrate --no-input

# Static files are already collected at image build time — skip at runtime

# Create superuser from env vars if set
if [ -n "$SUPERUSER_NAME" ] && [ -n "$SUPERUSER_PASSWORD" ]; then
    echo "==> Creating superuser (if not exists)..."
    python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='${SUPERUSER_NAME}').exists():
    User.objects.create_superuser('${SUPERUSER_NAME}', '${SUPERUSER_EMAIL:-admin@example.com}', '${SUPERUSER_PASSWORD}')
    print('Superuser created.')
else:
    print('Superuser already exists.')
"
fi

echo "==> Starting application..."
exec "$@"