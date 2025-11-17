/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Build DIM_GAME
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create ANALYTICS_LAYER.DIM_GAME summarizing performance metrics per game.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.DIM_GAME
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE ANALYTICS_LAYER.DIM_GAME AS
WITH transaction_stats AS (
    SELECT
        game_id,
        COUNT(*)                                         AS total_transactions,
        SUM(bet_amount)                                  AS total_bet_amount,
        SUM(payout_amount)                               AS total_payout_amount,
        SUM(net_amount)                                  AS total_net_amount,
        SUM(theoretical_win_amount)                      AS total_theoretical_amount,
        COUNT_IF(is_bonus)                               AS bonus_event_count
    FROM STAGING_LAYER.STG_TRANSACTIONS
    GROUP BY game_id
),
session_stats AS (
    SELECT
        favorite_game_type,
        COUNT(*)                                         AS sessions_played,
        SUM(total_wagered_amount)                        AS sessions_wagered_amount,
        SUM(theoretical_win_amount)                      AS sessions_theoretical,
        AVG(session_duration_minutes)                    AS avg_session_duration
    FROM STAGING_LAYER.STG_GAMING_SESSIONS
    GROUP BY favorite_game_type
)
SELECT
    g.game_id,
    g.game_code,
    g.game_name,
    g.game_type,
    g.house_edge_pct,
    g.volatility_rating,
    g.min_bet_amount,
    g.max_bet_amount,
    g.average_session_length_minutes,
    g.is_active,
    g.yield_category,
    NVL(t.total_transactions, 0)                         AS total_transactions,
    NVL(t.total_bet_amount, 0)                           AS total_bet_amount,
    NVL(t.total_payout_amount, 0)                        AS total_payout_amount,
    NVL(t.total_net_amount, 0)                           AS total_net_amount,
    NVL(t.total_theoretical_amount, 0)                   AS total_theoretical_amount,
    NVL(t.bonus_event_count, 0)                          AS bonus_event_count,
    NVL(s.sessions_played, 0)                            AS sessions_played,
    NVL(s.sessions_wagered_amount, 0)                    AS sessions_wagered_amount,
    NVL(s.sessions_theoretical, 0)                       AS sessions_theoretical,
    NVL(s.avg_session_duration, g.average_session_length_minutes)
                                                         AS avg_session_duration_minutes,
    CASE
        WHEN NVL(t.total_bet_amount, 0) = 0 THEN 0
        ELSE ROUND(NVL(t.total_net_amount, 0) / t.total_bet_amount, 4)
    END                                                   AS net_margin_pct,
    g.created_at,
    g.staged_at,
    CURRENT_TIMESTAMP()                                   AS built_at
FROM STAGING_LAYER.STG_GAMES g
LEFT JOIN transaction_stats t
  ON t.game_id = g.game_id
LEFT JOIN session_stats s
  ON s.favorite_game_type = g.game_type;

