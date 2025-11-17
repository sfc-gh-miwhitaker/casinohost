#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/01_setup.sh [--help]

Creates core Snowflake objects for the casino host intelligence demo:
  - Warehouse SFE_CASINO_HOST_WH (X-Small)
  - Database SNOWFLAKE_EXAMPLE with RAW/STAGING/ANALYTICS schemas
  - Roles SFE_CASINO_DEMO_ADMIN and CASINO_HOST_ANALYST with grants

Prerequisites:
  - snowsql installed and configured (default connection)
  - Role ACCOUNTADMIN or delegated admin role with equivalent privileges

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
SQL_DIR="${ROOT_DIR}/sql/01_setup"
SNOWSQL_CMD="${SNOWSQL_CMD:-snowsql}"
SNOWSQL_CONN="${SNOWSQL_CONN:-}"

run_sql() {
  local file="$1"
  echo "📦 Executing ${file}"
  if [[ -n "${SNOWSQL_CONN}" ]]; then
    "${SNOWSQL_CMD}" -c "${SNOWSQL_CONN}" -o exit_on_error=true -f "${file}"
  else
    "${SNOWSQL_CMD}" -o exit_on_error=true -f "${file}"
  fi
}

run_sql "${SQL_DIR}/01_create_core_objects.sql"
run_sql "${SQL_DIR}/02_create_raw_tables.sql"

echo "✅ Core Snowflake objects ready."

