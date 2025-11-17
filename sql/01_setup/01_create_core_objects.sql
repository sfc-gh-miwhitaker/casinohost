/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Create core database objects (warehouse, database, schemas, roles)
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Provision foundational Snowflake objects required for the demo environment.
 *
 * OBJECTS CREATED:
 *   - SFE_CASINO_HOST_WH (Warehouse)
 *   - SNOWFLAKE_EXAMPLE (Database, if not already present)
 *   - Schemas: RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER
 *   - Roles: SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

-- Warehouse dedicated to the casino host demo (X-Small for cost efficiency)
CREATE OR REPLACE WAREHOUSE SFE_CASINO_HOST_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE
       COMMENT = 'DEMO: Casino host intelligence - dedicated compute for demo workloads';

-- Demo database reserved for examples. Preserves existing content if present.
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
  COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION';

-- Core schemas following layered architecture pattern.
CREATE OR REPLACE SCHEMA SNOWFLAKE_EXAMPLE.RAW_INGESTION
  COMMENT = 'DEMO: Casino host intelligence - raw synthetic data landing zone';

CREATE OR REPLACE SCHEMA SNOWFLAKE_EXAMPLE.STAGING_LAYER
  COMMENT = 'DEMO: Casino host intelligence - cleaned and conformed staging layer';

CREATE OR REPLACE SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER
  COMMENT = 'DEMO: Casino host intelligence - dimensional analytics and semantic layer';

-- Roles for separation of duties.
CREATE OR REPLACE ROLE SFE_CASINO_DEMO_ADMIN COMMENT = 'DEMO: Casino host intelligence - deployment role';
CREATE OR REPLACE ROLE CASINO_HOST_ANALYST COMMENT = 'DEMO: Casino host intelligence - host consumption role';

-- Minimal grant structure aligning with demo responsibilities.
GRANT USAGE ON WAREHOUSE SFE_CASINO_HOST_WH TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT USAGE ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT USAGE ON ALL SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT ALL PRIVILEGES ON FUTURE FUNCTIONS IN DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;

GRANT USAGE ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE CASINO_HOST_ANALYST;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;

