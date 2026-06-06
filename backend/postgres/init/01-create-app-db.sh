#!/bin/sh
# Runs once, on first initialization of the Postgres data directory.
#
# LiteLLM manages its own tables with Prisma and will `db push` against its
# database — dropping any table it doesn't own. So the FastAPI app gets its own
# database (Alembic-managed) to keep the two migration systems fully isolated.
set -e

APP_DB="${APP_DB:-splitt_app}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE "$APP_DB";
EOSQL

echo "Created application database: $APP_DB (owner: $POSTGRES_USER)"
