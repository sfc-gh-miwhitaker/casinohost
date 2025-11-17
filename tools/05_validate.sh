#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/05_validate.sh [--skip-cleanup-check] [--help]

Runs end-to-end validation:
  1. Executes setup, data generation, transformations, and semantic deployment
  2. Runs pytest integration suite
  3. Optionally verifies teardown script (without dropping objects)

Prerequisites:
  - snowsql authenticated with role SFE_CASINO_DEMO_ADMIN
  - Python virtualenv with requirements installed
USAGE
}

RUN_CLEANUP_CHECK=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --skip-cleanup-check)
      RUN_CLEANUP_CHECK=false
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Running full deployment pipeline..."

"${ROOT_DIR}/tools/01_setup.sh"
"${ROOT_DIR}/tools/02_generate_data.sh"
"${ROOT_DIR}/tools/03_deploy_ml.sh"
"${ROOT_DIR}/tools/04_deploy_semantic_model.sh"

echo "🧪 Executing pytest integration suite..."
pytest "${ROOT_DIR}/python/tests"

if [[ "${RUN_CLEANUP_CHECK}" == true ]]; then
  echo "🔍 Validating teardown readiness..."
  SNOWSQL_CMD="${SNOWSQL_CMD:-snowsql}"
  SNOWSQL_CONN="${SNOWSQL_CONN:-}"
  VALIDATION_SQL="${ROOT_DIR}/sql/99_cleanup/validate_cleanup.sql"
  if [[ -n "${SNOWSQL_CONN}" ]]; then
    "${SNOWSQL_CMD}" -c "${SNOWSQL_CONN}" -o exit_on_error=true -f "${VALIDATION_SQL}"
  else
    "${SNOWSQL_CMD}" -o exit_on_error=true -f "${VALIDATION_SQL}"
  fi
fi

echo "✅ End-to-end validation complete."

