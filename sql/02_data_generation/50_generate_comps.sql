/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Generate synthetic comps history
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Populate RAW_INGESTION.COMPS_HISTORY with 500K comp issuance events aligned
 *   to player tier, churn risk indicators, and host interactions.
 *
 * OBJECTS MODIFIED:
 *   - RAW_INGESTION.COMPS_HISTORY (500K rows)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA RAW_INGESTION;

TRUNCATE TABLE COMPS_HISTORY;

WITH comp_base AS (
    SELECT
        SEQ8()                               AS seq_id,
        UNIFORM(0, 365, RANDOM())           AS days_ago,
        UNIFORM(0, 100, RANDOM())           AS type_selector,
        UNIFORM(0, 100, RANDOM())           AS channel_selector,
        UNIFORM(0, 100, RANDOM())           AS redemption_selector,
        RANDOM()                            AS randomizer
    FROM TABLE(GENERATOR(ROWCOUNT => 500000))
),
player_sample AS (
    SELECT
        cb.seq_id,
        cb.days_ago,
        cb.type_selector,
        cb.channel_selector,
        cb.redemption_selector,
        cb.randomizer,
        MOD(cb.seq_id, 50000) + 1          AS player_slot
    FROM comp_base cb
),
comp_enriched AS (
    SELECT
        player_sample.seq_id,
        player_sample.days_ago,
        player_sample.type_selector,
        player_sample.channel_selector,
        player_sample.redemption_selector,
        player_sample.randomizer,
        p.player_id,
        p.player_tier,
        p.preferred_game_type,
        p.average_daily_theoretical,
        p.host_employee_id,
        CASE
            WHEN p.player_tier = 'Diamond' THEN 0.38
            WHEN p.player_tier = 'Platinum' THEN 0.33
            WHEN p.player_tier = 'Gold' THEN 0.27
            WHEN p.player_tier = 'Silver' THEN 0.20
            ELSE 0.15
        END                                 AS comp_percentage
    FROM player_sample
    JOIN PLAYERS p
      ON p.player_id = player_sample.player_slot
),
issued_comps AS (
    SELECT
        seq_id,
        player_id,
        player_tier,
        preferred_game_type,
        comp_percentage,
        average_daily_theoretical,
        host_employee_id,
        DATEADD(day, -days_ago, CURRENT_DATE())                   AS comp_date,
        CASE
            WHEN type_selector < 40 THEN 'Meal'
            WHEN type_selector < 65 THEN 'Room'
            WHEN type_selector < 80 THEN 'Show'
            WHEN type_selector < 90 THEN 'Free Play'
            ELSE 'Cashback'
        END                                                       AS comp_type,
        CASE
            WHEN channel_selector < 45 THEN 'In-Person'
            WHEN channel_selector < 70 THEN 'Outbound Call'
            WHEN channel_selector < 90 THEN 'Mobile App'
            ELSE 'Email'
        END                                                       AS comp_channel,
        CASE
            WHEN redemption_selector < 70 THEN 'Redeemed'
            WHEN redemption_selector < 85 THEN 'Issued'
            WHEN redemption_selector < 95 THEN 'Expired'
            ELSE 'Cancelled'
        END                                                       AS redemption_status,
        CASE
            WHEN redemption_selector < 70 THEN DATEADD(day, UNIFORM(0, 30, RANDOM()), DATEADD(day, -days_ago, CURRENT_DATE()))
            ELSE NULL
        END                                                       AS redemption_date,
        ROUND(GREATEST(
            average_daily_theoretical * comp_percentage * (0.4 + randomizer),
            20
        ), 2)                                                     AS comp_value_amount,
        ROUND(GREATEST(
            average_daily_theoretical * (0.8 + randomizer),
            50
        ), 2)                                                     AS theoretical_basis_amount,
        randomizer
    FROM comp_enriched
),
finalized AS (
    SELECT
        seq_id,
        player_id,
        comp_date,
        comp_type,
        comp_channel,
        comp_value_amount,
        host_employee_id,
        CASE
            WHEN host_employee_id IS NOT NULL AND randomizer < 0.65 THEN host_employee_id
            WHEN randomizer < 0.75 THEN CONCAT('HOST-', LPAD(TO_VARCHAR(200 + MOD(seq_id, 60)), 4, '0'))
            ELSE NULL
        END                                                       AS issuing_host,
        CASE
            WHEN randomizer < 0.5 THEN 'HOST_TOOL'
            WHEN randomizer < 0.8 THEN 'CRM_AUTOMATION'
            ELSE 'SYSTEM_SUGGESTED'
        END                                                       AS issued_by_system,
        redemption_status,
        redemption_date,
        CONCAT('TRIP-', LPAD(TO_VARCHAR((seq_id % 20000) + 1), 6, '0')) AS trip_id,
        theoretical_basis_amount,
        CASE
            WHEN comp_type = 'Cashback' THEN 'Retention offer for declining theoretical'
            WHEN comp_type = 'Free Play' THEN 'Incentive to boost midweek visits'
            WHEN comp_type = 'Room' THEN 'Complimentary suite for VIP stay'
            WHEN comp_type = 'Show' THEN 'Event ticket for loyalty appreciation'
            ELSE 'Dining comp for host engagement'
        END                                                       AS notes
    FROM issued_comps
)
INSERT INTO COMPS_HISTORY (
    comp_id,
    player_id,
    comp_date,
    comp_type,
    comp_channel,
    comp_value_amount,
    host_employee_id,
    issued_by_system,
    redemption_status,
    redemption_date,
    trip_id,
    theoretical_basis_amount,
    notes,
    created_at
)
SELECT
    seq_id + 1,
    player_id,
    comp_date,
    comp_type,
    comp_channel,
    comp_value_amount,
    issuing_host,
    issued_by_system,
    redemption_status,
    redemption_date,
    trip_id,
    theoretical_basis_amount,
    notes,
    CURRENT_TIMESTAMP()
FROM finalized;

