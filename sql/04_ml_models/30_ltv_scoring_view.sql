/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Create V_PLAYER_LTV_SCORES view
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Generate RFM-based lifetime value score and quintile segmentation for players.
 *
 * OBJECTS CREATED:
 *   - ANALYTICS_LAYER.V_PLAYER_LTV_SCORES
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE VIEW ANALYTICS_LAYER.V_PLAYER_LTV_SCORES AS
WITH feature_base AS (
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
        sessions_last_90d,
        total_wagered_last_90d,
        total_theoretical_amount / NULLIF(loyalty_tenure_days, 0) AS theoretical_per_day
    FROM ANALYTICS_LAYER.V_PLAYER_FEATURES
),
scored AS (
    SELECT
        fb.*,
        6 - NTILE(5) OVER (ORDER BY days_since_last_session ASC NULLS LAST) AS recency_score,
        NTILE(5) OVER (ORDER BY sessions_last_90d DESC NULLS LAST)          AS frequency_score,
        NTILE(5) OVER (ORDER BY total_wagered_last_90d DESC NULLS LAST)     AS monetary_score,
        NTILE(100) OVER (ORDER BY total_theoretical_amount DESC NULLS LAST) AS ltv_percentile_rank
    FROM feature_base fb
)
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
    total_wagered_last_90d,
    recency_score,
    frequency_score,
    monetary_score,
    ROUND((recency_score * 0.3) + (frequency_score * 0.3) + (monetary_score * 0.4), 2)
                                                            AS ltv_score,
    CASE
        WHEN monetary_score >= 5 AND recency_score >= 4 THEN 'VIP'
        WHEN monetary_score >= 4 AND frequency_score >= 4 THEN 'High Value'
        WHEN monetary_score >= 3 AND frequency_score >= 3 THEN 'Growth'
        WHEN monetary_score >= 2 THEN 'Core'
        ELSE 'Dormant'
    END                                                    AS ltv_segment,
    101 - ltv_percentile_rank                              AS ltv_percentile,
    theoretical_per_day,
    CURRENT_TIMESTAMP()                                    AS scored_at
FROM scored;

