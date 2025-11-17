/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Generate synthetic player profiles
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Populate RAW_INGESTION.PLAYERS with 50K realistic player records using
 *   Snowflake native GENERATOR functions. Distributions are weighted by loyalty
 *   tier to emulate real casino player populations.
 *
 * OBJECTS MODIFIED:
 *   - RAW_INGESTION.PLAYERS (50K rows)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA RAW_INGESTION;

TRUNCATE TABLE PLAYERS;

WITH base AS (
    SELECT
        SEQ8()                                       AS seq_id,
        UNIFORM(0, 100, RANDOM())                   AS tier_selector,
        UNIFORM(0, 100, RANDOM())                   AS gender_selector,
        UNIFORM(0, 1000, RANDOM())                  AS geo_selector,
        UNIFORM(0, 365 * 3, RANDOM())               AS loyalty_days_ago,
        UNIFORM(0, 100, RANDOM())                   AS preference_selector,
        UNIFORM(0, 100, RANDOM())                   AS host_assignment_selector,
        UNIFORM(0, 100, RANDOM())                   AS marketing_selector,
        NORMALLY_DISTRIBUTED_RANDOM(90, 35, RANDOM()) AS avg_session_minutes,
        NORMALLY_DISTRIBUTED_RANDOM(6, 2, RANDOM())   AS monthly_visits,
        NORMALLY_DISTRIBUTED_RANDOM(600, 250, RANDOM()) AS adt_value
    FROM TABLE(GENERATOR(ROWCOUNT => 50000))
),
player_profiles AS (
    SELECT
        seq_id + 1                                               AS player_id,
        UUID_STRING()                                            AS player_guid,
        DATEADD(day, -loyalty_days_ago, CURRENT_DATE())          AS loyalty_join_date,
        DATEDIFF(
            'day',
            DATEADD(day, -loyalty_days_ago, CURRENT_DATE()),
            CURRENT_DATE()
        )                                                        AS tenure_days,
        CASE
            WHEN tier_selector < 50 THEN 'Bronze'
            WHEN tier_selector < 80 THEN 'Silver'
            WHEN tier_selector < 95 THEN 'Gold'
            WHEN tier_selector < 99 THEN 'Platinum'
            ELSE 'Diamond'
        END                                                      AS player_tier,
        CASE
            WHEN MOD(seq_id, 5) = 0 THEN '21-29'
            WHEN MOD(seq_id, 5) = 1 THEN '30-39'
            WHEN MOD(seq_id, 5) = 2 THEN '40-49'
            WHEN MOD(seq_id, 5) = 3 THEN '50-59'
            ELSE '60+'
        END                                                      AS age_group,
        CASE
            WHEN gender_selector < 49 THEN 'Female'
            WHEN gender_selector < 98 THEN 'Male'
            WHEN gender_selector < 99 THEN 'Non-Binary'
            ELSE 'Prefer Not'
        END                                                      AS gender,
        ARRAY_GET(
            ARRAY_CONSTRUCT('NV','CA','AZ','WA','OR','TX','IL','NY','NJ','FL'),
            MOD(geo_selector, 10)
        )                                                        AS home_state,
        TO_VARCHAR(10000 + geo_selector)                         AS home_zip,
        CASE
            WHEN preference_selector < 55 THEN 'Slots'
            WHEN preference_selector < 80 THEN 'Table'
            WHEN preference_selector < 92 THEN 'Poker'
            ELSE 'Sportsbook'
        END                                                      AS preferred_game_type,
        LEAST(GREATEST(avg_session_minutes, 25), 360)            AS average_session_minutes,
        LEAST(GREATEST(monthly_visits, 1), 20)                   AS visit_frequency_per_month,
        LEAST(GREATEST(adt_value, 50), 20000)                    AS average_daily_theoretical,
        LEAST(GREATEST(adt_value * tenure_days, 1000), 2000000)
                                                                AS lifetime_theoretical,
        LEAST(GREATEST((average_daily_theoretical * 0.92)
              * tenure_days, 500), 1500000)
                                                                AS lifetime_actual_loss,
        LEAST(GREATEST((average_daily_theoretical * 0.3)
              * tenure_days, 300), 600000)
                                                                AS lifetime_comp_value,
        marketing_selector < 75                                 AS marketing_opt_in,
        CASE
            WHEN player_tier IN ('Platinum','Diamond') THEN TRUE
            WHEN player_tier = 'Gold' AND host_assignment_selector < 40 THEN TRUE
            ELSE FALSE
        END                                                      AS host_assigned,
        CASE
            WHEN host_assigned THEN CONCAT('HOST-', LPAD(TO_VARCHAR(1 + MOD(seq_id, 120)), 4, '0'))
            ELSE NULL
        END                                                      AS host_employee_id
    FROM base
)
INSERT INTO PLAYERS (
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
    updated_at
)
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
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM player_profiles;

