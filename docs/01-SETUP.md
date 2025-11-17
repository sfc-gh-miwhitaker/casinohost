# 01 – Environment Setup

## Goal
Provision Snowflake prerequisites, local tooling, and security roles required to run the casino host intelligence demo safely.

## Prerequisites
- Snowflake account with `ACCOUNTADMIN` privileges (temporary or sandbox)
- SnowSQL CLI or Snowsight worksheets for running SQL scripts
- Git + Python 3.10+ installed locally
- Network access to `SNOWFLAKE_EXAMPLE` database (no IP restrictions)

Estimated time: 5 minutes

## Steps
1. **Clone repository**  
   ```bash
   git clone https://github.com/your-org/casinohost.git
   cd casinhost
   ```

2. **Configure Python environment**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate        # Windows: venv\Scripts\activate
   pip install -r python/requirements.txt
   ```

3. **Set Snowflake connectivity**  
   - Create `config/.env` (copy from `config/.env.example` once added)  
   - Populate account, username, role, warehouse, database, key pair / password

4. **Generate key pair (optional but recommended)**  
   ```bash
   openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt -out rsa_key.p8
   openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
   ```
   Upload public key to target Snowflake user profile.

5. **Initialize Snowflake roles and warehouse**  
   Execute `sql/01_setup/01_create_core_objects.sql` as `ACCOUNTADMIN`.

6. **Verify grants**  
   ```sql
   SHOW GRANTS TO ROLE SFE_CASINO_DEMO_ADMIN;
   SHOW GRANTS TO ROLE CASINO_HOST_ANALYST;
   ```

## Verification
- `SHOW WAREHOUSES LIKE 'SFE_CASINO_HOST_WH'` returns the demo warehouse  
- `SHOW ROLES LIKE 'SFE_CASINO_DEMO_ADMIN'` / `CASINO_HOST_ANALYST` return expected roles  
- No errors when executing setup script

## Troubleshooting
- **Warehouse already exists** → Adjust script to skip `CREATE OR REPLACE` or use isolated account  
- **Insufficient privileges** → Confirm session role is `ACCOUNTADMIN` before running setup  
- **Key pair login failures** → Validate private key path and ensure public key uploaded to Snowflake user

