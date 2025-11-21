# Auth Flow - Casino Host Intelligence
Author: Michael Whitaker  
Last Updated: 2025-11-21  
Status: Reference Impl  
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)  
Reference Impl: This code demonstrates prod-grade architectural patterns and best practice. review and customize security, networking, logic for your organization's specific requirements before deployment.

## Overview
Authentication and authorization steps for Git-integrated deployment via Snowsight and accessing host insights via Cortex Analyst, including role hierarchy, Git repository access, and resource grants.

```mermaid
sequenceDiagram
    actor User as User (ACCOUNTADMIN)
    participant Snowsight as Snowsight UI
    participant GitHub as GitHub Repository
    participant Snowflake as Snowflake Control Plane
    participant GitStage as Git Repository Stage
    participant Warehouse as SFE_CASINO_HOST_WH
    participant DB as SNOWFLAKE_EXAMPLE Schemas
    actor Host as Casino Host (CASINO_HOST_ANALYST)
    participant Analyst as Cortex Analyst

    Note over User,Snowflake: Phase 1: Git-Integrated Deployment
    User->>Snowsight: Login via SSO/OAuth (ACCOUNTADMIN)
    User->>Snowsight: Copy/paste deploy_all.sql
    User->>Snowsight: Click "Run All"
    
    Snowsight->>Snowflake: CREATE API INTEGRATION (Git HTTPS access)
    Snowsight->>Snowflake: CREATE WAREHOUSE SFE_CASINO_HOST_WH
    Snowsight->>Snowflake: CREATE ROLES (SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST)
    Snowsight->>Snowflake: GRANT privileges on warehouse, DB, schemas
    
    Snowsight->>GitHub: CREATE GIT REPOSITORY with ORIGIN URL
    GitHub-->>GitStage: Mount as @GIT_REPOS.CASINOHOST_REPO stage
    
    Note over Snowsight,DB: Phase 2: Execute All Scripts from Git
    Snowsight->>GitStage: EXECUTE IMMEDIATE FROM @stage/sql/02_data_generation/*.sql
    GitStage->>Warehouse: Run 50K players, 2M sessions, 10M transactions
    Warehouse-->>DB: Persist to RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER
    
    Snowsight->>GitStage: EXECUTE IMMEDIATE FROM @stage/sql/04_ml_models/*.sql
    GitStage->>Warehouse: Train churn model, create scoring views
    Warehouse-->>DB: Persist ML models and views
    
    Snowsight->>GitStage: EXECUTE IMMEDIATE FROM @stage/sql/05_semantic_model/*.sql
    GitStage->>Analyst: CREATE CORTEX ANALYST casino_host_analyst
    GitStage->>Analyst: GRANT USAGE TO ROLE CASINO_HOST_ANALYST

    Note over Host,DB: Phase 3: Host Usage
    Host->>Snowsight: Login via SSO/OAuth (CASINO_HOST_ANALYST)
    Snowflake->>Host: Issue session token for CASINO_HOST_ANALYST
    Host->>Analyst: Natural language query ("Who needs a comp?")
    Analyst->>DB: Execute verified query with CASINO_HOST_ANALYST privileges
    DB-->>Analyst: Return recommendations & metrics
    Analyst-->>Host: Response with actionable guidance
```

## Component Descriptions

### Deployment Components
- **User (ACCOUNTADMIN)**  
  - Purpose: Deploy demo via Snowsight using `deploy_all.sql`  
  - Technology: Snowflake RBAC, SSO/OAuth or key-pair authentication  
  - Location: `ACCOUNTADMIN` context during deployment  
  - Deps: Master Snowflake account access, network access to GitHub

- **Snowsight UI**  
  - Purpose: Primary deployment interface for copy/paste workflow  
  - Technology: Snowflake web interface (HTTPS 443)  
  - Location: Browser-based, `<account>.snowflakecomputing.com`  
  - Workflow: Copy entire `deploy_all.sql` → Paste → Click "Run All"

- **GitHub Repository**  
  - Purpose: Host all SQL scripts for Git-integrated deployment  
  - Technology: Public GitHub repository  
  - Location: `https://github.com/sfc-gh-miwhitaker/casinohost`  
  - Access: Public, no authentication required

- **Git Repository Stage**  
  - Purpose: Mount GitHub repo as Snowflake stage for `EXECUTE IMMEDIATE FROM`  
  - Technology: Snowflake Git Repository object with API Integration  
  - Location: `@SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO`  
  - Pattern: `@stage/branches/main/sql/<directory>/<script>.sql`

- SFE_CASINO_DEMO_ADMIN Role  
  - Purpose: Deploy demo schemas, data, ML models, and analyst configuration  
  - Technology: Snowflake RBAC role  
  - Location: `SFE_CASINO_DEMO_ADMIN`  
  - Deps: Grants on warehouse, database, Cortex Analyst

- CASINO_HOST_ANALYST Role  
  - Purpose: Provide read-only access to analytics layer and Cortex Analyst usage  
  - Technology: Snowflake RBAC role  
  - Location: `CASINO_HOST_ANALYST`  
  - Deps: SELECT on analytics views, USAGE on analyst instance

- Cortex Analyst `casino_host_analyst`  
  - Purpose: Enforce semantic model and execute verified queries with host role  
  - Technology: Snowflake Cortex Analyst  
  - Location: Snowflake managed service  
  - Deps: Semantic model stage, analytics views, role grants

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

