/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Generate synthetic game catalog
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Populate RAW_INGESTION.GAMES with 200 representative casino games covering
 *   slots, table games, poker variants, and sportsbook offerings.
 *
 * OBJECTS MODIFIED:
 *   - RAW_INGESTION.GAMES (200 rows)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA RAW_INGESTION;

TRUNCATE TABLE GAMES;

WITH base AS (
    SELECT
        SEQ8()                             AS seq_id,
        UNIFORM(0, 100, RANDOM())         AS type_selector,
        UNIFORM(0, 100, RANDOM())         AS volatility_selector,
        UNIFORM(50, 500, RANDOM())        AS min_bet_cents,
        UNIFORM(10, 5000, RANDOM())       AS max_bet_dollars
    FROM TABLE(GENERATOR(ROWCOUNT => 200))
),
game_shapes AS (
    SELECT
        seq_id + 1                                         AS game_id,
        CONCAT('GAME-', LPAD(TO_VARCHAR(seq_id + 1), 5, '0')) AS game_code,
        CASE
            WHEN type_selector < 45 THEN 'Slots'
            WHEN type_selector < 75 THEN 'Table'
            WHEN type_selector < 88 THEN 'Poker'
            ELSE 'Sportsbook'
        END                                                AS game_type,
        CASE
            WHEN type_selector < 45 THEN CONCAT('Slots ', LPAD(TO_VARCHAR((seq_id % 60) + 1), 2, '0'))
            WHEN type_selector < 75 THEN CONCAT('Table ', LPAD(TO_VARCHAR((seq_id % 40) + 1), 2, '0'))
            WHEN type_selector < 88 THEN CONCAT('Poker Variant ', LPAD(TO_VARCHAR((seq_id % 20) + 1), 2, '0'))
            ELSE CONCAT('Sportsbook Market ', LPAD(TO_VARCHAR((seq_id % 20) + 1), 2, '0'))
        END                                                AS game_name,
        CASE
            WHEN game_type = 'Slots' THEN ROUND(UNIFORM(85, 96, RANDOM()) / 100, 4)
            WHEN game_type = 'Table' THEN ROUND(UNIFORM(2, 6, RANDOM()) / 100, 4)
            WHEN game_type = 'Poker' THEN ROUND(UNIFORM(2, 12, RANDOM()) / 100, 4)
            ELSE ROUND(UNIFORM(3, 8, RANDOM()) / 100, 4)
        END                                                AS house_edge_pct,
        CASE
            WHEN volatility_selector < 40 THEN 'Low'
            WHEN volatility_selector < 75 THEN 'Medium'
            ELSE 'High'
        END                                                AS volatility_rating,
        ROUND(min_bet_cents / 100, 2)                      AS min_bet_amount,
        ROUND(max_bet_dollars, 2)                          AS max_bet_amount,
        CASE
            WHEN game_type = 'Slots' THEN ROUND(UNIFORM(15, 45, RANDOM()), 2)
            WHEN game_type = 'Table' THEN ROUND(UNIFORM(35, 90, RANDOM()), 2)
            WHEN game_type = 'Poker' THEN ROUND(UNIFORM(45, 120, RANDOM()), 2)
            ELSE ROUND(UNIFORM(20, 180, RANDOM()), 2)
        END                                                AS average_session_length_minutes,
        TRUE                                               AS is_active
    FROM base
)
INSERT INTO GAMES (
    game_id,
    game_code,
    game_name,
    game_type,
    house_edge_pct,
    volatility_rating,
    min_bet_amount,
    max_bet_amount,
    average_session_length_minutes,
    is_active,
    created_at
)
SELECT
    game_id,
    game_code,
    game_name,
    game_type,
    house_edge_pct,
    volatility_rating,
    min_bet_amount,
    max_bet_amount,
    average_session_length_minutes,
    is_active,
    CURRENT_TIMESTAMP()
FROM game_shapes;

