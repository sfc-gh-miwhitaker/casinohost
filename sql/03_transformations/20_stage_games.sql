/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Stage game catalog
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Clean RAW_INGESTION.GAMES into STAGING_LAYER.STG_GAMES with normalized names
 *   and risk metadata for downstream analytics.
 *
 * OBJECTS CREATED:
 *   - STAGING_LAYER.STG_GAMES
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE STAGING_LAYER.STG_GAMES AS
SELECT
    game_id,
    game_code,
    INITCAP(game_name)                     AS game_name,
    INITCAP(game_type)                     AS game_type,
    ROUND(house_edge_pct, 4)               AS house_edge_pct,
    INITCAP(volatility_rating)             AS volatility_rating,
    ROUND(min_bet_amount, 2)               AS min_bet_amount,
    ROUND(max_bet_amount, 2)               AS max_bet_amount,
    ROUND(average_session_length_minutes, 2) AS average_session_length_minutes,
    is_active,
    CASE
        WHEN house_edge_pct >= 0.08 THEN 'Premium Yield'
        WHEN house_edge_pct >= 0.05 THEN 'Core Yield'
        ELSE 'Low Yield'
    END                                    AS yield_category,
    created_at,
    CURRENT_TIMESTAMP()                    AS staged_at
FROM RAW_INGESTION.GAMES;

