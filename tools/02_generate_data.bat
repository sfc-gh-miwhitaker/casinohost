@echo off
setlocal enabledelayedexpansion

if "%~1"=="--help" (
  echo Usage: tools\02_generate_data.bat [--help]
  echo.
  echo Populates RAW_INGESTION tables with synthetic data.
  echo Requires snowsql authenticated as SFE_CASINO_DEMO_ADMIN.
  exit /b 0
)

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "SQL_DIR=%ROOT_DIR%\sql\02_data_generation"
set "SNOWSQL_CMD=%SNOWSQL_CMD%"
if "%SNOWSQL_CMD%"=="" set "SNOWSQL_CMD=snowsql"
set "SNOWSQL_CONN=%SNOWSQL_CONN%"

call :run_sql "%SQL_DIR%\10_generate_players.sql"
call :run_sql "%SQL_DIR%\20_generate_games.sql"
call :run_sql "%SQL_DIR%\30_generate_gaming_sessions.sql"
call :run_sql "%SQL_DIR%\40_generate_transactions.sql"
call :run_sql "%SQL_DIR%\50_generate_comps.sql"

echo ✅ Synthetic data loaded.
exit /b 0

:run_sql
set "FILE=%~1"
echo 🧪 Generating data via %FILE%
if not "%SNOWSQL_CONN%"=="" (
  "%SNOWSQL_CMD%" -c "%SNOWSQL_CONN%" -o exit_on_error=true -f "%FILE%"
) else (
  "%SNOWSQL_CMD%" -o exit_on_error=true -f "%FILE%"
)
exit /b 0

