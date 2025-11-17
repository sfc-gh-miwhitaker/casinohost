@echo off
setlocal enabledelayedexpansion

if "%~1"=="--help" (
  echo Usage: tools\01_setup.bat [--help]
  echo.
  echo Creates Snowflake warehouse, database, schemas, and roles for the demo.
  echo Requires snowsql in PATH and ACCOUNTADMIN privileges.
  exit /b 0
)

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "SQL_DIR=%ROOT_DIR%\sql\01_setup"
set "SNOWSQL_CMD=%SNOWSQL_CMD%"
if "%SNOWSQL_CMD%"=="" set "SNOWSQL_CMD=snowsql"
set "SNOWSQL_CONN=%SNOWSQL_CONN%"

call :run_sql "%SQL_DIR%\01_create_core_objects.sql"
call :run_sql "%SQL_DIR%\02_create_raw_tables.sql"

echo ✅ Core Snowflake objects ready.
exit /b 0

:run_sql
set "FILE=%~1"
echo 📦 Executing %FILE%
if not "%SNOWSQL_CONN%"=="" (
  "%SNOWSQL_CMD%" -c "%SNOWSQL_CONN%" -o exit_on_error=true -f "%FILE%"
) else (
  "%SNOWSQL_CMD%" -o exit_on_error=true -f "%FILE%"
)
exit /b 0

