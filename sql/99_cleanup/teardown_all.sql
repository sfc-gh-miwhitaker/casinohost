/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Teardown all demo objects
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Remove demo schemas, tables, ML models, and compute resources created by the
 *   casino host intelligence reference implementation while leaving the
 *   SNOWFLAKE_EXAMPLE database in place.
 *
 * OBJECTS REMOVED:
 *   - Cortex Analyst casino_host_analyst
 *   - Stage ANALYTICS_LAYER.SEMANTIC_MODELS
 *   - Schemas RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER
 *   - Warehouse SFE_CASINO_HOST_WH
 *   - Roles SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST (optional)
 *
 * CLEANUP:
 *   Run `sql/99_cleanup/validate_cleanup.sql` to confirm removal.
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- Drop Cortex Analyst and semantic stage
DROP CORTEX ANALYST IF EXISTS casino_host_analyst;

-- Switch to demo admin to clean schemas gracefully
USE ROLE SFE_CASINO_DEMO_ADMIN;

DROP STAGE IF EXISTS SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.SEMANTIC_MODELS;

-- Drop analytics objects
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.STAGING_LAYER CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.RAW_INGESTION CASCADE;

-- Optional: keep database shell for future demos
USE ROLE ACCOUNTADMIN;

-- Drop warehouse
DROP WAREHOUSE IF EXISTS SFE_CASINO_HOST_WH;

-- Optionally drop roles (comment out to reuse)
REVOKE ROLE SFE_CASINO_DEMO_ADMIN FROM ROLE ACCOUNTADMIN;
REVOKE ROLE CASINO_HOST_ANALYST FROM ROLE ACCOUNTADMIN;
DROP ROLE IF EXISTS CASINO_HOST_ANALYST;
DROP ROLE IF EXISTS SFE_CASINO_DEMO_ADMIN;

-- Leave SNOWFLAKE_EXAMPLE database intact for audit
ALTER DATABASE SNOWFLAKE_EXAMPLE SET DEFAULT_DDL_COLLATION='en-ci';

-- Switch back to ACCOUNTADMIN for confirmation
USE ROLE ACCOUNTADMIN;

