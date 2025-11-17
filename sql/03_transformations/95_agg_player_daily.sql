/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Build AGG_PLAYER_DAILY
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Aggregate session-level data into daily metrics per player for trend
 *   analysis and ML feature creation.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.AGG_PLAYER_DAILY
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE ANALYTICS_LAYER.AGG_PLAYER_DAILY AS
SELECT
    player_id,
    session_date                                        AS activity_date,
    COUNT(*)                                            AS session_count,
    SUM(total_wagered_amount)                           AS total_wagered_amount,
    SUM(total_won_amount)                               AS total_won_amount,
    SUM(net_win_amount)                                 AS total_net_win_amount,
    SUM(theoretical_win_amount)                         AS total_theoretical_amount,
    SUM(comp_points_earned)                             AS total_comp_points,
    COUNT_IF(host_interaction_flag)                     AS host_touch_count,
    SUM(CASE WHEN day_part = 'Evening' THEN 1 ELSE 0 END) AS evening_sessions,
    SUM(CASE WHEN visit_sequence_bucket = 'Trip Starter' THEN 1 ELSE 0 END)
                                                       AS trip_starter_count,
    MAX(session_duration_minutes)                       AS max_session_duration_minutes,
    MIN(session_duration_minutes)                       AS min_session_duration_minutes,
    AVG(session_duration_minutes)                       AS avg_session_duration_minutes,
    CURRENT_TIMESTAMP()                                 AS built_at
FROM ANALYTICS_LAYER.FCT_GAMING_SESSION
GROUP BY player_id, session_date;

