#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/02_generate_data.sh [--help]

Populates RAW_INGESTION tables with synthetic casino data using Snowflake generator functions.

Prerequisites:
  - Run tools/01_setup.sh
  - snowsql authenticated with role SFE_CASINO_DEMO_ADMIN
  - Warehouse SFE_CASINO_HOST_WH resumed

Environment overrides:
  SNOWSQL_CMD   Path to snowsql executable (default: snowsql)
  SNOWSQL_CONN  Snowsql connection name (default: empty for default connection)
USAGE
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_DIR="${ROOT_DIR}/sql/02_data_generation"
SNOWSQL_CMD="${SNOWSQL_CMD:-snowsql}"
SNOWSQL_CONN="${SNOWSQL_CONN:-}"

run_sql() {
  local file="$1"
  echo "🧪 Generating data via ${file}"
  if [[ -n "${SNOWSQL_CONN}" ]]; then
    "${SNOWSQL_CMD}" -c "${SNOWSQL_CONN}" -o exit_on_error=true -f "${file}"
  else
    "${SNOWSQL_CMD}" -o exit_on_error=true -f "${file}"
  fi
}

run_sql "${SQL_DIR}/10_generate_players.sql"
run_sql "${SQL_DIR}/20_generate_games.sql"
run_sql "${SQL_DIR}/30_generate_gaming_sessions.sql"
run_sql "${SQL_DIR}/40_generate_transactions.sql"
run_sql "${SQL_DIR}/50_generate_comps.sql"

echo "✅ Synthetic data loaded."

