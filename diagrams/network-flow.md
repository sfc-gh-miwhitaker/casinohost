# Network Flow - Casino Host Intelligence
Author: Michael Whitaker  
Last Updated: 2025-11-17  
Status: Reference Impl  
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)  
Reference Impl: This code demonstrates prod-grade architectural patterns and best practice. review and customize security, networking, logic for your organization's specific requirements before deployment.

## Overview
Logical connectivity of demo components including developer workstation, Snowflake services, warehouses, and Cortex Analyst endpoints used by casino hosts.

```mermaid
graph TB
    subgraph "Client Layer"
        DevIDE[Developer Workstation<br/>Cursor IDE]
        HostTablet[Casino Host Tablet<br/>Browser]
    end

    subgraph "Snowflake Account"
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
            Stage[Stage SEMANTIC_MODELS]
            Analyst[Cortex Analyst<br/>casino_host_analyst]
        end
    end

    DevIDE -->|HTTPS 443 / SnowSQL| Warehouse
    HostTablet -->|HTTPS 443 (Snowsight / Analyst UI)| Analyst

    Warehouse --> DB
    DB --> RAW
    DB --> STG
    DB --> ANL
    Analyst --> Stage
    Stage --> ANL

    Roles --> Warehouse
    Roles --> DB
    Roles --> Analyst
```

## Component Descriptions
- Developer Workstation  
  - Purpose: Author SQL, Python, and deployment scripts  
  - Technology: Cursor IDE on macOS, SnowSQL CLI  
  - Location: Local workstation  
  - Deps: Snowflake account credentials

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

