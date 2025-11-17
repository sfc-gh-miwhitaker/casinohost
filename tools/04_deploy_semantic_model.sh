#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/04_deploy_semantic_model.sh [--skip-put] [--help]

Uploads the semantic model YAML to Snowflake stage and creates the Cortex Analyst instance.
  --skip-put   Skip PUT command (useful if file already staged)

Prerequisites:
  - Execute tools/03_deploy_ml.sh
  - snowsql authenticated with role SFE_CASINO_DEMO_ADMIN
USAGE
}

RUN_PUT=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --skip-put)
      RUN_PUT=false
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
SEMANTIC_FILE="${ROOT_DIR}/sql/05_semantic_model/casino_host_semantic_model.yaml"
SQL_SCRIPT="${ROOT_DIR}/sql/05_semantic_model/prepare_cortex_analyst.sql"
SNOWSQL_CMD="${SNOWSQL_CMD:-snowsql}"
SNOWSQL_CONN="${SNOWSQL_CONN:-}"

PUT_QUERY="PUT file://${SEMANTIC_FILE} @SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.SEMANTIC_MODELS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"

run_sql() {
  local file="$1"
  echo "🧩 Executing ${file}"
  if [[ -n "${SNOWSQL_CONN}" ]]; then
    "${SNOWSQL_CMD}" -c "${SNOWSQL_CONN}" -o exit_on_error=true -f "${file}"
  else
    "${SNOWSQL_CMD}" -o exit_on_error=true -f "${file}"
  fi
}

if [[ "${RUN_PUT}" == true ]]; then
  echo "⬆️  Uploading semantic model to stage"
  if [[ -n "${SNOWSQL_CONN}" ]]; then
    "${SNOWSQL_CMD}" -c "${SNOWSQL_CONN}" -q "${PUT_QUERY}"
  else
    "${SNOWSQL_CMD}" -q "${PUT_QUERY}"
  fi
fi

run_sql "${SQL_SCRIPT}"

echo "✅ Semantic model deployed and Cortex Analyst ready."

