# Data Flow - Casino Host Intelligence
Author: Michael Whitaker  
Last Updated: 2025-11-17  
Status: Reference Impl  
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)  
Reference Impl: This code demonstrates prod-grade architectural patterns and best practice. review and customize security, networking, logic for your organization's specific requirements before deployment.

## Overview
End-to-end journey of synthetic casino data from raw generation through staging, analytics modeling, ML feature creation, and Cortex Analyst consumption supporting casino host decisions.

```mermaid
graph TB
    subgraph "Generation"
        GEN_PLAYERS[SQL Generator<br/>Players]
        GEN_GAMES[SQL Generator<br/>Games]
        GEN_SESSIONS[SQL Generator<br/>Sessions]
        GEN_TXNS[SQL Generator<br/>Transactions]
        GEN_COMPS[SQL Generator<br/>Comps]
    end

    subgraph "Raw Layer - SNOWFLAKE_EXAMPLE.RAW_INGESTION"
        RAW_PLAYERS[(PLAYERS)]
        RAW_GAMES[(GAMES)]
        RAW_SESSIONS[(GAMING_SESSIONS)]
        RAW_TXNS[(TRANSACTIONS)]
        RAW_COMPS[(COMPS_HISTORY)]
    end

    subgraph "Staging Layer - SNOWFLAKE_EXAMPLE.STAGING_LAYER"
        STG_PLAYERS[(STG_PLAYERS)]
        STG_GAMES[(STG_GAMES)]
        STG_SESSIONS[(STG_GAMING_SESSIONS)]
        STG_TXNS[(STG_TRANSACTIONS)]
        STG_COMPS[(STG_COMPS_HISTORY)]
    end

    subgraph "Analytics Layer - SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER"
        DIM_PLAYER[(DIM_PLAYER)]
        DIM_GAME[(DIM_GAME)]
        FCT_SESSION[(FCT_GAMING_SESSION)]
        FCT_TXN[(FCT_TRANSACTION)]
        AGG_DAILY[(AGG_PLAYER_DAILY)]
        AGG_LIFETIME[(AGG_PLAYER_LIFETIME)]
        VIEW_FEATURES[[V_PLAYER_FEATURES]]
        VIEW_CHURN[[V_PLAYER_CHURN_SCORES]]
        VIEW_LTV[[V_PLAYER_LTV_SCORES]]
        VIEW_RECO[[V_PLAYER_RECOMMENDATIONS]]
    end

    subgraph "Consumption"
        SEMANTIC[Semantic Model YAML]
        ANALYST[Cortex Analyst<br/>casino_host_analyst]
        HOST_UI[Host Experience]
    end

    GEN_PLAYERS --> RAW_PLAYERS
    GEN_GAMES --> RAW_GAMES
    GEN_SESSIONS --> RAW_SESSIONS
    GEN_TXNS --> RAW_TXNS
    GEN_COMPS --> RAW_COMPS

    RAW_PLAYERS --> STG_PLAYERS --> DIM_PLAYER
    RAW_GAMES --> STG_GAMES --> DIM_GAME
    RAW_SESSIONS --> STG_SESSIONS --> FCT_SESSION --> AGG_DAILY --> AGG_LIFETIME
    RAW_TXNS --> STG_TXNS --> FCT_TXN
    RAW_COMPS --> STG_COMPS --> DIM_PLAYER

    DIM_PLAYER --> VIEW_FEATURES
    AGG_LIFETIME --> VIEW_FEATURES
    FCT_SESSION --> VIEW_FEATURES

    VIEW_FEATURES --> VIEW_CHURN
    VIEW_FEATURES --> VIEW_LTV
    VIEW_CHURN --> VIEW_RECO
    VIEW_LTV --> VIEW_RECO

    VIEW_FEATURES --> SEMANTIC
    VIEW_CHURN --> SEMANTIC
    VIEW_LTV --> SEMANTIC
    VIEW_RECO --> SEMANTIC

    SEMANTIC --> ANALYST --> HOST_UI
```

## Component Descriptions
- Synthetic Generators  
  - Purpose: Generate statistically realistic casino demo data  
  - Technology: Snowflake SQL (`TABLE(GENERATOR())`, random functions)  
  - Location: `sql/02_data_generation/`  
  - Deps: `SNOWFLAKE_EXAMPLE.RAW_INGESTION` tables

- Staging Layer Tables  
  - Purpose: Standardize data types, cleanse values, add derived metrics  
  - Technology: SQL transformation scripts  
  - Location: `sql/03_transformations/10-50_stage_*.sql`  
  - Deps: Raw tables, Snowflake warehouse `SFE_CASINO_HOST_WH`

- Analytics Layer Facts & Dimensions  
  - Purpose: Provide dimensional model with aggregated session and transaction metrics  
  - Technology: SQL star-schema modeling  
  - Location: `sql/03_transformations/60-96_*.sql`  
  - Deps: Staging tables (`STAGING_LAYER` schemas)

- ML Feature & Scoring Views  
  - Purpose: Supply churn, LTV, and recommendation insights for hosts  
  - Technology: SQL views + Cortex ML classification  
  - Location: `sql/04_ml_models/`  
  - Deps: Analytics layer tables, Cortex ML runtime

- Semantic Model & Cortex Analyst  
  - Purpose: Deliver natural language access to host insights  
  - Technology: Mermaid YAML + Cortex Analyst service  
  - Location: `sql/05_semantic_model/`  
  - Deps: Feature views, stage `ANALYTICS_LAYER.SEMANTIC_MODELS`

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

