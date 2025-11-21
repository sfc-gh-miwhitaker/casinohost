# 07 - Cost Estimation & Budget Planning

## Goal
Understand the complete cost breakdown for deploying and operating the casino host intelligence demo.

**Bottom line:** ~$0.50 one-time deployment, < $0.01/month ongoing

---

## Cost Summary

| Component | One-Time Cost | Monthly Cost | Notes |
|-----------|--------------|--------------|-------|
| **Deployment** | $0.50 | - | 35 min on X-SMALL warehouse |
| **Storage** | - | < $0.01 | ~50 MB compressed |
| **Warehouse (idle)** | - | $0 | Auto-suspend prevents charges |
| **Cortex AI** | Included | Included | No separate charge for Cortex Analyst |
| **ML Training** | Included | Included | Cortex ML classification |
| **Git Integration** | $0 | $0 | Public repository access |
| **TOTAL** | **~$0.50** | **< $0.01** | Minimal demo cost |

---

## Detailed Breakdown

### 1. Deployment Cost (One-Time)

**Warehouse:** X-SMALL  
**Runtime:** 35 minutes  
**Calculation:**

```
Cost = (35 minutes ÷ 60 minutes/hour) × $1/hour
     = 0.58 hours × $1/hour
     = $0.58
```

**Phases:**
| Phase | Runtime | Credits | Cost |
|-------|---------|---------|------|
| Infrastructure setup | 2 min | 0.03 | $0.03 |
| Raw table creation | 1 min | 0.02 | $0.02 |
| Synthetic data generation | 10 min | 0.17 | $0.17 |
| Staging layer | 5 min | 0.08 | $0.08 |
| Analytics layer | 8 min | 0.13 | $0.13 |
| ML models & scoring | 8 min | 0.13 | $0.13 |
| Cortex Analyst setup | 1 min | 0.02 | $0.02 |
| **TOTAL** | **35 min** | **0.58 credits** | **$0.58** |

**Note:** X-SMALL warehouse = $1/hour = ~0.017 credits/minute

---

### 2. Storage Cost (Ongoing)

**Data Volume:**
- 50,000 players
- 2,000,000 gaming sessions  
- 10,000,000 transactions
- 500,000 comp records
- **Total rows:** ~22 million

**Storage Estimate:**
| Layer | Uncompressed | Snowflake Compressed | Cost/Month |
|-------|--------------|---------------------|------------|
| RAW | ~300 MB | ~30 MB | $0.006 |
| STAGING | ~200 MB | ~20 MB | $0.004 |
| ANALYTICS | ~150 MB | ~15 MB | $0.003 |
| Views (metadata only) | < 1 MB | < 1 MB | < $0.001 |
| **TOTAL** | **~650 MB** | **~65 MB** | **~$0.013** |

**Calculation:**  
Storage rate = $23/TB/month = $0.023/GB/month

```
Cost = 0.065 GB × $0.023/GB/month = $0.0015/month
```

**Snowflake compression:** Typically 10:1 ratio (actual may vary by data type)

---

### 3. Compute Cost (Ongoing)

**Warehouse:** `SFE_CASINO_HOST_WH` (X-SMALL)  
**Auto-suspend:** 60 seconds  
**Auto-resume:** Enabled

**Idle Cost:** $0  
- Warehouse suspends when inactive
- No charges while suspended
- Resumes automatically on first query

**Query Cost (estimated):**
| Scenario | Queries/Day | Avg Runtime | Credits/Day | Cost/Day |
|----------|-------------|-------------|-------------|----------|
| Demo (active exploration) | 50 | 2 sec | 0.028 | $0.028 |
| Occasional review | 5 | 2 sec | 0.003 | $0.003 |
| Idle (no use) | 0 | 0 | 0 | $0 |

**Monthly (occasional use):**
```
Cost = 5 queries/day × 30 days × 0.003 credits = 0.09 credits = $0.09/month
```

---

### 4. Cortex AI Cost (Included)

**Cortex ML Classification:**
- **Training:** Included in warehouse compute (already counted above)
- **Scoring:** Included in query execution
- **No separate charge** for Cortex ML functions

**Cortex Analyst:**
- **Setup:** Included in deployment
- **Queries:** No per-query charge for Cortex Analyst
- **Compute:** Uses existing warehouse credits

**Total Cortex AI Cost:** $0 additional (included in warehouse compute)

---

### 5. Git Integration Cost

**API Integration:** Free  
**Repository Access:** Free (public GitHub repository)  
**EXECUTE IMMEDIATE FROM:** Uses warehouse credits (already counted)

**Total Git Cost:** $0

---

## Cost Optimization Strategies

### 1. Aggressive Auto-Suspend (Already Implemented)
```sql
ALTER WAREHOUSE SFE_CASINO_HOST_WH SET AUTO_SUSPEND = 60;
```
**Savings:** ~90% reduction in idle costs

### 2. Use Transient Tables (If Acceptable)
For tables where 7-day Fail-safe is unnecessary:
```sql
CREATE TRANSIENT TABLE ... 
```
**Savings:** ~25% storage cost reduction

### 3. Drop Warehouse When Not in Use
```sql
DROP WAREHOUSE IF EXISTS SFE_CASINO_HOST_WH;
```
**Savings:** Eliminates all compute costs  
**Trade-off:** Must recreate for queries

### 4. Scale Data Volume
For budget-constrained environments:
```sql
-- In data generation scripts, reduce ROWCOUNT:
-- Instead of 50K players, use 5K
-- Instead of 2M sessions, use 200K
```
**Savings:** ~90% deployment time = ~$0.45 savings

