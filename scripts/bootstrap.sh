#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROWS="${1:-2000000}"

docker compose -f "$ROOT_DIR/docker-compose.yml" up -d postgres >/dev/null

echo "[bootstrap] waiting for postgres healthcheck"
until docker compose -f "$ROOT_DIR/docker-compose.yml" exec -T postgres \
  pg_isready -U postgres -d postgres >/dev/null 2>&1; do
  sleep 1
done

echo "[bootstrap] loading schema and synthetic data (${ROWS} rows)"
"$ROOT_DIR/scripts/psql.sh" -v demo_rows="$ROWS" -f "$ROOT_DIR/sql/bootstrap.sql"

echo "[bootstrap] verifying distribution"
"$ROOT_DIR/scripts/psql.sh" -f "$ROOT_DIR/sql/check_distribution.sql"
