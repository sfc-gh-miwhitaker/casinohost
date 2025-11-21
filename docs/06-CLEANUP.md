# 06 - Cleanup & Teardown

## Goal
Safely remove all casino host intelligence demo objects while preserving shared infrastructure for future demos.

**Estimated time:** 2 minutes

---

## Complete Teardown

### Method 1: Single-Script Cleanup (Recommended)

**Fastest way to remove everything:**

1. **Open Snowsight**
2. **Copy** the entire `sql/99_cleanup/teardown_all.sql` script
3. **Paste** into new worksheet
4. **Click "Run All"**

**Done!** All demo objects removed in < 1 minute.

---

### Method 2: Command-Line Cleanup

If you have Snow CLI configured:

```bash
snow sql -f sql/99_cleanup/teardown_all.sql
```

---

## What Gets Removed

### Schemas (with all contained objects)
- `SNOWFLAKE_EXAMPLE.RAW_INGESTION`
  - 5 raw tables (players, games, sessions, transactions, comps)
  - ~22M rows total
- `SNOWFLAKE_EXAMPLE.STAGING_LAYER`
  - 5 staging tables
  - Transformation logic
- `SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER`
  - 2 dimension tables (player, game)
  - 2 fact tables (gaming session, transaction)
  - 2 aggregate tables (daily, lifetime)
  - 4 ML scoring views (features, churn, LTV, recommendations)
  - Semantic model stage

### Compute & Roles
- Warehouse: `SFE_CASINO_HOST_WH`
- Roles: `SFE_CASINO_DEMO_ADMIN`, `CASINO_HOST_ANALYST`

### AI Objects
- Cortex Analyst: `casino_host_analyst`
- Semantic model YAML file

---

## What Gets Preserved

### Protected Infrastructure
- `SNOWFLAKE_EXAMPLE` database (empty shell)
  - Reason: Shared across demo projects
  - Status: Reset to default state
- `SNOWFLAKE_EXAMPLE.GIT_REPOS` schema (if exists)
  - Reason: Shared Git repository stages
  - Status: Preserved for other demos
- `SFE_*` API integrations (if shared)
  - Example: `SFE_CASINOHOST_GIT_INTEGRATION`
  - Reason: May be used by multiple projects
  - Note: Check before dropping

---

## Verification

After cleanup, run validation queries:

### Option 1: Copy/Paste Validation Script

```sql
-- Run sql/99_cleanup/validate_cleanup.sql
@sql/99_cleanup/validate_cleanup.sql
```

### Option 2: Manual Verification

```sql
-- Should return 0 rows
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE;

-- Should NOT show these schemas
-- RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER

-- Should return 0 rows
SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH';

-- Should return 0 rows
SHOW CORTEX ANALYSTS LIKE 'casino_host_analyst';

-- Should return 0 rows  
SHOW ROLES LIKE 'SFE_CASINO_DEMO_ADMIN';
SHOW ROLES LIKE 'CASINO_HOST_ANALYST';
```

**Expected result:** All queries return 0 rows except GIT_REPOS schema (if preserved).

---

## Partial Cleanup (Advanced)

If you want to keep some components:

### Keep Schemas, Remove Roles Only

```sql
USE ROLE ACCOUNTADMIN;

-- Drop roles but keep data
REVOKE ROLE SFE_CASINO_DEMO_ADMIN FROM ROLE ACCOUNTADMIN;
REVOKE ROLE CASINO_HOST_ANALYST FROM ROLE ACCOUNTADMIN;
DROP ROLE IF EXISTS CASINO_HOST_ANALYST;
DROP ROLE IF EXISTS SFE_CASINO_DEMO_ADMIN;
```

### Keep Data, Remove Warehouse Only

```sql
USE ROLE ACCOUNTADMIN;

-- Stop compute but preserve data
DROP WAREHOUSE IF EXISTS SFE_CASINO_HOST_WH;
```

### Remove Specific Schema Only

