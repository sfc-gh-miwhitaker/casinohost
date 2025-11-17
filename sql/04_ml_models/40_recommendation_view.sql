/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Create V_PLAYER_RECOMMENDATIONS view
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Combine LTV and churn scores with business heuristics to produce
 *   next-best-action recommendations and suggested comp values.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE VIEW ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS AS
WITH joined AS (
    SELECT
        f.player_id,
        f.player_tier,
        f.is_vip,
        f.days_since_last_session,
        f.sessions_last_30d,
        f.total_wagered_last_30d,
        f.total_theoretical_amount,
        f.total_comp_points,
        f.comp_value_redeemed_30d,
        churn.churn_probability,
        churn.churn_risk_segment,
        churn.churn_prediction_flag,
        ltv.ltv_score,
        ltv.ltv_segment
    FROM ANALYTICS_LAYER.V_PLAYER_FEATURES f
    JOIN ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES churn
      ON churn.player_id = f.player_id
    JOIN ANALYTICS_LAYER.V_PLAYER_LTV_SCORES ltv
      ON ltv.player_id = f.player_id
)
SELECT
    player_id,
    player_tier,
    is_vip,
    ltv_segment,
    churn_risk_segment,
    churn_probability,
    days_since_last_session,
    sessions_last_30d,
    total_wagered_last_30d,
    total_theoretical_amount,
    total_comp_points,
    comp_value_redeemed_30d,
    CASE
        WHEN ltv_segment = 'VIP' AND churn_probability >= 0.6 THEN
            'URGENT: Offer premium comp bundle (suite + dining + show) and personal host outreach'
        WHEN ltv_segment IN ('High Value','VIP') AND churn_probability BETWEEN 0.4 AND 0.6 THEN
            'Proactive: Schedule host check-in, evaluate tier upgrade, extend exclusive event invite'
        WHEN ltv_segment = 'Growth' AND churn_probability >= 0.5 THEN
            'Retention: Provide free play credits and highlight loyalty milestones'
        WHEN days_since_last_session > 30 AND total_wagered_last_30d = 0 AND ltv_segment IN ('High Value','Growth') THEN
            'Win-back: Send targeted offer on favorite game with bonus multipliers'
        WHEN ltv_segment = 'Dormant' AND churn_probability >= 0.7 THEN
            'Reactivation: Extend limited-time comeback offer and host welcome-back call'
        WHEN ltv_segment IN ('VIP','High Value') AND comp_value_redeemed_30d < 100 THEN
            'Nurture: Recommend experience-based comp (fine dining or show) to deepen loyalty'
        ELSE
            'Monitor: Maintain cadence with personalized messaging and track engagement'
    END AS recommended_action,
    CASE
        WHEN ltv_segment = 'VIP' AND churn_probability >= 0.6 THEN 200
        WHEN ltv_segment IN ('VIP','High Value') AND churn_probability BETWEEN 0.4 AND 0.6 THEN 125
        WHEN ltv_segment = 'Growth' AND churn_probability >= 0.5 THEN 80
        WHEN days_since_last_session > 30 AND ltv_segment IN ('High Value','Growth') THEN 75
        WHEN ltv_segment = 'Dormant' AND churn_probability >= 0.7 THEN 60
        WHEN ltv_segment IN ('VIP','High Value') THEN 100
        WHEN ltv_segment = 'Growth' THEN 50
        ELSE 25
    END AS suggested_comp_value_usd,
    CASE
        WHEN churn_probability >= 0.6 THEN 'High churn probability requires immediate retention strategy'
        WHEN ltv_segment IN ('VIP','High Value') THEN 'Maintain strong relationship with top-tier player'
        WHEN days_since_last_session > 30 THEN 'Extended inactivity window signals potential churn'
        WHEN comp_value_redeemed_30d < 50 THEN 'Under-utilization of comps—opportunity to increase engagement'
        ELSE 'Maintain engagement cadence and monitor behavior shifts'
    END AS recommendation_reason,
    CURRENT_TIMESTAMP() AS generated_at
FROM joined;

