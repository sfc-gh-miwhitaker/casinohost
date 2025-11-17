/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Build FCT_TRANSACTION
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create ANALYTICS_LAYER.FCT_TRANSACTION at the wager-event grain with links
 *   to players, games, and sessions.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.FCT_TRANSACTION
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE ANALYTICS_LAYER.FCT_TRANSACTION AS
SELECT
    t.transaction_id,
    t.session_id,
    t.player_id,
    t.game_id,
    p.player_tier,
    g.game_type,
    t.transaction_ts,
    t.transaction_type,
    t.bet_amount,
    t.payout_amount,
    t.net_amount,
    t.theoretical_win_amount,
    t.outcome,
    t.is_bonus,
    t.is_bet_event,
    t.is_win_event,
    t.is_comp_event,
    DATE(t.transaction_ts)                          AS transaction_date,
    DATE_TRUNC('hour', t.transaction_ts)            AS transaction_hour,
    t.staged_at,
    CURRENT_TIMESTAMP()                             AS built_at
FROM STAGING_LAYER.STG_TRANSACTIONS t
LEFT JOIN ANALYTICS_LAYER.DIM_PLAYER p
  ON p.player_id = t.player_id
LEFT JOIN ANALYTICS_LAYER.DIM_GAME g
  ON g.game_id = t.game_id;

