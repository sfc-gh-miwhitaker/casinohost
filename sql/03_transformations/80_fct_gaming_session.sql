/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Build FCT_GAMING_SESSION
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create ANALYTICS_LAYER.FCT_GAMING_SESSION capturing grain at player-session
 *   level with keys to dimensional tables and derived measures.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.FCT_GAMING_SESSION
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE ANALYTICS_LAYER.FCT_GAMING_SESSION AS
SELECT
    s.session_id,
    s.player_id,
    d.player_tier,
    d.is_vip,
    d.adt_segment,
    s.favorite_game_type,
    s.session_start_ts,
    s.session_end_ts,
    s.session_duration_minutes,
    s.total_wagered_amount,
    s.total_won_amount,
    s.net_win_amount,
    s.theoretical_win_amount,
    s.comp_points_earned,
    s.host_interaction_flag,
    s.day_part,
    s.visit_sequence_in_month,
    s.session_date,
    s.wager_per_minute,
    s.payout_ratio,
    s.net_margin_pct,
    s.visit_sequence_bucket,
    s.staged_at,
    CURRENT_TIMESTAMP() AS built_at
FROM STAGING_LAYER.STG_GAMING_SESSIONS s
JOIN ANALYTICS_LAYER.DIM_PLAYER d
  ON d.player_id = s.player_id;

