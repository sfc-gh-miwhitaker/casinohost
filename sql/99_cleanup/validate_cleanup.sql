/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Validate demo cleanup
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Confirm all demo objects were removed after teardown_all.sql execution.
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- 1. Check schemas (expect zero rows)
SELECT schema_name
FROM SNOWFLAKE.INFORMATION_SCHEMA.SCHEMATA
WHERE catalog_name = 'SNOWFLAKE_EXAMPLE'
  AND schema_name IN ('RAW_INGESTION','STAGING_LAYER','ANALYTICS_LAYER');

-- 2. Check warehouse (expect "No warehouses" message)
SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH';

-- 3. Check roles (expect zero rows)
SHOW ROLES LIKE 'SFE_CASINO_DEMO_ADMIN';
SHOW ROLES LIKE 'CASINO_HOST_ANALYST';

-- 4. Check stage (expect zero rows or object does not exist)
SHOW STAGES LIKE 'SEMANTIC_MODELS' IN DATABASE SNOWFLAKE_EXAMPLE;

