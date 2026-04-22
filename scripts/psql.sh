#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_FILE=""
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f)
      SQL_FILE="$2"
      shift 2
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ -n "$SQL_FILE" ]]; then
  if [[ ${#ARGS[@]} -gt 0 ]]; then
    docker compose -f "$ROOT_DIR/docker-compose.yml" exec -T postgres \
      psql -U postgres -d postgres "${ARGS[@]}" < "$SQL_FILE"
  else
    docker compose -f "$ROOT_DIR/docker-compose.yml" exec -T postgres \
      psql -U postgres -d postgres < "$SQL_FILE"
  fi
else
  if [[ ${#ARGS[@]} -gt 0 ]]; then
    docker compose -f "$ROOT_DIR/docker-compose.yml" exec -T postgres \
      psql -U postgres -d postgres "${ARGS[@]}"
  else
    docker compose -f "$ROOT_DIR/docker-compose.yml" exec -T postgres \
      psql -U postgres -d postgres
  fi
fi
