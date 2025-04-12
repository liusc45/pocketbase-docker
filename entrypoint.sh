#!/bin/sh
set -e

if [ ! -d "/pb/pb_data" ]; then
    echo "Initializing PocketBase with superuser..."
    /pb/pocketbase superuser create test@test.com Test123!
else
    echo "Database already exists, skipping superuser creation..."
fi

exec "$@"
