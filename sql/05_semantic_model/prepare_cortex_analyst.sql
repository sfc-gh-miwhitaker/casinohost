/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Deploy Cortex Analyst instance for host guidance
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create stage for semantic models, upload YAML, and instantiate Cortex Analyst.
 *
 * OBJECTS CREATED:
 *   - Stage ANALYTICS_LAYER.SEMANTIC_MODELS
 *   - Cortex Analyst casino_host_analyst
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE STAGE ANALYTICS_LAYER.SEMANTIC_MODELS
    COMMENT = 'DEMO: Casino host intelligence - semantic model definitions';

-- Upload semantic model file from local workstation (executed via SnowSQL/SnowSight worksheet).
-- Example:
--   PUT file://sql/05_semantic_model/casino_host_semantic_model.yaml
--       @SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.SEMANTIC_MODELS
--       AUTO_COMPRESS = FALSE OVERWRITE = TRUE;

CREATE OR REPLACE CORTEX ANALYST casino_host_analyst
  SEMANTIC_MODEL = '@ANALYTICS_LAYER.SEMANTIC_MODELS/casino_host_semantic_model.yaml'
  COMMENT = 'DEMO: Casino host intelligence assistant for comps and churn insights';

GRANT USAGE ON CORTEX ANALYST casino_host_analyst TO ROLE CASINO_HOST_ANALYST;

