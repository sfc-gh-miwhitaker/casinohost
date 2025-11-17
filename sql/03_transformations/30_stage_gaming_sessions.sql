/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Stage gaming sessions
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Normalize RAW_INGESTION.GAMING_SESSIONS into STAGING_LAYER.STG_GAMING_SESSIONS
 *   with derived metrics for behavior analysis.
 *
 * OBJECTS CREATED:
 *   - STAGING_LAYER.STG_GAMING_SESSIONS
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE STAGING_LAYER.STG_GAMING_SESSIONS AS
SELECT
    session_id,
    player_id,
    session_start_ts,
    session_end_ts,
    session_duration_minutes,
    total_wagered_amount,
    total_won_amount,
    net_win_amount,
    theoretical_win_amount,
    comp_points_earned,
    NVL(host_interaction_flag, FALSE)                       AS host_interaction_flag,
    INITCAP(favorite_game_type)                             AS favorite_game_type,
    INITCAP(day_part)                                       AS day_part,
    visit_sequence_in_month,
    DATE(session_start_ts)                                  AS session_date,
    ROUND(total_wagered_amount / NULLIF(session_duration_minutes, 0), 2)
                                                           AS wager_per_minute,
    ROUND(NULLIF(total_won_amount, 0) / NULLIF(total_wagered_amount, 0), 4)
                                                           AS payout_ratio,
    ROUND(NULLIF(net_win_amount, 0) / NULLIF(total_wagered_amount, 0), 4)
                                                           AS net_margin_pct,
    CASE
        WHEN visit_sequence_in_month = 1 THEN 'Trip Starter'
        WHEN visit_sequence_in_month BETWEEN 2 AND 5 THEN 'Core Visit'
        ELSE 'High Frequency'
    END                                                     AS visit_sequence_bucket,
    CURRENT_TIMESTAMP()                                     AS staged_at
FROM RAW_INGESTION.GAMING_SESSIONS;