```sql
USE ROLE ACCOUNTADMIN;

-- Example: Remove only raw layer
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.RAW_INGESTION CASCADE;
```

---

## Storage Reclamation

After cleanup, storage is reclaimed gradually:

### Immediate
- Active table storage released
- Warehouse compute credits stop accruing

### Within 7 Days
- Time Travel data expires (1-day retention on most tables)
- Fail-safe period completes for permanent tables

### Cost After Cleanup
- **Storage:** < $0.01/month (empty database shell)
- **Compute:** $0 (warehouse dropped)
- **Total:** Effectively $0

---

## Re-Deployment

To redeploy after cleanup:

1. **Copy** `deploy_all.sql` script
2. **Paste** into Snowsight
3. **Run All** (~35 minutes)

All data regenerates from scratch with new synthetic values.

---

## Troubleshooting

### Cleanup Script Fails

**Error: Insufficient privileges**
```
Solution: Ensure you're using ACCOUNTADMIN role
USE ROLE ACCOUNTADMIN;
```

**Error: Object does not exist**
```
Solution: Safe to ignore - object already removed
Continue with rest of script
```

**Error: Cannot drop database (objects still exist)**
```
Solution: Script preserves SNOWFLAKE_EXAMPLE database intentionally
This is expected behavior
```

### Warehouse Still Appears

**Check suspension:**
```sql
SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH';
-- If showing, verify it's suspended (not consuming credits)
```

**Force drop:**
```sql
USE ROLE ACCOUNTADMIN;
DROP WAREHOUSE IF EXISTS SFE_CASINO_HOST_WH;
```

### Roles Still Exist

**Revoke grants first:**
```sql
REVOKE ROLE SFE_CASINO_DEMO_ADMIN FROM ROLE ACCOUNTADMIN;
REVOKE ROLE CASINO_HOST_ANALYST FROM ROLE ACCOUNTADMIN;

-- Then drop
DROP ROLE IF EXISTS CASINO_HOST_ANALYST;
DROP ROLE IF EXISTS SFE_CASINO_DEMO_ADMIN;
```

### Storage Not Declining

**Time Travel retention:**
- Data persists for 1-90 days depending on table type
- Wait for retention period to expire
- Check: `SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN TABLE <table_name>;`

**Fail-safe period (permanent tables):**
- Additional 7 days after Time Travel
- Not user-accessible
- Reclaimed automatically by Snowflake

---

## Cleanup Checklist

- [ ] Backup any custom modifications (if you made changes)
- [ ] Run `sql/99_cleanup/teardown_all.sql`
- [ ] Verify schemas removed: `SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE;`
- [ ] Verify warehouse removed: `SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH';`
- [ ] Verify roles removed: `SHOW ROLES LIKE 'SFE_CASINO_DEMO_ADMIN';`
- [ ] Verify Cortex Analyst removed: `SHOW CORTEX ANALYSTS;`
- [ ] Check storage metrics (optional): Query `ACCOUNT_USAGE.STORAGE_USAGE`

---

## Next Steps

After cleanup:

1. **Review architecture:** See `docs/04-ARCHITECTURE.md` for technical deep dive
2. **Customize for your use case:** Clone and modify for production deployment
3. **Explore other demos:** `SNOWFLAKE_EXAMPLE` database ready for new demos
4. **Redeploy anytime:** Use `deploy_all.sql` for fresh installation

---

## Support

**Cleanup issues?**
- Review `sql/99_cleanup/teardown_all.sql` for detailed commands
- Check role permissions: Must be ACCOUNTADMIN
- Verify no active sessions using demo objects

**Questions?**
- See `docs/04-ARCHITECTURE.md` for object relationships
- Review `diagrams/data-model.md` for schema dependencies

---

**Total cleanup time:** < 2 minutes  
**Storage freed:** ~50 MB (compressed)  
**Cost savings:** ~$0.50/month (X-SMALL warehouse + minimal storage)

