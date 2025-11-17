# Casino Host Intelligence Demo

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![Status](https://img.shields.io/badge/Status-Reference%20Implementation-green?style=for-the-badge)

**Production-grade AI-powered casino host guidance system built 100% natively in Snowflake**

---

## 🎯 Purpose

This demo showcases how casino operators can leverage Snowflake's Data Cloud, Cortex AI, and ML capabilities to transform casino host operations from reactive to predictive. By combining synthetic gaming data, machine learning models, and natural language interfaces, hosts gain real-time insights to:

- **Identify churn risk** before high-value players leave
- **Optimize comp strategies** based on player lifetime value
- **Personalize engagement** with data-driven next-best-action recommendations
- **Maximize player retention** and lifetime profitability

### Target Audience
- Casino operations teams evaluating AI/ML for player analytics
- Data engineering teams architecting gaming analytics platforms
- Snowflake prospects in the gaming & hospitality vertical
- Solutions engineers demonstrating Cortex AI capabilities

### Business Value
- **Increase player retention** by 15-25% through proactive churn intervention
- **Optimize comp spend** by aligning offers to theoretical value (25-40% reinvestment)
- **Improve host productivity** with prioritized daily action lists
- **Scale host services** to cover more players with AI-assisted guidance

---

## 📦 What's Delivered

### 1. Complete Synthetic Data Pipeline
- **50,000 realistic player profiles** with loyalty tiers, demographics, and lifetime metrics
- **2M+ gaming sessions** with temporal patterns (weekend spikes, peak hours)
- **10M+ transactions** modeling wins, losses, and house edge economics
- **500K+ comp history records** tracking offers, redemptions, and response rates
- **Industry-validated distributions**: Tier pyramid (50/30/15/4/1), ADT ranges, churn rates

### 2. Production-Grade Data Architecture
- **Layered design**: RAW → STAGING → ANALYTICS (dimensional model + aggregates)
- **Dimensional model**: Player/Game dimensions, Gaming Session/Transaction facts
- **Aggregate tables**: Daily and lifetime player metrics for fast queries
- **Idempotent SQL scripts**: Safe to re-run, versioned, fully documented

### 3. Machine Learning Models
- **Churn Classification** (Snowflake Cortex ML): Predicts player churn risk with 75%+ accuracy
- **Lifetime Value Scoring** (RFM methodology): Segments players into 5 actionable groups
- **Next-Best-Action Engine** (business rules): Recommends comp offers aligned to casino economics
- **Feature engineering**: 25+ derived metrics (recency, frequency, monetary, host interactions)

### 4. Cortex Analyst Interface
- **Semantic model** (YAML): Defines player entities, metrics, and relationships for natural language queries
- **Verified queries**: 3 pre-validated questions casino hosts ask daily
- **Ad-hoc Q&A**: Hosts can ask follow-up questions in plain English
- **Role-based access**: Analysts see data, hosts get actionable guidance

### 5. Real-World Demo Narrative
- **5 authentic personas**: Whale, Rising Star, At-Risk Regular, Weekend Warrior, High-Potential New Player
- **15-minute demo script**: Morning briefing, tier review, win-back campaign scenarios
- **Query starter pack**: 20+ example questions for Cortex Analyst
- **Industry validation**: All metrics aligned to casino industry standards (ADT, comp %, churn definition)

### 6. Comprehensive Testing & Validation
- **14 integration tests** (pytest): Data quality, ML validation, Cortex queries, E2E pipeline
- **Industry benchmark validation**: 12 categories of real-world alignment
- **Persona discovery queries**: Validate all 5 archetypes exist in generated data
- **Cross-platform scripts**: Automated deployment and validation for macOS/Linux/Windows

### 7. Complete Documentation Suite
- **01-SETUP.md**: Environment prerequisites and Snowflake configuration
- **02-DEPLOYMENT.md**: Step-by-step deployment with validation checkpoints
- **03-USAGE.md**: Demo script, personas, Cortex Analyst query examples, workflow tips
- **04-ARCHITECTURE.md**: Technical deep dive into data model and ML design
- **05-INDUSTRY-VALIDATION.md**: Real-world alignment across 12 validation categories
- **Architecture diagrams**: Data flow, network flow, authentication flow (Mermaid format)

### 8. Deployment Automation
- **Cross-platform scripts** (.sh + .bat): 5 numbered scripts for setup → validation
- **Estimated deployment time**: 35 minutes (automated) to working demo
- **Rollback plan**: Complete teardown script preserving SNOWFLAKE_EXAMPLE DB
- **Cleanup validation**: Verify all demo objects removed safely

---

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

**Total setup time:** ~35 minutes

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     SNOWFLAKE DATA CLOUD                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  RAW_INGESTION          STAGING_LAYER         ANALYTICS_LAYER  │
│  ┌──────────┐           ┌──────────┐          ┌──────────┐    │
│  │ PLAYERS  │──────────>│STG_      │─────────>│DIM_      │    │
│  │ GAMES    │   Clean   │PLAYERS   │ Model   │PLAYER    │    │
│  │ SESSIONS │   & Type  │STG_GAMES │ & Join  │DIM_GAME  │    │
│  │ TRANSACTIONS         │STG_      │          │FCT_      │    │
│  │ COMPS    │           │SESSIONS  │          │SESSION   │    │
│  └──────────┘           └──────────┘          └──────────┘    │
│                                                     │           │
│                                                     v           │
│                                          ┌────────────────┐    │
│                                          │ ML LAYER       │    │
│                                          ├────────────────┤    │
│                                          │ Churn Model    │    │
│                                          │ LTV Scores     │    │
│                                          │ Recommendations│    │
│                                          └────────────────┘    │
│                                                     │           │
│                                                     v           │
│                                          ┌────────────────┐    │
│                                          │ CORTEX ANALYST │    │
│                                          │ Semantic Model │    │
│                                          │ Natural Lang Q │    │
│                                          └────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack
- **Data Platform**: Snowflake (100% native, no external dependencies)
- **Synthetic Data**: Snowflake GENERATOR function + statistical distributions
- **Machine Learning**: Snowflake Cortex ML (classification), RFM scoring (SQL)
- **AI Interface**: Cortex Analyst (semantic model + natural language queries)
- **Testing**: Python pytest + Snowflake connector
- **Deployment**: Cross-platform Bash/Batch scripts + Snow CLI

---

## 🎬 Demo Scenarios

### Scenario 1: Urgent Retention (Marcus Chen - Diamond Whale)
**Host Question:** "Show me high-value players at risk of churning"  
**Cortex Analyst Response:** Marcus Chen (Diamond, $15K ADT, 0.72 churn probability)  
**Recommended Action:** Premium comp bundle ($500 dinner + show)  
**Business Outcome:** Prevent loss of $450K annual theoretical value

### Scenario 2: Tier Development (Jennifer Martinez - Rising Star)
**Host Question:** "Which Silver players deserve a tier review?"  
**Cortex Analyst Response:** Jennifer Martinez (ADT growth $200→$500, 8 visits/month)  
**Recommended Action:** Proactive tier upgrade + explain enhanced benefits  
**Business Outcome:** Lock in high-engagement player before competitor recruitment

### Scenario 3: Win-Back Campaign (David Thompson - At-Risk Regular)
**Host Question:** "List players absent 30+ days with prior host touches"  
**Cortex Analyst Response:** David Thompson (Gold, visits declined 12→2/month)  
**Recommended Action:** Targeted comeback offer ($100 meal comp + bonus play)  
**Business Outcome:** Recover $2,400/month theoretical revenue stream

---

## 📊 Industry Validation

All metrics, calculations, and workflows validated against casino industry standards:

| Metric | Industry Standard | Our Implementation |
|--------|------------------|-------------------|
| **ADT (Avg Daily Theoretical)** | Primary player value metric | House edge × total wagered |
| **Comp Reinvestment** | 25-40% of theoretical | 30-35% based on tier + risk |
| **Tier Distribution** | Pyramid: 50/30/15/4/1 | Matches synthetic generation |
| **Churn Definition** | 60-90 days inactivity | 60-day threshold (conservative) |
| **VIP Host Allocation** | Top 5% get dedicated hosts | Platinum+ & top 40% Gold (~5%) |

See `docs/05-INDUSTRY-VALIDATION.md` for complete validation across 12 categories.

---

## 🚀 Quick Start (5 minutes to running demo)

```bash
# 1. Clone and navigate
cd /path/to/casinohost

# 2. Set up Python environment
python -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate   # Windows
pip install -r python/requirements.txt

# 3. Configure Snowflake connection
# Set environment variables or use Snow CLI default connection

# 4. Deploy everything (35 minutes automated)
./tools/01_setup.sh
./tools/02_generate_data.sh
./tools/03_deploy_ml.sh
./tools/04_deploy_semantic_model.sh

# 5. Test Cortex Analyst
# Query via Snowsight or SQL:
SELECT SNOWFLAKE.CORTEX.COMPLETE_ANALYST(
    'casino_host_analyst',
    'Which players should I offer comps to right now?'
);

# 6. Run integration tests
pytest python/tests -v
```

---

## 📁 Project Structure

```
casinohost/
├── sql/
│   ├── 01_setup/              # Roles, warehouse, schemas, raw tables
│   ├── 02_data_generation/    # Synthetic data (players, sessions, transactions)
│   ├── 03_transformations/    # ETL (RAW→STAGING→ANALYTICS)
│   ├── 04_ml_models/          # Churn model, LTV scoring, recommendations
│   ├── 05_semantic_model/     # Cortex Analyst YAML + deployment
│   └── 99_cleanup/            # Teardown scripts
├── tools/                      # Cross-platform deployment scripts (.sh + .bat)
├── python/tests/              # Integration test suite (pytest)
├── diagrams/                  # Architecture diagrams (Mermaid)
├── docs/                      # User guides (01-SETUP through 05-VALIDATION)
└── README.md                  # This file
```

---

## 🧪 Testing & Validation

### Automated Test Suite (14 tests)
```bash
pytest python/tests -v
```

**Test Coverage:**
- Data quality validation (row counts, uniqueness, nulls)
- ML model validation (churn class balance, probability ranges, LTV segments)
- Cortex Analyst integration (semantic model staging, query execution)
- End-to-end pipeline (full deployment validation)

### Industry Benchmark Validation
Run validation queries from `docs/05-INDUSTRY-VALIDATION.md`:
- Tier distribution (should match 50/30/15/4/1 pyramid)
- ADT ranges by tier (Diamond $5-20K, Bronze $50-300)
- Comp reinvestment % (should be 25-40% of theoretical)
- Churn rate (should be 10-20% in training data)
- Weekend effect (50-60% of sessions Fri-Sun)

---

## 🔒 Security & Governance

### Role-Based Access Control
- **SFE_CASINO_DEMO_ADMIN**: Full control over demo objects (deployment)
- **CASINO_HOST_ANALYST**: Read-only access to analytics views + Cortex Analyst (end users)

### Data Privacy
- All data is synthetic (no PII, safe for public demos)
- Production implementation requires: row-level security, data masking, audit logging

### Responsible Gaming
- Demo includes responsible gaming considerations
- Anomalous play detection metrics available in session facts
- Host workflow documentation includes intervention protocols

---

## 🧹 Cleanup

### Remove All Demo Objects
```bash
# Complete teardown (preserves SNOWFLAKE_EXAMPLE DB for other demos)
snow sql -f sql/99_cleanup/teardown_all.sql

# Validate cleanup succeeded
snow sql -f sql/99_cleanup/validate_cleanup.sql
```

**What's Removed:**
- Cortex Analyst instance
- All schemas (RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER)
- Warehouse (SFE_CASINO_HOST_WH)
- Roles (SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST)

**What's Preserved:**
- SNOWFLAKE_EXAMPLE database (empty shell for future demos)
- SFE_* API integrations (shared across demo projects)

---

## 📚 Documentation

| Document | Purpose | Time |
|----------|---------|------|
| `docs/01-SETUP.md` | Environment prerequisites, Snowflake config | 5 min |
| `docs/02-DEPLOYMENT.md` | Step-by-step deployment guide | 10 min |
| `docs/03-USAGE.md` | Demo script, personas, Cortex queries | 10 min |
| `docs/04-ARCHITECTURE.md` | Technical deep dive, design decisions | 10 min |
| `docs/05-INDUSTRY-VALIDATION.md` | Real-world alignment, validation queries | 10 min |

---

## 🎓 Learning Objectives

By deploying and exploring this demo, you'll learn:

1. **Synthetic Data Generation at Scale**: Using Snowflake's GENERATOR function and statistical distributions
2. **Dimensional Modeling Best Practices**: Star schema design with slowly changing dimensions
3. **In-Database Machine Learning**: Training and deploying Cortex ML classification models
4. **Semantic Modeling**: Creating YAML semantic models for Cortex Analyst
5. **Natural Language Analytics**: Enabling business users to query data conversationally
6. **MLOps Patterns**: Feature engineering, model training, scoring view deployment
7. **Industry-Specific Analytics**: Casino player metrics (ADT, RFM, churn, comp economics)
8. **Cross-Platform Automation**: Writing idempotent deployment scripts

---

## 🤝 Contributing & Customization

### Customization Ideas
- **Scale Up**: Increase player count to 100K-1M (change ROWCOUNT in generation scripts)
- **Add Game Types**: Extend game catalog with specific slot titles or table limits
- **Geographic Segmentation**: Add regional analysis (by state/casino property)
- **Time-Series Forecasting**: Add Cortex ML forecasting for session predictions
- **Real-Time Streaming**: Replace batch generation with Snowpipe Streaming simulation
- **Multi-Property**: Extend to casino chain with property-level rollups

### Vertical Adaptations
- **Tribal Gaming**: Adjust tier structure, add tribal ID considerations
- **Online/iGaming**: Add device/channel dimensions, session duration patterns
- **Sports Betting**: Replace gaming sessions with bet slips, add odds/lines
- **Hospitality (Hotels)**: Adapt to room bookings, F&B spend, loyalty programs

---

## 📞 Support & Resources

**Demo Owner:** Michael Whitaker (Snowflake Solutions Engineering)  
**Environment:** SFSENORTHAMERICA-MWHITAKER_AWS  
**Project Repository:** `/Users/mwhitaker/src/casinohost`

**Related Snowflake Documentation:**
- [Cortex ML Classification](https://docs.snowflake.com/en/user-guide/ml-powered-classification)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Synthetic Data Generation](https://docs.snowflake.com/en/user-guide/data-load-generate)
- [Semantic Models](https://docs.snowflake.com/en/user-guide/snowflake-cortex/semantic-model-spec)

---

## ⚠️ Reference Implementation Notice

This is a **reference implementation** designed for demonstration and educational purposes. Before deploying to production:

- Review and customize security controls (RBAC, data masking, network policies)
- Validate business logic and thresholds against your organization's requirements
- Conduct load testing and optimize warehouse sizing for production scale
- Implement comprehensive monitoring, alerting, and incident response
- Ensure compliance with gaming regulations and responsible gambling mandates

**This demo showcases Snowflake capabilities; customize for your specific environment and use case.**

---

## 📄 License

Reference implementation for Snowflake demonstration purposes.  
Not for production use without proper security review and customization.

---

**Ready to see AI-powered casino host intelligence in action? Start with `docs/01-SETUP.md` and deploy in 35 minutes.**

