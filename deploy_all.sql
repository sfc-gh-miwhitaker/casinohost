/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence - Git-Integrated Deployment
 * 
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * USAGE IN SNOWSIGHT:
 *   1. Copy this ENTIRE script (all 250+ lines)
 *   2. Open Snowsight -> New Worksheet
 *   3. Paste the script
 *   4. Click "Run All" button (top right)
 *   5. Wait ~35 minutes for complete deployment
 * 
 * WHAT GETS DEPLOYED:
 *   - Core infrastructure (warehouse, database, schemas, roles)
 *   - Git integration for repository access
 *   - 50K synthetic player profiles
 *   - 2M gaming sessions
 *   - 10M transactions
 *   - 500K comp history records
 *   - Dimensional model (2 dimensions, 2 facts, 2 aggregates)
 *   - ML scoring views (churn, LTV, recommendations)
 *   - Cortex Analyst semantic model
 *
 * ESTIMATED RUNTIME: ~35 minutes on X-SMALL warehouse
 * ESTIMATED COST: ~$0.50 (35 min × $1/hour × 1 X-SMALL warehouse)
 *
 * PREREQUISITES:
 *   - Snowflake account with ACCOUNTADMIN privileges
 *   - Network access to GitHub (for git repository)
 *   - Public repository: https://github.com/sfc-gh-miwhitaker/casinohost
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql (drops all objects except SNOWFLAKE_EXAMPLE DB)
 ******************************************************************************/

-- ============================================================================
-- PHASE 1: CREATE CORE INFRASTRUCTURE (2 minutes)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create Git API Integration for public GitHub access
CREATE OR REPLACE API INTEGRATION SFE_CASINOHOST_GIT_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: Casino Host Intelligence - GitHub repository access';

-- Create demo warehouse (X-SMALL for cost efficiency)
CREATE OR REPLACE WAREHOUSE SFE_CASINO_HOST_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'DEMO: Casino Host Intelligence - Dedicated demo warehouse';

-- Create admin role for deployment
CREATE OR REPLACE ROLE SFE_CASINO_DEMO_ADMIN
    COMMENT = 'DEMO: Casino Host Intelligence - Admin role for deployment';

-- Create analyst role for Cortex Analyst usage
CREATE OR REPLACE ROLE CASINO_HOST_ANALYST
    COMMENT = 'DEMO: Casino Host Intelligence - Read-only role for hosts';

-- Grant warehouse usage to admin role
GRANT USAGE ON WAREHOUSE SFE_CASINO_HOST_WH TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT OPERATE ON WAREHOUSE SFE_CASINO_HOST_WH TO ROLE SFE_CASINO_DEMO_ADMIN;

-- Grant roles to ACCOUNTADMIN
GRANT ROLE SFE_CASINO_DEMO_ADMIN TO ROLE ACCOUNTADMIN;
GRANT ROLE CASINO_HOST_ANALYST TO ROLE ACCOUNTADMIN;

-- Create demo database
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION';

-- Grant database permissions
GRANT USAGE ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT CREATE SCHEMA ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE SFE_CASINO_DEMO_ADMIN;
GRANT USAGE ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE CASINO_HOST_ANALYST;

-- Create Git repository stage
USE ROLE SFE_CASINO_DEMO_ADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE SCHEMA IF NOT EXISTS GIT_REPOS
    COMMENT = 'DEMO: Git repository stages for code deployment';

CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO
    API_INTEGRATION = SFE_CASINOHOST_GIT_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/casinohost'
    COMMENT = 'DEMO: Casino Host Intelligence - Public repository for SQL scripts';

-- Create schemas for data layers
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.RAW_INGESTION
    COMMENT = 'DEMO: Raw data landing layer for synthetic casino data';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.STAGING_LAYER
    COMMENT = 'DEMO: Cleansed and standardized data layer';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER
    COMMENT = 'DEMO: Dimensional model for BI and ML consumption';

-- Grant schema permissions
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.RAW_INGESTION TO ROLE CASINO_HOST_ANALYST;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.STAGING_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER TO ROLE CASINO_HOST_ANALYST;

-- Set warehouse context for all subsequent operations
USE WAREHOUSE SFE_CASINO_HOST_WH;

SELECT 'Phase 1 Complete: Core infrastructure created' AS status;

-- ============================================================================
-- PHASE 2: CREATE RAW TABLES (1 minute)
-- ============================================================================

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/01_setup/02_create_raw_tables.sql;

SELECT 'Phase 2 Complete: Raw tables created' AS status;

-- ============================================================================
-- PHASE 3: GENERATE SYNTHETIC DATA (10 minutes)
-- ============================================================================

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/02_data_generation/10_generate_players.sql;
SELECT 'Generated 50K player profiles' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/02_data_generation/20_generate_games.sql;
SELECT 'Generated ~100 casino games' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/02_data_generation/30_generate_gaming_sessions.sql;
SELECT 'Generated 2M gaming sessions' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/02_data_generation/40_generate_transactions.sql;
SELECT 'Generated 10M transactions (this may take 8+ minutes)' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/02_data_generation/50_generate_comps.sql;
SELECT 'Generated 500K comp history records' AS status;

