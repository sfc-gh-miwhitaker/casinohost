/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Build DIM_PLAYER
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create ANALYTICS_LAYER.DIM_PLAYER with consolidated player attributes,
 *   tenure metrics, and behavioral aggregates sourced from staging tables.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.DIM_PLAYER
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE ANALYTICS_LAYER.DIM_PLAYER AS
WITH session_stats AS (
    SELECT
        player_id,
        COUNT(*)                                       AS total_sessions,
        COUNT_IF(host_interaction_flag)                AS host_touch_sessions,
        SUM(total_wagered_amount)                      AS total_wagered_amount,
        SUM(total_won_amount)                          AS total_won_amount,
        SUM(net_win_amount)                            AS total_net_win_amount,
        SUM(theoretical_win_amount)                    AS total_theoretical_amount,
        SUM(comp_points_earned)                        AS total_comp_points,
        MAX(session_start_ts)                          AS last_session_ts,
        MIN(session_start_ts)                          AS first_session_ts,
        SUM(
            CASE
                WHEN session_start_ts >= DATEADD(day, -30, CURRENT_TIMESTAMP())
                THEN 1 ELSE 0
            END
        )                                              AS sessions_last_30d,
        SUM(
            CASE
                WHEN session_start_ts >= DATEADD(day, -90, CURRENT_TIMESTAMP())
                THEN 1 ELSE 0
            END
        )                                              AS sessions_last_90d
    FROM STAGING_LAYER.STG_GAMING_SESSIONS
    GROUP BY player_id
),
comp_stats AS (
    SELECT
        player_id,
        COUNT(*)                                       AS total_comps_issued,
        SUM(CASE WHEN redemption_status = 'Redeemed' THEN comp_value_amount ELSE 0 END)
                                                     AS redeemed_comp_value,
        SUM(CASE WHEN redemption_status = 'Redeemed' THEN 1 ELSE 0 END)
                                                     AS comps_redeemed_count,
        SUM(comp_value_amount)                        AS total_comp_value,
        AVG(NULLIF(days_to_redeem, 0))                AS avg_days_to_redeem
    FROM STAGING_LAYER.STG_COMPS_HISTORY
    GROUP BY player_id
)
SELECT
    p.player_id,
    p.player_guid,
    p.loyalty_join_date,
    p.player_tier,
    p.age_group,
    p.gender,
    p.home_state,
    p.home_zip,
    p.preferred_game_type,
    p.average_session_minutes,
    p.visit_frequency_per_month,
    p.average_daily_theoretical,
    p.lifetime_theoretical,
    p.lifetime_actual_loss,
    p.lifetime_comp_value,
    p.marketing_opt_in,
    p.host_assigned,
    p.host_employee_id,
    p.loyalty_tenure_days,
    p.is_vip,
    p.adt_segment,
    NVL(s.total_sessions, 0)                           AS total_sessions,
    NVL(s.host_touch_sessions, 0)                      AS sessions_with_host_touch,
    NVL(s.total_wagered_amount, 0)                     AS total_wagered_amount,
    NVL(s.total_won_amount, 0)                         AS total_won_amount,
    NVL(s.total_net_win_amount, 0)                     AS total_net_win_amount,
    NVL(s.total_theoretical_amount, 0)                 AS total_theoretical_amount,
    NVL(s.total_comp_points, 0)                        AS total_comp_points,
    s.last_session_ts,
    s.first_session_ts,
    NVL(s.sessions_last_30d, 0)                        AS sessions_last_30d,
    NVL(s.sessions_last_90d, 0)                        AS sessions_last_90d,
    NVL(c.total_comps_issued, 0)                       AS total_comps_issued,
    NVL(c.total_comp_value, 0)                         AS total_comp_value,
    NVL(c.redeemed_comp_value, 0)                      AS redeemed_comp_value,
    NVL(c.comps_redeemed_count, 0)                     AS comps_redeemed_count,
    NVL(c.avg_days_to_redeem, 0)                       AS avg_days_to_redeem,
    DATEDIFF('day', NVL(s.last_session_ts, p.loyalty_join_date), CURRENT_DATE())
                                                      AS days_since_last_session,
    CASE
        WHEN NVL(s.total_sessions, 0) = 0 THEN 0
        ELSE ROUND(NVL(s.total_comp_points, 0) / s.total_sessions, 2)
    END                                                AS avg_comp_points_per_session,
    CASE
        WHEN NVL(s.total_sessions, 0) = 0 THEN 0
        ELSE ROUND(NVL(s.total_theoretical_amount, 0) / s.total_sessions, 2)
    END                                                AS avg_theoretical_per_session,
    CASE
        WHEN NVL(s.total_wagered_amount, 0) = 0 THEN 0
        ELSE ROUND(NVL(s.total_net_win_amount, 0) / s.total_wagered_amount, 4)
    END                                                AS net_margin_pct,
    p.created_at,
    p.updated_at,
    CURRENT_TIMESTAMP()                                AS built_at
FROM STAGING_LAYER.STG_PLAYERS p
LEFT JOIN session_stats s
  ON s.player_id = p.player_id
LEFT JOIN comp_stats c
  ON c.player_id = p.player_id;

