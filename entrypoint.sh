#!/bin/sh

set -e

if [ ! -d "/app/pb_data" ]; then
    echo "[INFO] Initializing PocketBase with temporary superuser..."
    /app/pocketbase superuser create "test@test.com" "Test123!!!"
    echo "[SUCCESS] PocketBase temporary superuser created. Don't forget to change credentails!"
else
    echo "[INFO] pb_data already exists, skipping temporary superuser creation..."
fi

exec "$@"
