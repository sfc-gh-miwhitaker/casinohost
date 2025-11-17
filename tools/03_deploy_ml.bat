@echo off
setlocal enabledelayedexpansion

set "RUN_STAGE=true"
set "RUN_MODELS=true"

if "%~1"=="--help" (
  echo Usage: tools\03_deploy_ml.bat [--stage-only] [--models] [--help]
  echo.
  echo Transforms staging/analytics layers and trains ML assets.
  exit /b 0
)

:parse_args
if "%~1"=="" goto args_done
if "%~1"=="--stage-only" (
  set "RUN_STAGE=true"
  set "RUN_MODELS=false"
) else if "%~1"=="--models" (
  set "RUN_STAGE=false"
  set "RUN_MODELS=true"
) else (
  echo Unknown argument: %~1
  exit /b 1
)
shift
goto parse_args
:args_done

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "TRANSFORM_DIR=%ROOT_DIR%\sql\03_transformations"
set "ML_DIR=%ROOT_DIR%\sql\04_ml_models"
set "SNOWSQL_CMD=%SNOWSQL_CMD%"
if "%SNOWSQL_CMD%"=="" set "SNOWSQL_CMD=snowsql"
set "SNOWSQL_CONN=%SNOWSQL_CONN%"

if /I "%RUN_STAGE%"=="true" (
  call :run_sql "%TRANSFORM_DIR%\10_stage_players.sql"
  call :run_sql "%TRANSFORM_DIR%\20_stage_games.sql"
  call :run_sql "%TRANSFORM_DIR%\30_stage_gaming_sessions.sql"
  call :run_sql "%TRANSFORM_DIR%\40_stage_transactions.sql"
  call :run_sql "%TRANSFORM_DIR%\50_stage_comps_history.sql"
  call :run_sql "%TRANSFORM_DIR%\60_dim_player.sql"
  call :run_sql "%TRANSFORM_DIR%\70_dim_game.sql"
  call :run_sql "%TRANSFORM_DIR%\80_fct_gaming_session.sql"
  call :run_sql "%TRANSFORM_DIR%\90_fct_transaction.sql"
  call :run_sql "%TRANSFORM_DIR%\95_agg_player_daily.sql"
  call :run_sql "%TRANSFORM_DIR%\96_agg_player_lifetime.sql"
)

if /I "%RUN_MODELS%"=="true" (
  call :run_sql "%ML_DIR%\10_player_features_view.sql"
  call :run_sql "%ML_DIR%\20_churn_model.sql"
  call :run_sql "%ML_DIR%\30_ltv_scoring_view.sql"
  call :run_sql "%ML_DIR%\40_recommendation_view.sql"
)

echo ✅ Transformations and ML assets deployed.
exit /b 0

:run_sql
set "FILE=%~1"
echo ⚙️  Executing %FILE%
if not "%SNOWSQL_CONN%"=="" (
  "%SNOWSQL_CMD%" -c "%SNOWSQL_CONN%" -o exit_on_error=true -f "%FILE%"
) else (
  "%SNOWSQL_CMD%" -o exit_on_error=true -f "%FILE%"
)
exit /b 0

