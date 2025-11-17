/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Build AGG_PLAYER_LIFETIME
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Summarize lifetime performance metrics per player leveraging dimensional
 *   tables and aggregates for ML readiness.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.AGG_PLAYER_LIFETIME
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE ANALYTICS_LAYER.AGG_PLAYER_LIFETIME AS
SELECT
    d.player_id,
    d.player_guid,
    d.player_tier,
    d.adt_segment,
    d.is_vip,
    d.loyalty_join_date,
    d.loyalty_tenure_days,
    d.days_since_last_session,
    d.total_sessions,
    d.total_wagered_amount,
    d.total_won_amount,
    d.total_net_win_amount,
    d.total_theoretical_amount,
    d.total_comp_points,
    d.total_comps_issued,
    d.total_comp_value,
    d.redeemed_comp_value,
    d.comps_redeemed_count,
    d.avg_days_to_redeem,
    d.avg_comp_points_per_session,
    d.avg_theoretical_per_session,
    d.net_margin_pct,
    ad.sessions_last_30d,
    ad.sessions_last_90d,
    COALESCE(sum30.total_wagered_amount_30d, 0)          AS total_wagered_amount_30d,
    COALESCE(sum30.total_theoretical_amount_30d, 0)      AS total_theoretical_amount_30d,
    COALESCE(sum30.total_comp_points_30d, 0)             AS total_comp_points_30d,
    CURRENT_TIMESTAMP()                                  AS built_at
FROM ANALYTICS_LAYER.DIM_PLAYER d
LEFT JOIN (
    SELECT
        player_id,
        SUM(CASE WHEN activity_date >= DATEADD(day, -30, CURRENT_DATE()) THEN session_count ELSE 0 END) AS sessions_last_30d,
        SUM(CASE WHEN activity_date >= DATEADD(day, -90, CURRENT_DATE()) THEN session_count ELSE 0 END) AS sessions_last_90d
    FROM ANALYTICS_LAYER.AGG_PLAYER_DAILY
    GROUP BY player_id
) ad
  ON ad.player_id = d.player_id
LEFT JOIN (
    SELECT
        player_id,
        SUM(CASE WHEN activity_date >= DATEADD(day, -30, CURRENT_DATE()) THEN total_wagered_amount ELSE 0 END)
                                                                AS total_wagered_amount_30d,
        SUM(CASE WHEN activity_date >= DATEADD(day, -30, CURRENT_DATE()) THEN total_theoretical_amount ELSE 0 END)
                                                                AS total_theoretical_amount_30d,
        SUM(CASE WHEN activity_date >= DATEADD(day, -30, CURRENT_DATE()) THEN total_comp_points ELSE 0 END)
                                                                AS total_comp_points_30d
    FROM ANALYTICS_LAYER.AGG_PLAYER_DAILY
    GROUP BY player_id
) sum30
  ON sum30.player_id = d.player_id;

