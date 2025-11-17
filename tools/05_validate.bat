@echo off
setlocal enabledelayedexpansion

set "RUN_CLEANUP_CHECK=true"

if "%~1"=="--help" (
  echo Usage: tools\05_validate.bat [--skip-cleanup-check] [--help]
  echo.
  echo Runs complete deployment pipeline, pytest suite, and optional cleanup validation.
  exit /b 0
)

:parse
if "%~1"=="" goto args_done
if "%~1"=="--skip-cleanup-check" (
  set "RUN_CLEANUP_CHECK=false"
) else (
  echo Unknown argument: %~1
  exit /b 1
)
shift
goto parse
:args_done

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "SNOWSQL_CMD=%SNOWSQL_CMD%"
if "%SNOWSQL_CMD%"=="" set "SNOWSQL_CMD=snowsql"
set "SNOWSQL_CONN=%SNOWSQL_CONN%"

echo 🚀 Running full deployment pipeline...
call "%ROOT_DIR%\tools\01_setup.bat"
call "%ROOT_DIR%\tools\02_generate_data.bat"
call "%ROOT_DIR%\tools\03_deploy_ml.bat"
call "%ROOT_DIR%\tools\04_deploy_semantic_model.bat"

echo 🧪 Executing pytest integration suite...
pytest "%ROOT_DIR%\python\tests"

if /I "%RUN_CLEANUP_CHECK%"=="true" (
  echo 🔍 Validating teardown readiness...
  set "VALIDATION_SQL=%ROOT_DIR%\sql\99_cleanup\validate_cleanup.sql"
  if not "%SNOWSQL_CONN%"=="" (
    "%SNOWSQL_CMD%" -c "%SNOWSQL_CONN%" -o exit_on_error=true -f "%VALIDATION_SQL%"
  ) else (
    "%SNOWSQL_CMD%" -o exit_on_error=true -f "%VALIDATION_SQL%"
  )
)

echo ✅ End-to-end validation complete.
exit /b 0

