#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/03_deploy_ml.sh [--stage-only] [--models] [--help]

Transforms staging/analytics layers and trains ML models.
  --stage-only   Run staging + analytics scripts only
  --models       Run ML feature + model scripts only
  (no flags)     Run both stages sequentially

Prerequisites:
  - Execute tools/02_generate_data.sh
  - snowsql authenticated with role SFE_CASINO_DEMO_ADMIN
  - Warehouse SFE_CASINO_HOST_WH resumed
USAGE
}

RUN_STAGE=true
RUN_MODELS=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --stage-only)
      RUN_STAGE=true
      RUN_MODELS=false
      shift
      ;;
    --models)
      RUN_STAGE=false
      RUN_MODELS=true
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
TRANSFORM_DIR="${ROOT_DIR}/sql/03_transformations"
ML_DIR="${ROOT_DIR}/sql/04_ml_models"
SNOWSQL_CMD="${SNOWSQL_CMD:-snowsql}"
SNOWSQL_CONN="${SNOWSQL_CONN:-}"

run_sql() {
  local file="$1"
  echo "⚙️  Executing ${file}"
  if [[ -n "${SNOWSQL_CONN}" ]]; then
    "${SNOWSQL_CMD}" -c "${SNOWSQL_CONN}" -o exit_on_error=true -f "${file}"
  else
    "${SNOWSQL_CMD}" -o exit_on_error=true -f "${file}"
  fi
}

if [[ "${RUN_STAGE}" == true ]]; then
  run_sql "${TRANSFORM_DIR}/10_stage_players.sql"
  run_sql "${TRANSFORM_DIR}/20_stage_games.sql"
  run_sql "${TRANSFORM_DIR}/30_stage_gaming_sessions.sql"
  run_sql "${TRANSFORM_DIR}/40_stage_transactions.sql"
  run_sql "${TRANSFORM_DIR}/50_stage_comps_history.sql"
  run_sql "${TRANSFORM_DIR}/60_dim_player.sql"
  run_sql "${TRANSFORM_DIR}/70_dim_game.sql"
  run_sql "${TRANSFORM_DIR}/80_fct_gaming_session.sql"
  run_sql "${TRANSFORM_DIR}/90_fct_transaction.sql"
  run_sql "${TRANSFORM_DIR}/95_agg_player_daily.sql"
  run_sql "${TRANSFORM_DIR}/96_agg_player_lifetime.sql"
fi

if [[ "${RUN_MODELS}" == true ]]; then
  run_sql "${ML_DIR}/10_player_features_view.sql"
  run_sql "${ML_DIR}/20_churn_model.sql"
  run_sql "${ML_DIR}/30_ltv_scoring_view.sql"
  run_sql "${ML_DIR}/40_recommendation_view.sql"
fi

echo "✅ Transformations and ML assets deployed."

