/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Stage player profiles
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Cleanse and enrich RAW_INGESTION.PLAYERS into STAGING_LAYER.STG_PLAYERS with
 *   standardized demographic values, tenure metrics, and VIP indicators.
 *
 * OBJECTS CREATED:
 *   - STAGING_LAYER.STG_PLAYERS
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE STAGING_LAYER.STG_PLAYERS AS
WITH base AS (
    SELECT
        player_id,
        player_guid,
        loyalty_join_date,
        player_tier,
        age_group,
        gender,
        home_state,
        home_zip,
        preferred_game_type,
        average_session_minutes,
        visit_frequency_per_month,
        average_daily_theoretical,
        lifetime_theoretical,
        lifetime_actual_loss,
        lifetime_comp_value,
        marketing_opt_in,
        host_assigned,
        host_employee_id,
        created_at,
        updated_at,
        DATEDIFF('day', loyalty_join_date, CURRENT_DATE()) AS loyalty_tenure_days
    FROM RAW_INGESTION.PLAYERS
)
SELECT
    player_id,
    player_guid,
    loyalty_join_date,
    UPPER(player_tier)                                         AS player_tier,
    age_group,
    INITCAP(gender)                                            AS gender,
    UPPER(home_state)                                          AS home_state,
    home_zip,
    INITCAP(preferred_game_type)                               AS preferred_game_type,
    ROUND(average_session_minutes, 2)                          AS average_session_minutes,
    ROUND(visit_frequency_per_month, 2)                        AS visit_frequency_per_month,
    ROUND(average_daily_theoretical, 2)                        AS average_daily_theoretical,
    ROUND(lifetime_theoretical, 2)                             AS lifetime_theoretical,
    ROUND(lifetime_actual_loss, 2)                             AS lifetime_actual_loss,
    ROUND(lifetime_comp_value, 2)                              AS lifetime_comp_value,
    marketing_opt_in,
    host_assigned,
    host_employee_id,
    loyalty_tenure_days,
    CASE
        WHEN player_tier IN ('PLATINUM','DIAMOND') THEN TRUE
        ELSE FALSE
    END                                                        AS is_vip,
    CASE
        WHEN average_daily_theoretical >= 10000 THEN 'Ultra High'
        WHEN average_daily_theoretical >= 5000 THEN 'High'
        WHEN average_daily_theoretical >= 1500 THEN 'Medium'
        ELSE 'Core'
    END                                                        AS adt_segment,
    created_at,
    updated_at,
    CURRENT_TIMESTAMP()                                        AS staged_at
FROM base;

