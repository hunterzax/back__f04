#!/bin/sh
set -e

echo "[ENTRYPOINT] Setting up $NODE_ENV environment..."

# โหลด environment (หากจำเป็น)
if [ -f ./docker.env ]; then
  export $(grep -v '^#' ./docker.env | xargs)
fi

# fallback if not foud DATABASE_DIRECT_URL
if [ -z "$DATABASE_DIRECT_URL" ]; then
  echo "DATABASE_DIRECT_URL not set, fallback to DATABASE_URL"
  export DATABASE_DIRECT_URL=$DATABASE_URL
fi

# skip write database for dr
if [ "$NODE_ENV" = "dr" ]; then
  echo "DR mode → skip entrypoint logic"
  exec "$@"
fi

#Run Prisma migration deploy
echo "[ENTRYPOINT] Running Prisma Migrations..."
npx prisma migrate deploy

#Run temp seed import
echo "[ENTRYPOINT] Running temp seed import..."
node dist/prisma/seed-entrypoint.js

#Start the app
echo "[ENTRYPOINT] Starting application..."
exec "$@"
