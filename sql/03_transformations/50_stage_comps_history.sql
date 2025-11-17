/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Stage comps history
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Normalize RAW_INGESTION.COMPS_HISTORY into STAGING_LAYER.STG_COMPS_HISTORY
 *   with categorical consolidations and time-to-redeem metrics.
 *
 * OBJECTS CREATED:
 *   - STAGING_LAYER.STG_COMPS_HISTORY
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE STAGING_LAYER.STG_COMPS_HISTORY AS
SELECT
    comp_id,
    player_id,
    comp_date,
    INITCAP(comp_type)                          AS comp_type,
    INITCAP(comp_channel)                       AS comp_channel,
    ROUND(comp_value_amount, 2)                 AS comp_value_amount,
    host_employee_id,
    UPPER(issued_by_system)                     AS issued_by_system,
    INITCAP(redemption_status)                  AS redemption_status,
    redemption_date,
    trip_id,
    ROUND(theoretical_basis_amount, 2)          AS theoretical_basis_amount,
    notes,
    DATEDIFF('day', comp_date, NVL(redemption_date, CURRENT_DATE()))
                                                AS days_to_redeem,
    CASE
        WHEN comp_type IN ('Meal','Room') THEN 'Experience'
        WHEN comp_type IN ('Cashback','Free Play') THEN 'Monetary'
        ELSE 'Entertainment'
    END                                         AS comp_category,
    CURRENT_TIMESTAMP()                         AS staged_at
FROM RAW_INGESTION.COMPS_HISTORY;

