# 01 – Environment Setup

## Goal
Provision Snowflake prerequisites, local tooling, and security roles required to run the casino host intelligence demo safely.

## Prerequisites
- Snowflake account with `ACCOUNTADMIN` privileges (temporary or sandbox)
- **Snowsight access** (web interface) - primary deployment method
- Network access to GitHub for git repository integration
- Network access to `SNOWFLAKE_EXAMPLE` database (no IP restrictions)

Estimated time: 5 minutes

## Deployment Method

This demo uses **100% native Snowflake deployment** via Git integration. No local tooling required.

### Primary Method: Single-Script Deployment

1. **Open Snowsight** (your Snowflake web interface)
2. **Copy** entire `deploy_all.sql` script from GitHub (project root)
3. **Paste** into new Snowsight worksheet
4. **Click "Run All"** (top right button)
5. **Wait ~35 minutes** for automated deployment

**That's it!** All infrastructure, data generation, ML models, and Cortex Analyst deploy automatically.

### Alternative: Manual Step-by-Step

If you prefer to execute each component separately:

1. **Initialize Snowflake roles and warehouse**  
   Execute `sql/01_setup/01_create_core_objects.sql` as `ACCOUNTADMIN`

2. **Verify grants**  
   ```sql
   SHOW GRANTS TO ROLE SFE_CASINO_DEMO_ADMIN;
   SHOW GRANTS TO ROLE CASINO_HOST_ANALYST;
   ```

3. **Proceed to deployment**  
   See `docs/02-DEPLOYMENT.md` for step-by-step manual deployment

## Verification
- `SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH'` returns the demo warehouse  
- `SHOW ROLES LIKE 'SFE_CASINO_DEMO_ADMIN'` / `CASINO_HOST_ANALYST` return expected roles  
- No errors when executing setup script

## Troubleshooting
- **Warehouse already exists** → Adjust script to skip `CREATE OR REPLACE` or use isolated account  
- **Insufficient privileges** → Confirm session role is `ACCOUNTADMIN` before running setup  
- **Key pair login failures** → Validate private key path and ensure public key uploaded to Snowflake user

