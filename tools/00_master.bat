@echo off
REM ===========================================================================
REM Master Orchestration Script - Casino Host Intelligence Demo (Windows)
REM
REM Purpose: Single entry point for all deployment, validation, and cleanup ops
REM Usage:   tools\00_master.bat [command] [options]
REM
REM Commands:
REM   deploy    - Full deployment (setup + data + ML + semantic model)
REM   validate  - Run validation checks
REM   cleanup   - Remove all demo objects
REM   help      - Show this help message
REM
REM Examples:
REM   tools\00_master.bat deploy
REM   tools\00_master.bat validate
REM   tools\00_master.bat cleanup
REM ===========================================================================

setlocal enabledelayedexpansion

set "COMMAND=%1"

REM Default to help if no command
if "%COMMAND%"=="" set "COMMAND=help"

REM Execute command
if /i "%COMMAND%"=="deploy" goto :cmd_deploy
if /i "%COMMAND%"=="validate" goto :cmd_validate
if /i "%COMMAND%"=="cleanup" goto :cmd_cleanup
if /i "%COMMAND%"=="help" goto :cmd_help

echo ERROR: Unknown command: %COMMAND%
goto :cmd_help

REM ===========================================================================
REM Deploy Command
REM ===========================================================================
:cmd_deploy
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  Casino Host Intelligence - Full Deployment                    ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo This script is a helper. Primary deployment method:
echo   ^→ Copy deploy_all.sql to Snowsight and click 'Run All'
echo.
echo If you have Snow CLI configured, scripts can run individually:
echo.

where snow >nul 2>&1
if errorlevel 1 (
    echo ERROR: Snow CLI not found. Use Snowsight deployment method.
    echo See QUICKSTART.md for instructions
    exit /b 1
)

echo Running sequential deployment via Snow CLI...
echo.

echo [1/5] Infrastructure Setup
call tools\01_setup.bat
if errorlevel 1 goto :error

echo [2/5] Synthetic Data Generation
call tools\02_generate_data.bat
if errorlevel 1 goto :error

echo [3/5] ML Models ^& Scoring
call tools\03_deploy_ml.bat
if errorlevel 1 goto :error

echo [4/5] Cortex Analyst Deployment
call tools\04_deploy_semantic_model.bat
if errorlevel 1 goto :error

echo [5/5] Validation
call tools\05_validate.bat
if errorlevel 1 goto :error

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  Deployment Complete                                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ✓ All components deployed successfully
echo.
echo Next steps:
echo   1. Test Cortex Analyst in Snowsight
echo   2. Query: 'Which players should I offer comps to right now?'
echo   3. See docs\03-USAGE.md for demo scenarios
echo.
echo Estimated cost: ~$0.50
echo Time elapsed: ~35 minutes
goto :end

REM ===========================================================================
REM Validate Command
REM ===========================================================================
:cmd_validate
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  Running Validation Checks                                     ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

where snow >nul 2>&1
if errorlevel 1 (
    echo ERROR: Snow CLI not found
    echo Validation requires Snow CLI for automated checks
    echo.
    echo Manual validation:
    echo   Run queries from docs\05-INDUSTRY-VALIDATION.md in Snowsight
    exit /b 1
)

call tools\05_validate.bat
if errorlevel 1 (
    echo ERROR: Some validation checks failed
    echo Review output above for details
    exit /b 1
)

echo ✓ All validation checks passed
goto :end

REM ===========================================================================
REM Cleanup Command
REM ===========================================================================
:cmd_cleanup
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  Cleanup - Remove All Demo Objects                            ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ⚠ This will remove ALL casino host demo objects:
echo   • Schemas: RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER
echo   • Warehouse: SFE_CASINO_HOST_WH
echo   • Roles: SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST
echo   • Cortex Analyst: casino_host_analyst
echo.
echo Preserved:
echo   • SNOWFLAKE_EXAMPLE database (empty shell)
echo   • GIT_REPOS schema (shared infrastructure)
echo.

set /p "confirmation=Continue with cleanup? (yes/no): "
if /i not "%confirmation%"=="yes" (
    echo ⚠ Cleanup cancelled
    exit /b 0
)

echo.
echo Running cleanup script...

where snow >nul 2>&1
if errorlevel 1 (
    echo ⚠ Snow CLI not found
    echo.
    echo Manual cleanup:
    echo   1. Open sql\99_cleanup\teardown_all.sql
    echo   2. Copy entire script
    echo   3. Paste into Snowsight
    echo   4. Click 'Run All'
    echo.
    echo See docs\06-CLEANUP.md for details
    exit /b 1
)

snow sql -f sql\99_cleanup\teardown_all.sql
if errorlevel 1 goto :error

echo ✓ Cleanup complete
echo All demo objects removed
goto :end

REM ===========================================================================
REM Help Command
REM ===========================================================================
:cmd_help
echo.
echo Casino Host Intelligence - Master Orchestration Script
echo.
echo USAGE:
echo     tools\00_master.bat [COMMAND]
echo.
echo COMMANDS:
echo     deploy      Full deployment (setup + data + ML + semantic model)
echo     validate    Run validation checks
echo     cleanup     Remove all demo objects
echo     help        Show this help message
echo.
echo EXAMPLES:
echo     # Full deployment
echo     tools\00_master.bat deploy
echo.
echo     # Validate existing deployment
echo     tools\00_master.bat validate
echo.
echo     # Cleanup
echo     tools\00_master.bat cleanup
echo.
echo RECOMMENDED DEPLOYMENT METHOD:
echo     For fastest deployment, use Snowsight (100%% native):
echo.
echo     1. Open deploy_all.sql (project root)
echo     2. Copy entire script
echo     3. Paste into Snowsight worksheet
echo     4. Click "Run All"
echo     5. Wait ~35 minutes
echo.
echo     See QUICKSTART.md for detailed instructions.
echo.
echo DOCUMENTATION:
echo     QUICKSTART.md                - 5-minute quick start
echo     docs\01-SETUP.md             - Prerequisites
echo     docs\02-DEPLOYMENT.md        - Detailed deployment guide
echo     docs\03-USAGE.md             - Demo scenarios
echo     docs\04-ARCHITECTURE.md      - Technical deep dive
echo     docs\05-INDUSTRY-VALIDATION.md - Validation queries
echo     docs\06-CLEANUP.md           - Cleanup instructions
echo     docs\07-COST-ESTIMATION.md   - Cost breakdown
echo.
goto :end

REM ===========================================================================
REM Error Handler
REM ===========================================================================
:error
echo.
echo ✗ ERROR: Command failed
echo.
echo Troubleshooting:
echo   1. Check Snow CLI connection: snow connection test
echo   2. Verify ACCOUNTADMIN privileges
echo   3. Review error messages above
echo   4. See docs\02-DEPLOYMENT.md for detailed guidance
echo.
exit /b 1

REM ===========================================================================
REM Exit
REM ===========================================================================
:end
exit /b 0