SELECT 'Phase 3 Complete: Synthetic data generated (22M+ rows)' AS status;

-- ============================================================================
-- PHASE 4: BUILD STAGING LAYER (5 minutes)
-- ============================================================================

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/10_stage_players.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/20_stage_games.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/30_stage_gaming_sessions.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/40_stage_transactions.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/50_stage_comps_history.sql;

SELECT 'Phase 4 Complete: Staging layer built' AS status;

-- ============================================================================
-- PHASE 5: BUILD ANALYTICS LAYER (8 minutes)
-- ============================================================================

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/60_dim_player.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/70_dim_game.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/80_fct_gaming_session.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/90_fct_transaction.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/95_agg_player_daily.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/03_transformations/96_agg_player_lifetime.sql;

SELECT 'Phase 5 Complete: Analytics layer built (dimensions, facts, aggregates)' AS status;

-- ============================================================================
-- PHASE 6: BUILD ML MODELS & SCORING VIEWS (8 minutes)
-- ============================================================================

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/04_ml_models/10_player_features_view.sql;
SELECT 'Created V_PLAYER_FEATURES view' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/04_ml_models/20_churn_model.sql;
SELECT 'Trained churn model and created V_PLAYER_CHURN_SCORES view' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/04_ml_models/30_ltv_scoring_view.sql;
SELECT 'Created V_PLAYER_LTV_SCORES view' AS status;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/04_ml_models/40_recommendation_view.sql;
SELECT 'Created V_PLAYER_RECOMMENDATIONS view' AS status;

SELECT 'Phase 6 Complete: ML models and scoring views ready' AS status;

-- ============================================================================
-- PHASE 7: DEPLOY CORTEX ANALYST (3 minutes)
-- ============================================================================

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO/branches/main/sql/05_semantic_model/prepare_cortex_analyst.sql;

SELECT 'Phase 7 Complete: Cortex Analyst deployed' AS status;

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================

SELECT '
╔════════════════════════════════════════════════════════════════════════════╗
║                     DEPLOYMENT COMPLETE                                     ║
╚════════════════════════════════════════════════════════════════════════════╝

✅ Infrastructure: Warehouse, database, schemas, roles created
✅ Synthetic Data: 50K players, 2M sessions, 10M transactions, 500K comps
✅ Dimensional Model: 2 dimensions, 2 facts, 2 aggregates
✅ ML Models: Churn classification model trained
✅ Scoring Views: Features, churn scores, LTV scores, recommendations
✅ Cortex Analyst: Semantic model deployed for natural language queries

NEXT STEPS:

1. Test Cortex Analyst:
   - Open Cortex Analyst in Snowsight
   - Try: "Which players should I offer comps to right now?"
   - Try: "Show me high-value players at risk of churning"

2. Query the analytics layer:
   SELECT player_id, player_name, loyalty_tier, churn_probability, suggested_action, suggested_comp_value_usd
   FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS 
   LIMIT 25;

3. Review demo scenarios:
   See docs/03-USAGE.md for complete demo script with 5 personas

4. Run validation queries:
   See docs/05-INDUSTRY-VALIDATION.md for industry benchmark validation queries

5. Cleanup when done:
   Run sql/99_cleanup/teardown_all.sql to remove all demo objects

ESTIMATED COST: ~$0.50 for this deployment
TOTAL RUNTIME: ~35 minutes

For questions or issues, see docs/04-ARCHITECTURE.md
' AS deployment_summary;

-- Show final object counts
SELECT 'Final Object Inventory:' AS summary;
SELECT COUNT(*) AS player_count FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.DIM_PLAYER;
SELECT COUNT(*) AS session_count FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.FCT_GAMING_SESSION;
SELECT COUNT(*) AS transaction_count FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.FCT_TRANSACTION;
SELECT COUNT(*) AS high_risk_players FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES WHERE churn_risk_segment = 'High Risk';
SELECT COUNT(*) AS recommendations FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS WHERE suggested_comp_value_usd > 0;

/*******************************************************************************
 * TROUBLESHOOTING
 ******************************************************************************/

-- If deployment fails:

-- 1. Check Git repository access:
--    SHOW GIT REPOSITORIES IN DATABASE SNOWFLAKE_EXAMPLE;
--    If missing, verify API integration and repository ORIGIN URL

-- 2. Check warehouse status:
--    SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH';
--    If suspended, it will auto-resume on next query

-- 3. Check role permissions:
--    SHOW GRANTS TO ROLE SFE_CASINO_DEMO_ADMIN;
--    Must have USAGE on warehouse, CREATE SCHEMA on database

-- 4. Check for partial deployment:
--    SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.RAW_INGESTION;
--    SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER;
--    If tables exist, you can resume from a specific EXECUTE IMMEDIATE command

-- 5. Full cleanup and retry:
--    Run sql/99_cleanup/teardown_all.sql then re-run this script

-- 6. Repository not accessible:
--    Verify GitHub repository is public: https://github.com/sfc-gh-miwhitaker/casinohost
--    Verify network access to github.com from your Snowflake account

-- 7. Cortex Analyst errors:
--    Verify Cortex AI is enabled in your Snowflake account
--    Check that semantic model YAML file exists in repository

-- For detailed architecture, see diagrams/data-model.md

