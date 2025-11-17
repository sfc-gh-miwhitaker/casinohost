/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Train churn classification model and create scoring view
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Prepare training dataset, train a Cortex ML classification model, and expose
 *   prediction scores via ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.PLAYER_CHURN_TRAINING (table)
 *   - ANALYTICS_LAYER.PLAYER_CHURN_MODEL (Snowflake ML model)
 *   - ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES (view)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

-- Assemble labeled training dataset using recent activity pattern.
CREATE OR REPLACE TABLE ANALYTICS_LAYER.PLAYER_CHURN_TRAINING AS
SELECT
    player_id,
    player_tier,
    is_vip,
    adt_segment,
    loyalty_tenure_days,
    days_since_last_session,
    total_sessions,
    total_wagered_amount,
    total_theoretical_amount,
    total_comp_points,
    sessions_last_7d,
    sessions_last_30d,
    sessions_last_90d,
    total_wagered_last_30d,
    total_wagered_last_90d,
    theoretical_win_last_30d,
    theoretical_win_last_90d,
    comp_points_last_30d,
    host_touches_last_30d,
    comp_value_redeemed_30d,
    comp_value_issued_30d,
    avg_wager_per_session_30d,
    avg_theoretical_per_session_30d,
    lifetime_avg_wager_per_session,
    lifetime_avg_comp_points_per_session,
    net_margin_pct,
    CASE
        WHEN days_since_last_session > 60
             AND sessions_last_90d >= 2 THEN 1
        ELSE 0
    END AS churn_label
FROM ANALYTICS_LAYER.V_PLAYER_FEATURES
WHERE total_sessions >= 3;

-- Train classification model using Cortex ML.
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION MODEL ANALYTICS_LAYER.PLAYER_CHURN_MODEL
    INPUT (
        SELECT
            player_tier,
            is_vip,
            adt_segment,
            loyalty_tenure_days,
            days_since_last_session,
            total_sessions,
            total_wagered_amount,
            total_theoretical_amount,
            total_comp_points,
            sessions_last_7d,
            sessions_last_30d,
            sessions_last_90d,
            total_wagered_last_30d,
            total_wagered_last_90d,
            theoretical_win_last_30d,
            theoretical_win_last_90d,
            comp_points_last_30d,
            host_touches_last_30d,
            comp_value_redeemed_30d,
            comp_value_issued_30d,
            avg_wager_per_session_30d,
            avg_theoretical_per_session_30d,
            lifetime_avg_wager_per_session,
            lifetime_avg_comp_points_per_session,
            net_margin_pct,
            churn_label
        FROM ANALYTICS_LAYER.PLAYER_CHURN_TRAINING
    )
    TARGET churn_label
    OPTIONS (
        MODEL_TYPE = 'AUTO',
        AUTO_TUNE = TRUE,
        SEED = 42
    );

-- Create scoring view leveraging trained model.
CREATE OR REPLACE VIEW ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES AS
SELECT
    f.player_id,
    prediction:probability::FLOAT                            AS churn_probability,
    CASE
        WHEN prediction:class = 1 THEN 'High Risk'
        WHEN prediction:probability >= 0.4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END                                                      AS churn_risk_segment,
    prediction:class::INT                                    AS churn_prediction_flag,
    f.player_tier,
    f.is_vip,
    f.days_since_last_session,
    f.sessions_last_30d,
    f.total_wagered_last_30d,
    f.host_touches_last_30d,
    f.comp_value_redeemed_30d,
    CURRENT_TIMESTAMP()                                      AS scored_at
FROM ANALYTICS_LAYER.V_PLAYER_FEATURES f,
LATERAL SNOWFLAKE.ML.CLASSIFICATION(
    MODEL => 'ANALYTICS_LAYER.PLAYER_CHURN_MODEL',
    INPUT => OBJECT_CONSTRUCT(
        'player_tier', f.player_tier,
        'is_vip', f.is_vip,
        'adt_segment', f.adt_segment,
        'loyalty_tenure_days', f.loyalty_tenure_days,
        'days_since_last_session', f.days_since_last_session,
        'total_sessions', f.total_sessions,
        'total_wagered_amount', f.total_wagered_amount,
        'total_theoretical_amount', f.total_theoretical_amount,
        'total_comp_points', f.total_comp_points,
        'sessions_last_7d', f.sessions_last_7d,
        'sessions_last_30d', f.sessions_last_30d,
        'sessions_last_90d', f.sessions_last_90d,
        'total_wagered_last_30d', f.total_wagered_last_30d,
        'total_wagered_last_90d', f.total_wagered_last_90d,
        'theoretical_win_last_30d', f.theoretical_win_last_30d,
        'theoretical_win_last_90d', f.theoretical_win_last_90d,
        'comp_points_last_30d', f.comp_points_last_30d,
        'host_touches_last_30d', f.host_touches_last_30d,
        'comp_value_redeemed_30d', f.comp_value_redeemed_30d,
        'comp_value_issued_30d', f.comp_value_issued_30d,
        'avg_wager_per_session_30d', f.avg_wager_per_session_30d,
        'avg_theoretical_per_session_30d', f.avg_theoretical_per_session_30d,
        'lifetime_avg_wager_per_session', f.lifetime_avg_wager_per_session,
        'lifetime_avg_comp_points_per_session', f.lifetime_avg_comp_points_per_session,
        'net_margin_pct', f.net_margin_pct
    )
) prediction;

