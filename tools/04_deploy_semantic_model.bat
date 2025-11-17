@echo off
setlocal enabledelayedexpansion

set "RUN_PUT=true"

if "%~1"=="--help" (
  echo Usage: tools\04_deploy_semantic_model.bat [--skip-put] [--help]
  echo.
  echo Uploads semantic model YAML and creates Cortex Analyst instance.
  exit /b 0
)

:parse
if "%~1"=="" goto args_done
if "%~1"=="--skip-put" (
  set "RUN_PUT=false"
) else (
  echo Unknown argument: %~1
  exit /b 1
)
shift
goto parse
:args_done

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "SEMANTIC_FILE=%ROOT_DIR%\sql\05_semantic_model\casino_host_semantic_model.yaml"
set "SQL_SCRIPT=%ROOT_DIR%\sql\05_semantic_model\prepare_cortex_analyst.sql"
set "SNOWSQL_CMD=%SNOWSQL_CMD%"
if "%SNOWSQL_CMD%"=="" set "SNOWSQL_CMD=snowsql"
set "SNOWSQL_CONN=%SNOWSQL_CONN%"

if /I "%RUN_PUT%"=="true" (
  echo ⬆️  Uploading semantic model to stage
  if not "%SNOWSQL_CONN%"=="" (
    "%SNOWSQL_CMD%" -c "%SNOWSQL_CONN%" -q "PUT file://%SEMANTIC_FILE% @SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.SEMANTIC_MODELS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
  ) else (
    "%SNOWSQL_CMD%" -q "PUT file://%SEMANTIC_FILE% @SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.SEMANTIC_MODELS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
  )
)

echo 🧩 Executing %SQL_SCRIPT%
if not "%SNOWSQL_CONN%"=="" (
  "%SNOWSQL_CMD%" -c "%SNOWSQL_CONN%" -o exit_on_error=true -f "%SQL_SCRIPT%"
) else (
  "%SNOWSQL_CMD%" -o exit_on_error=true -f "%SQL_SCRIPT%"
)

echo ✅ Semantic model deployed and Cortex Analyst ready.
exit /b 0

