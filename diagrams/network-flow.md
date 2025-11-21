# Network Flow - Casino Host Intelligence
Author: Michael Whitaker  
Last Updated: 2025-11-21  
Status: Reference Impl  
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)  
Reference Impl: This code demonstrates prod-grade architectural patterns and best practice. review and customize security, networking, logic for your organization's specific requirements before deployment.

## Overview
Logical connectivity of demo components including Git-integrated deployment via Snowsight, GitHub repository access, Snowflake services, warehouses, and Cortex Analyst endpoints used by casino hosts.

```mermaid
graph TB
    subgraph "External Services"
        GitHub[GitHub<br/>sfc-gh-miwhitaker/casinohost<br/>Public Repository]
    end

    subgraph "Client Layer"
        Snowsight[Snowsight UI<br/>Deploy via Copy/Paste]
        HostTablet[Casino Host Tablet<br/>Cortex Analyst Queries]
    end

    subgraph "Snowflake Account"
        subgraph "Git Integration"
            APIInt[API Integration<br/>SFE_CASINOHOST_GIT_INTEGRATION]
            GitRepo[Git Repository Stage<br/>@GIT_REPOS.CASINOHOST_REPO]
        end

        subgraph "Security & Access"
            Roles[Roles<br/>ACCOUNTADMIN<br/>SFE_CASINO_DEMO_ADMIN<br/>CASINO_HOST_ANALYST]
        end

        subgraph "Compute"
            Warehouse[SFE_CASINO_HOST_WH<br/>X-Small Warehouse]
        end

        subgraph "Storage & Processing"
            DB[SNOWFLAKE_EXAMPLE Database]
            RAW[RAW_INGESTION Schema]
            STG[STAGING_LAYER Schema]
            ANL[ANALYTICS_LAYER Schema]
        end

        subgraph "AI / Semantic"
            SemanticStage[SEMANTIC_MODELS Stage]
            Analyst[Cortex Analyst<br/>casino_host_analyst]
        end
    end

    GitHub -->|HTTPS Clone| APIInt
    APIInt -->|Git Access| GitRepo
    Snowsight -->|SQL via HTTPS 443| Warehouse
    Snowsight -->|Deploy Script| GitRepo
    GitRepo -.EXECUTE IMMEDIATE FROM.-> Warehouse
    HostTablet -->|HTTPS 443 Analyst UI| Analyst

    Warehouse --> DB
    DB --> RAW
    DB --> STG
    DB --> ANL
    Analyst --> SemanticStage
    SemanticStage --> ANL

    Roles --> Warehouse
    Roles --> DB
    Roles --> Analyst
    Roles --> GitRepo
```

## Component Descriptions

### External Services
- **GitHub Repository**  
  - Purpose: Host all SQL scripts, documentation, and deployment code  
  - Technology: GitHub public repository  
  - Location: `https://github.com/sfc-gh-miwhitaker/casinohost`  
  - Access: Public, no authentication required

### Client Layer
- **Snowsight UI**  
  - Purpose: Primary deployment interface via copy/paste of `deploy_all.sql`  
  - Technology: Snowflake web interface (HTTPS 443)  
  - Location: `<account>.snowflakecomputing.com`  
  - Deps: ACCOUNTADMIN role for initial deployment

- **Casino Host Tablet**  
  - Purpose: Access Cortex Analyst for natural language queries  
  - Technology: Browser-based Cortex Analyst UI  
  - Location: Snowsight interface  
  - Deps: CASINO_HOST_ANALYST role

### Git Integration
- **API Integration (SFE_CASINOHOST_GIT_INTEGRATION)**  
  - Purpose: Authorize Snowflake to access GitHub repository via HTTPS  
  - Technology: Snowflake API Integration object (git_https_api)  
  - Location: Account-level object  
  - Allowed Prefix: `https://github.com/sfc-gh-miwhitaker/`

- **Git Repository Stage (@GIT_REPOS.CASINOHOST_REPO)**  
  - Purpose: Mount GitHub repository as Snowflake stage for `EXECUTE IMMEDIATE FROM`  
  - Technology: Snowflake Git Repository object  
  - Location: `SNOWFLAKE_EXAMPLE.GIT_REPOS.CASINOHOST_REPO`  
  - Pattern: `@stage/branches/main/sql/...`

- SFE_CASINO_HOST_WH Warehouse  
  - Purpose: Execute synthetic data generation, transformations, and ML scoring  
  - Technology: Snowflake virtual warehouse (X-Small)  
  - Location: `SFE_CASINO_HOST_WH`  
  - Deps: `SFE_CASINO_DEMO_ADMIN` role grants

- SNOWFLAKE_EXAMPLE Database  
  - Purpose: Persist raw, staging, and analytics schemas for demo  
  - Technology: Snowflake database schemas  
  - Location: `SNOWFLAKE_EXAMPLE`  
  - Deps: Warehouse compute, storage services

- Cortex Analyst Instance  
  - Purpose: Provide natural language interface for casino hosts  
  - Technology: Snowflake Cortex Analyst service  
  - Location: `casino_host_analyst`  
  - Deps: Semantic model stage, `CASINO_HOST_ANALYST` role

- Semantic Model Stage  
  - Purpose: Store YAML definitions for Analyst deployments  
  - Technology: Snowflake internal stage  
  - Location: `ANALYTICS_LAYER.SEMANTIC_MODELS`  
  - Deps: Upload from developer workstation

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

