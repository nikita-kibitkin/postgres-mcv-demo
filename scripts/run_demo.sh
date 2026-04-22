#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="$ROOT_DIR/results"
BEFORE_SQL="$ROOT_DIR/sql/1_explain_before.sql"
FIX_SQL="$ROOT_DIR/sql/2_fix.sql"
AFTER_SQL="$ROOT_DIR/sql/3_explain_after.sql"

if [[ $# -gt 0 ]]; then
  echo "usage: $0"
  exit 1
fi

mkdir -p "$RESULTS_DIR"

echo "[demo] benchmark without MCV"
"$ROOT_DIR/scripts/psql.sh" -f "$BEFORE_SQL" \
  | tee "$RESULTS_DIR/01_before_mcv.txt"

echo
echo "[demo] benchmark with MCV"
"$ROOT_DIR/scripts/psql.sh" -f "$FIX_SQL" >/dev/null
"$ROOT_DIR/scripts/psql.sh" -f "$AFTER_SQL" \
  | tee "$RESULTS_DIR/02_after_mcv.txt"

{
  echo "=== before MCV ==="
  grep -E "Nested Loop|Hash Join|rows=|actual time=|Execution Time" "$RESULTS_DIR/01_before_mcv.txt" || true
  echo
  echo "=== after MCV ==="
  grep -E "Nested Loop|Hash Join|rows=|actual time=|Execution Time" "$RESULTS_DIR/02_after_mcv.txt" || true
} | tee "$RESULTS_DIR/summary.txt"

echo
echo "[demo] raw plans:"
echo "  $RESULTS_DIR/01_before_mcv.txt"
echo "  $RESULTS_DIR/02_after_mcv.txt"
echo "  $RESULTS_DIR/summary.txt"
