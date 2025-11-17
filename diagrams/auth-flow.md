# Auth Flow - Casino Host Intelligence
Author: Michael Whitaker  
Last Updated: 2025-11-17  
Status: Reference Impl  
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)  
Reference Impl: This code demonstrates prod-grade architectural patterns and best practice. review and customize security, networking, logic for your organization's specific requirements before deployment.

## Overview
Authentication and authorization steps for deploying the demo and accessing host insights via Cortex Analyst, including role hierarchy and resource grants.

```mermaid
sequenceDiagram
    actor Dev as Developer (ACCOUNTADMIN)
    participant Snowflake as Snowflake Control Plane
    participant Warehouse as SFE_CASINO_HOST_WH
    actor Host as Casino Host (CASINO_HOST_ANALYST)
    participant Analyst as Cortex Analyst
    participant DB as SNOWFLAKE_EXAMPLE Schemas

    Dev->>Snowflake: Login with key pair (ACCOUNTADMIN)
    Dev->>Snowflake: CREATE ROLE SFE_CASINO_DEMO_ADMIN
    Dev->>Snowflake: GRANT privileges on DB, schemas, warehouse
    Dev->>Snowflake: ASSIGN ROLE SFE_CASINO_DEMO_ADMIN TO <deployment user>
    Dev->>Snowflake: CREATE ROLE CASINO_HOST_ANALYST
    Dev->>Snowflake: GRANT USAGE SELECT on ANALYTICS_LAYER

    Dev->>Snowflake: Use Role SFE_CASINO_DEMO_ADMIN
    Dev->>Warehouse: Run data generation & transforms
    Warehouse-->>DB: Persist tables and views

    Dev->>Snowflake: Upload semantic model to stage
    Dev->>Analyst: CREATE CORTEX ANALYST casino_host_analyst
    Dev->>Analyst: GRANT USAGE TO ROLE CASINO_HOST_ANALYST

    Host->>Snowflake: Login via Snowsight (SSO/OAuth)
    Snowflake->>Host: Issue session token for CASINO_HOST_ANALYST
    Host->>Analyst: Natural language query ("Who needs a comp?")
    Analyst->>DB: Execute verified query with CASINO_HOST_ANALYST privileges
    DB-->>Analyst: Return recommendations & metrics
    Analyst-->>Host: Response with actionable guidance
```

## Component Descriptions
- ACCOUNTADMIN / Deployment Admin  
  - Purpose: Bootstrap roles, warehouse, and security model  
  - Technology: Snowflake RBAC, key-pair authentication  
  - Location: `ACCOUNTADMIN` context during setup  
  - Deps: Master Snowflake account access

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

