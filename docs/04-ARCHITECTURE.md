# 04 – Architecture & Validation

## Goal
Document technical decisions, validation checkpoints, and real-world alignment for the casino host intelligence reference implementation.

## Layered Design Summary
| Layer | Purpose | Key Objects | Notes |
| --- | --- | --- | --- |
| Raw (`RAW_INGESTION`) | Land synthetic data with source fidelity | `PLAYERS`, `GAMING_SESSIONS` | Generated via `TABLE(GENERATOR())` using weighted distributions |
| Staging (`STAGING_LAYER`) | Cleanse, normalize, derive base metrics | `STG_PLAYERS`, `STG_GAMING_SESSIONS` | Handles type casting, buckets, host flags |
| Analytics (`ANALYTICS_LAYER`) | Dimensional & aggregate model | `DIM_PLAYER`, `FCT_GAMING_SESSION`, `AGG_PLAYER_LIFETIME` | Supports ML & semantic consumption |
| ML & Recommendations | Feature views + Cortex ML | `V_PLAYER_FEATURES`, `V_PLAYER_CHURN_SCORES`, `V_PLAYER_LTV_SCORES`, `V_PLAYER_RECOMMENDATIONS` | Combines churn, LTV, and business rules |
| Experience | Semantic model & Analyst | `casino_host_semantic_model.yaml`, `casino_host_analyst` | Natural language access for hosts |

## Real-World Validation
- **Comp Economics** – Recommendation engine caps reinvestment at 40% of theoretical, aligned with industry reinvestment ranges.  
- **Churn Definition** – Players inactive >60 days (with prior activity) flagged, mirroring typical loyalty KPI thresholds.  
- **Tier Distribution** – Synthetic generator weights tiers (50% Bronze, 30% Silver, 15% Gold, 4% Platinum, 1% Diamond) reflecting common loyalty programs.  
- **Host Workflows** – Persona narrative derived from actual host responsibilities: proactive outreach, comp justification, and CRM follow-up.  
- **Responsible Gaming** – Scripts encourage hosts to monitor high comp usage and unusual win/loss variance.

## Security & Roles
- `ACCOUNTADMIN` – Bootstrap only; not used during demo.  
- `SFE_CASINO_DEMO_ADMIN` – Full control over demo objects, warehouse, and model training.  
- `CASINO_HOST_ANALYST` – Read-only analytics access + Cortex Analyst usage; no raw/staging access.  
- Key-pair auth recommended; `.env` committed only as reference template.

## Cost Controls
- Warehouse sized `XSMALL` with 60s auto-suspend.  
- Synthetic data volumes tuned to stay performant (<10M rows).  
- Resource monitor template (optional) can cap monthly credits for demo by role.  
- Scripts idempotent—safe to re-run without additional storage growth.

## Testing & Monitoring Hooks
- Data quality tests in `python/tests/` (row counts, referential integrity, distribution checks).  
- ML validation placeholders ensure churn model accuracy ≥75% before showcasing.  
- Diagnostics queries (under `sql/99_cleanup/validate_cleanup.sql`) review credit usage and storage footprint.

## Future Enhancements
- Integrate near-real-time streaming via Snowpipe Streaming for live session updates.  
- Expand Analyst semantic model with verified “What-if comp scenario” queries.  
- Add problem gambling flags leveraging anomaly detection functions.  
- Sync Lucidchart exports (`diagrams/lucidchart/`) for presentation-grade visuals.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory and diagram updates.

