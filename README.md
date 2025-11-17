# Casino Host Intelligence Demo

## 👋 First Time Here?
Follow these items in order:
1. `docs/01-SETUP.md` – Environment prerequisites and Snowflake configuration (5 min)
2. `tools/01_setup.sh` – Provision demo warehouse, roles, and schemas
3. `docs/02-DEPLOYMENT.md` – Deploy synthetic data, transforms, and ML models (10 min)
4. `tools/02_generate_data.sh` – Generate casino synthetic datasets
5. `tools/03_deploy_ml.sh` – Build analytics layer and ML scoring artifacts
6. `tools/04_deploy_semantic_model.sh` – Publish semantic model and Cortex Analyst agent
7. `docs/03-USAGE.md` – Operate the demo and run Cortex Analyst scenarios (10 min)
8. `docs/04-ARCHITECTURE.md` – Understand design decisions and validation checks (10 min)
9. `tools/05_validate.sh` – Optional full pipeline + pytest validation (10 min)

Total setup time: ~35 minutes

## Overview
This repository delivers a fully native Snowflake reference implementation that guides casino hosts with AI-driven recommendations. Synthetic data models gaming sessions, comps, and player behavior to generate churn risk, lifetime value, and next-best-action insights exposed through Snowflake Cortex Analyst. The project emphasizes responsible gaming, validated industry metrics, and a narrative storyline for demo delivery.

## Key Features
- Native Snowflake synthetic data generation at scale (50K players, 10M transactions)
- Layered architecture (RAW → STAGING → ANALYTICS) with dimensional modeling
- Cortex ML churn classification and SQL-based LTV scoring
- Business-rule recommendation engine aligned with casino comp economics
- Cortex Analyst semantic model enabling natural language interaction for hosts
- Comprehensive documentation, tests, and teardown scripts for repeatable demos

