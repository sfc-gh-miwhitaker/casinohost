# 02 – Demo Deployment

## Goal
Load synthetic data, build analytics and ML assets, and publish the Cortex Analyst instance for casino host guidance.

Estimated time: 15 minutes

## Prerequisites
- Complete `docs/01-SETUP.md`
- Active Snowflake session with role `SFE_CASINO_DEMO_ADMIN`
- Warehouse `SFE_CASINO_HOST_WH` in resume-ready state

## Steps
1. **Run infrastructure setup script**  
   ```bash
   ./tools/01_setup.sh
   ```
   - Creates warehouse, database, schemas, and roles (idempotent)

2. **Generate synthetic datasets**  
   ```bash
   ./tools/02_generate_data.sh
   ```
   - Executes SQL in `sql/02_data_generation/` to populate raw layer

3. **Build staging and analytics layers**  
   ```bash
   ./tools/03_deploy_ml.sh --stage-only
   ```
   - Cleanses raw data into staging tables  
   - Constructs dimensional model, fact tables, and aggregates

4. **Train ML models and create feature views**  
   ```bash
   ./tools/03_deploy_ml.sh --models
   ```
   - Creates `V_PLAYER_FEATURES`, trains churn model, builds LTV and recommendation views

5. **Publish semantic model and Cortex Analyst**  
   ```bash
   ./tools/04_deploy_semantic_model.sh
   ```
   - Uploads YAML to stage  
   - Instantiates `casino_host_analyst` and grants host role access

6. **Review deployment status**  
   ```sql
   SHOW CORTEX ANALYSTS LIKE 'CASINO_HOST_ANALYST';
   SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.DIM_PLAYER;
   ```

## Validation Checklist
- ✔ Raw tables contain expected volumes (`PLAYERS` ≈ 50K, `GAMING_SESSIONS` ≈ 2M)  
- ✔ `ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES` returns probability field  
- ✔ `CORTEX ANALYST casino_host_analyst` status = READY  
- ✔ `CASINO_HOST_ANALYST` role can `SELECT` from analytics views

## Troubleshooting
- **Warehouse auto-suspend mid-run** → Increase cluster auto-suspend to 120 seconds temporarily  
- **Semantic model upload fails** → Verify `PUT` command executed with `AUTO_COMPRESS=FALSE` and role has stage access  
- **Model training errors** → Ensure all scripts ran sequentially and `PLAYER_CHURN_TRAINING` contains rows  
- **Analyst access denied** → Confirm `GRANT USAGE ON CORTEX ANALYST` executed for `CASINO_HOST_ANALYST`