---

## Snowflake Edition Requirements

**Minimum Edition:** Standard  
**Recommended:** Enterprise (for full Cortex capabilities)

| Feature | Standard | Enterprise | Business Critical |
|---------|----------|------------|-------------------|
| Cortex Analyst | ✅ | ✅ | ✅ |
| Cortex ML Classification | ✅ | ✅ | ✅ |
| Git Integration | ✅ | ✅ | ✅ |
| Auto-suspend/resume | ✅ | ✅ | ✅ |
| **Cost/credit** | **$2** | **$3** | **$4** |

**This demo uses:** Standard edition features  
**Estimated cost:** Based on Standard ($2/credit)

---

## Budget Planning

### Sandbox/Dev Environment
- **One-time:** $0.50 deployment
- **Monthly:** $0.10 (occasional queries)
- **Annual:** ~$1.70

### Active Demo Use (Daily)
- **One-time:** $0.50 deployment
- **Monthly:** $2.50 (50 queries/day)
- **Annual:** ~$30.50

### Production-Scale Deployment
For production with real data:
- **Data volume:** 100x larger = 5M players
- **Storage:** ~$1.30/month
- **Warehouse:** MEDIUM or LARGE = $8-32/credit
- **Monthly:** $500-2,000 (depending on query volume)

---

## Cost Monitoring

### Check Current Usage

```sql
-- Credit consumption (last 7 days)
SELECT 
    TO_DATE(start_time) AS usage_date,
    warehouse_name,
    SUM(credits_used) AS total_credits,
    SUM(credits_used) * 2 AS estimated_cost_usd
FROM snowflake.account_usage.warehouse_metering_history
WHERE warehouse_name = 'SFE_CASINO_HOST_WH'
  AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC;

-- Storage usage
SELECT 
    TO_DATE(usage_date) AS date,
    database_name,
    AVG(storage_bytes) / POWER(1024, 3) AS avg_storage_gb,
    AVG(storage_bytes) / POWER(1024, 3) * 0.023 AS estimated_cost_usd_monthly
FROM snowflake.account_usage.database_storage_usage_history
WHERE database_name = 'SNOWFLAKE_EXAMPLE'
  AND usage_date >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC
LIMIT 30;
```

### Set Up Budget Alerts

```sql
-- Create resource monitor (preventative)
CREATE OR REPLACE RESOURCE MONITOR CASINO_DEMO_BUDGET
  WITH CREDIT_QUOTA = 5  -- Alert at $10 (5 credits × $2)
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Apply to warehouse
ALTER WAREHOUSE SFE_CASINO_HOST_WH 
  SET RESOURCE_MONITOR = CASINO_DEMO_BUDGET;
```

---

## Cost Comparison

### vs. Traditional Infrastructure

| Component | Snowflake Demo | Traditional (AWS/Azure) |
|-----------|----------------|-------------------------|
| Database setup | $0 (included) | $50-100 (RDS instance) |
| Storage | $0.01/month | $5-10/month (EBS) |
| Compute | $0 (suspended) | $20-50/month (EC2 always-on) |
| ML infrastructure | $0 (included) | $100-500/month (SageMaker) |
| Maintenance | $0 (managed) | 4-8 hours/month (admin time) |
| **TOTAL (1st month)** | **$0.50** | **$175-660** |

**Savings:** ~350x cheaper for demo/dev workloads

---

## Frequently Asked Questions

### Q: Why is deployment so cheap?
**A:** Snowflake separates storage and compute. You only pay for:
- Compute while warehouse is running (~35 min)
- Storage for actual data (~65 MB compressed)

### Q: Will costs increase if I leave it deployed?
**A:** No. With auto-suspend:
- Warehouse suspends after 60 seconds of inactivity
- Storage is minimal (< $0.01/month)
- Total ongoing cost: < $0.10/month

### Q: What if I query it frequently?
**A:** Each query on X-SMALL costs ~$0.0005 (2 seconds avg)
- 1,000 queries/month = $0.50
- 10,000 queries/month = $5.00

### Q: Can I reduce costs further?
**A:** Yes:
1. Drop warehouse when not in use ($0 compute)
2. Use smaller data sample (reduce deployment time)
3. Drop entire demo after testing ($0 total)

### Q: Is Cortex AI usage metered separately?
**A:** No. Cortex functions use warehouse credits:
- Cortex ML training = warehouse compute time
- Cortex Analyst queries = warehouse compute time
- No additional per-query or per-model fees

---

## Summary

**This demo is designed for cost efficiency:**

✅ **Minimal deployment cost** (~$0.50)  
✅ **Near-zero ongoing cost** (< $0.01/month idle)  
✅ **Aggressive auto-suspend** (60 seconds)  
✅ **Small data footprint** (~65 MB)  
✅ **No separate AI costs** (included in warehouse)

**Perfect for:**
- Learning Snowflake Cortex AI
- Customer demos and POCs
- Development and testing
- Educational purposes

**Not intended for:**
- Production workloads (scale up warehouse + data)
- High-volume query environments (consider SMALL or MEDIUM warehouse)
- Long-term persistent storage (consider regular cleanup)

---

**Questions about costs?**  
- Review actual usage: `snowflake.account_usage` views
- Set budget alerts: Resource Monitors
- Optimize further: See `docs/04-ARCHITECTURE.md` for tuning options

---

**Last Updated:** 2025-11-21  
**Edition:** Standard ($2/credit)  
**Warehouse Size:** X-SMALL ($1/hour)  
**Data Volume:** ~22M rows (~65 MB compressed)

