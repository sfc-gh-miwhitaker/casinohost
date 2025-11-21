# Casino Host Intelligence - Quick Start

**Get from zero to working demo in 5 minutes.**

---

## Single-Script Deployment (Recommended)

**Time:** 5 minutes active work, 35 minutes automated  
**Method:** 100% native Snowflake deployment via Git integration

### Steps

1. **Open Snowsight** (your Snowflake web interface)
2. **Navigate to** your Snowflake account with `ACCOUNTADMIN` privileges
3. **Copy** the entire `deploy_all.sql` script from:  
   https://github.com/sfc-gh-miwhitaker/casinohost/blob/main/deploy_all.sql
4. **Create** a new Snowsight worksheet
5. **Paste** the entire script (all 280+ lines)
6. **Click "Run All"** button (top right corner)
7. **Wait ~35 minutes** for automated deployment

**Done!** All infrastructure, data, ML models, and Cortex Analyst deployed automatically.

---

## What Gets Deployed

✅ **Infrastructure**
- Warehouse: `SFE_CASINO_HOST_WH` (X-SMALL, auto-suspend 60s)
- Database: `SNOWFLAKE_EXAMPLE` (shared demo database)
- Schemas: `RAW_INGESTION`, `STAGING_LAYER`, `ANALYTICS_LAYER`
- Roles: `SFE_CASINO_DEMO_ADMIN`, `CASINO_HOST_ANALYST`

✅ **Synthetic Data** (22M+ rows)
- 50,000 player profiles with realistic tier distribution
- 2 million gaming sessions with temporal patterns
- 10 million transactions modeling house edge economics
- 500,000 comp history records

✅ **Data Architecture**
- Dimensional model: 2 dimensions (player, game)
- Fact tables: gaming sessions, transactions
- Aggregate tables: daily and lifetime player metrics

✅ **Machine Learning**
- Churn classification model (Snowflake Cortex ML)
- Lifetime value scoring (RFM methodology)
- Next-best-action recommendations engine

✅ **AI Interface**
- Cortex Analyst semantic model
- Natural language query capability
- Pre-validated demo queries

---

## First Query

After deployment completes, test Cortex Analyst:

```sql
-- Open Cortex Analyst in Snowsight
-- Or run directly:
SELECT SNOWFLAKE.CORTEX.COMPLETE_ANALYST(
    'casino_host_analyst',
    'Which players should I offer comps to right now?'
);
```

**Expected result:** List of high-value players with recommended comp offers.

---

## Demo Scenarios

### Scenario 1: Identify At-Risk VIPs
**Query:** "Show me high-value players at risk of churning"  
**Use Case:** Urgent retention intervention

### Scenario 2: Tier Development Opportunities
**Query:** "Which Silver players deserve a tier review?"  
**Use Case:** Proactive loyalty program management

### Scenario 3: Win-Back Campaign
**Query:** "List players absent 30+ days with prior host touches"  
**Use Case:** Targeted reactivation campaigns

See `docs/03-USAGE.md` for complete demo script with 5 personas.

---

## View Analytics Directly

Query the analytics layer without natural language:

```sql
-- High-priority recommendations
SELECT 
    player_id,
    player_name,
    loyalty_tier,
    churn_probability,
    suggested_action,
    suggested_comp_value_usd
FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS
WHERE churn_risk_segment = 'High Risk'
ORDER BY lifetime_theoretical_value DESC
LIMIT 25;
```

---

## Estimated Costs

**One-time deployment:** ~$0.50  
- Runtime: 35 minutes on X-SMALL warehouse
- Rate: ~$1/hour for X-SMALL
- Formula: 35/60 × $1 = $0.58

**Ongoing costs:** < $0.01/month (with auto-suspend)

See `docs/07-COST-ESTIMATION.md` for detailed breakdown.

---

## Cleanup

Remove all demo objects when finished:

```sql
-- Copy/paste into Snowsight and run:
@sql/99_cleanup/teardown_all.sql
```

**What's removed:**
- All schemas (RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER)
- Warehouse (SFE_CASINO_HOST_WH)
- Roles (SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST)
- Cortex Analyst instance

**What's preserved:**
- `SNOWFLAKE_EXAMPLE` database (empty shell for future demos)
- Shared API integrations (if used by other demos)

Verify cleanup: `docs/06-CLEANUP.md`

---

## Next Steps

1. **Explore demo personas** - `docs/03-USAGE.md`
2. **Understand architecture** - `docs/04-ARCHITECTURE.md`
3. **Validate industry alignment** - `docs/05-INDUSTRY-VALIDATION.md`
4. **Review diagrams** - `diagrams/` directory

---

## Troubleshooting

**Deployment fails?**
- Check ACCOUNTADMIN privileges
- Verify network access to GitHub
- Confirm Cortex AI enabled in your account

**Cortex Analyst not responding?**
- Verify semantic model deployed: `SHOW CORTEX ANALYSTS;`
- Check role permissions: `USE ROLE CASINO_HOST_ANALYST;`

**Data looks wrong?**
- Run validation queries: `docs/05-INDUSTRY-VALIDATION.md`
- Check row counts: deployment script shows final counts

**Need help?**
- See detailed deployment guide: `docs/02-DEPLOYMENT.md`
- Review architecture: `docs/04-ARCHITECTURE.md`

---

**Ready to deploy? Copy `deploy_all.sql` into Snowsight and click "Run All".**

