/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Create V_PLAYER_FEATURES view
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Assemble feature-rich view supporting churn, LTV, and recommendation models.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.V_PLAYER_FEATURES
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE VIEW ANALYTICS_LAYER.V_PLAYER_FEATURES AS
WITH recent_sessions AS (
    SELECT
        player_id,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -7, CURRENT_TIMESTAMP())
            THEN 1 ELSE 0 END)                          AS sessions_last_7d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -30, CURRENT_TIMESTAMP())
            THEN 1 ELSE 0 END)                          AS sessions_last_30d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -90, CURRENT_TIMESTAMP())
            THEN 1 ELSE 0 END)                          AS sessions_last_90d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -30, CURRENT_TIMESTAMP())
            THEN total_wagered_amount ELSE 0 END)       AS wagered_last_30d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -90, CURRENT_TIMESTAMP())
            THEN total_wagered_amount ELSE 0 END)       AS wagered_last_90d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -30, CURRENT_TIMESTAMP())
            THEN theoretical_win_amount ELSE 0 END)     AS theoretical_last_30d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -90, CURRENT_TIMESTAMP())
            THEN theoretical_win_amount ELSE 0 END)     AS theoretical_last_90d,
        SUM(CASE WHEN session_start_ts >= DATEADD(day, -30, CURRENT_TIMESTAMP())
            THEN comp_points_earned ELSE 0 END)         AS comp_points_last_30d,
        SUM(CASE WHEN host_interaction_flag
                 AND session_start_ts >= DATEADD(day, -30, CURRENT_TIMESTAMP())
            THEN 1 ELSE 0 END)                          AS host_touches_last_30d
    FROM ANALYTICS_LAYER.FCT_GAMING_SESSION
    GROUP BY player_id
),
day_part_prefs AS (
    SELECT
        player_id,
        ARRAY_AGG(OBJECT_CONSTRUCT('day_part', day_part, 'count', session_count)
                  ORDER BY session_count DESC) AS day_part_array
    FROM (
        SELECT
            player_id,
            day_part,
            COUNT(*) AS session_count
        FROM ANALYTICS_LAYER.FCT_GAMING_SESSION
        GROUP BY player_id, day_part
    )
    GROUP BY player_id
),
favorite_day_part AS (
    SELECT
        player_id,
        COALESCE(day_part_array[0]:day_part::STRING, 'Evening') AS favorite_day_part
    FROM day_part_prefs
),
comp_recent AS (
    SELECT
        player_id,
        SUM(CASE WHEN redemption_status = 'Redeemed'
                 AND comp_date >= DATEADD(day, -30, CURRENT_DATE())
            THEN comp_value_amount ELSE 0 END)          AS comp_value_redeemed_30d,
        SUM(CASE WHEN comp_date >= DATEADD(day, -30, CURRENT_DATE())
            THEN comp_value_amount ELSE 0 END)          AS comps_issued_30d
    FROM STAGING_LAYER.STG_COMPS_HISTORY
    GROUP BY player_id
)
SELECT
    d.player_id,
    d.player_guid,
    d.player_tier,
    d.age_group,
    d.gender,
    d.home_state,
    d.preferred_game_type,
    d.is_vip,
    d.adt_segment,
    d.loyalty_tenure_days,
    d.days_since_last_session,
    d.total_sessions,
    d.total_wagered_amount,
    d.total_theoretical_amount,
    d.total_comp_points,
    d.total_comps_issued,
    d.total_comp_value,
    d.redeemed_comp_value,
    d.avg_theoretical_per_session,
    d.avg_comp_points_per_session,
    d.net_margin_pct,
    COALESCE(rs.sessions_last_7d, 0)                     AS sessions_last_7d,
    COALESCE(rs.sessions_last_30d, 0)                    AS sessions_last_30d,
    COALESCE(rs.sessions_last_90d, 0)                    AS sessions_last_90d,
    COALESCE(rs.wagered_last_30d, 0)                     AS total_wagered_last_30d,
    COALESCE(rs.wagered_last_90d, 0)                     AS total_wagered_last_90d,
    COALESCE(rs.theoretical_last_30d, 0)                 AS theoretical_win_last_30d,
    COALESCE(rs.theoretical_last_90d, 0)                 AS theoretical_win_last_90d,
    COALESCE(rs.comp_points_last_30d, 0)                 AS comp_points_last_30d,
    COALESCE(rs.host_touches_last_30d, 0)                AS host_touches_last_30d,
    COALESCE(fr.favorite_day_part, 'Evening')            AS favorite_day_part,
    COALESCE(cr.comp_value_redeemed_30d, 0)              AS comp_value_redeemed_30d,
    COALESCE(cr.comps_issued_30d, 0)                     AS comp_value_issued_30d,
    CASE
        WHEN COALESCE(rs.sessions_last_30d, 0) = 0 THEN 0
        ELSE COALESCE(rs.wagered_last_30d, 0) / rs.sessions_last_30d
    END                                                  AS avg_wager_per_session_30d,
    CASE
        WHEN COALESCE(rs.sessions_last_30d, 0) = 0 THEN 0
        ELSE COALESCE(rs.theoretical_last_30d, 0) / rs.sessions_last_30d
    END                                                  AS avg_theoretical_per_session_30d,
    CASE
        WHEN d.total_sessions = 0 THEN 0
        ELSE d.total_comp_points / d.total_sessions
    END                                                  AS lifetime_avg_comp_points_per_session,
    CASE
        WHEN d.total_sessions = 0 THEN 0
        ELSE d.total_wagered_amount / d.total_sessions
    END                                                  AS lifetime_avg_wager_per_session,
    CURRENT_TIMESTAMP()                                  AS built_at
FROM ANALYTICS_LAYER.DIM_PLAYER d
LEFT JOIN recent_sessions rs
  ON rs.player_id = d.player_id
LEFT JOIN favorite_day_part fr
  ON fr.player_id = d.player_id
LEFT JOIN comp_recent cr
  ON cr.player_id = d.player_id;

