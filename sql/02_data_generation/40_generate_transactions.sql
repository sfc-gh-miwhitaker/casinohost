/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Generate synthetic wagering transactions
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Populate RAW_INGESTION.TRANSACTIONS with 10M granular wager events aligned
 *   to gaming sessions. Distributions follow player preference, session pacing,
 *   and comp issuance cadence.
 *
 * OBJECTS MODIFIED:
 *   - RAW_INGESTION.TRANSACTIONS (10M rows)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA RAW_INGESTION;

TRUNCATE TABLE TRANSACTIONS;

WITH transaction_base AS (
    SELECT
        SEQ8()                           AS seq_id,
        UNIFORM(0, 100, RANDOM())       AS type_selector,
        UNIFORM(0, 1000, RANDOM())      AS bet_selector,
        RANDOM()                        AS randomizer
    FROM TABLE(GENERATOR(ROWCOUNT => 10000000))
),
session_lookup AS (
    SELECT
        tb.seq_id,
        FLOOR(tb.seq_id / 5) + 1        AS session_id,
        tb.type_selector,
        tb.bet_selector,
        tb.randomizer
    FROM transaction_base tb
),
session_join AS (
    SELECT
        sl.seq_id,
        sl.session_id,
        sl.type_selector,
        sl.bet_selector,
        sl.randomizer,
        gs.player_id,
        gs.favorite_game_type,
        gs.session_start_ts,
        gs.session_end_ts,
        gs.session_duration_minutes,
        gs.theoretical_win_amount,
        gs.total_wagered_amount,
        gs.house_edge_pct
    FROM session_lookup sl
    JOIN GAMING_SESSIONS gs
      ON gs.session_id = sl.session_id
),
game_arrays AS (
    SELECT
        (SELECT ARRAY_AGG(game_id ORDER BY game_id) FROM GAMES WHERE game_type = 'Slots')      AS slots_array,
        (SELECT ARRAY_AGG(game_id ORDER BY game_id) FROM GAMES WHERE game_type = 'Table')      AS table_array,
        (SELECT ARRAY_AGG(game_id ORDER BY game_id) FROM GAMES WHERE game_type = 'Poker')      AS poker_array,
        (SELECT ARRAY_AGG(game_id ORDER BY game_id) FROM GAMES WHERE game_type = 'Sportsbook') AS sportsbook_array
),
transaction_enriched AS (
    SELECT
        sj.seq_id,
        sj.session_id,
        sj.player_id,
        CASE sj.favorite_game_type
            WHEN 'Slots' THEN ARRAY_GET(ga.slots_array, MOD(sj.seq_id, ARRAY_SIZE(ga.slots_array)))
            WHEN 'Table' THEN ARRAY_GET(ga.table_array, MOD(sj.seq_id, ARRAY_SIZE(ga.table_array)))
            WHEN 'Poker' THEN ARRAY_GET(ga.poker_array, MOD(sj.seq_id, ARRAY_SIZE(ga.poker_array)))
            ELSE ARRAY_GET(ga.sportsbook_array, MOD(sj.seq_id, ARRAY_SIZE(ga.sportsbook_array)))
        END                                                         AS game_id,
        sj.type_selector,
        sj.bet_selector,
        sj.randomizer,
        sj.session_start_ts,
        sj.session_end_ts,
        sj.session_duration_minutes,
        sj.theoretical_win_amount,
        sj.total_wagered_amount,
        COALESCE(sj.house_edge_pct,
            CASE sj.favorite_game_type
                WHEN 'Slots' THEN 0.09
                WHEN 'Table' THEN 0.045
                WHEN 'Poker' THEN 0.025
                ELSE 0.06
            END
        )                                                             AS house_edge_pct
    FROM session_join sj
    CROSS JOIN game_arrays ga
),
transaction_values AS (
    SELECT
        seq_id,
        session_id,
        player_id,
        COALESCE(game_id, ARRAY_GET((SELECT slots_array FROM game_arrays), 0)) AS game_id,
        CASE
            WHEN type_selector < 70 THEN 'BET'
            WHEN type_selector < 90 THEN 'WIN'
            WHEN type_selector < 95 THEN 'BONUS'
            ELSE 'COMP'
        END                                                             AS transaction_type,
        session_start_ts,
        session_end_ts,
        session_duration_minutes,
        theoretical_win_amount,
        total_wagered_amount,
        house_edge_pct,
        randomizer,
        bet_selector
    FROM transaction_enriched
),
transaction_amounts AS (
    SELECT
        seq_id,
        session_id,
        player_id,
        game_id,
        transaction_type,
        DATEADD(
            millisecond,
            FLOOR(randomizer * session_duration_minutes * 60 * 1000),
            session_start_ts
        )                                                               AS transaction_ts,
        CASE
            WHEN transaction_type = 'BET' THEN
                ROUND(GREATEST(total_wagered_amount / 5 * (0.5 + randomizer), 5), 2)
            WHEN transaction_type = 'BONUS' THEN
                ROUND(GREATEST(theoretical_win_amount * 0.05 * (0.4 + randomizer), 3), 2)
            ELSE 0
        END                                                             AS bet_amount,
        CASE
            WHEN transaction_type = 'WIN' THEN
                ROUND(GREATEST(
                    total_wagered_amount / 5 * (0.3 + randomizer),
                    2
                ), 2)
            WHEN transaction_type = 'COMP' THEN
                ROUND(GREATEST(theoretical_win_amount * 0.08 * (0.5 + randomizer), 5), 2)
            ELSE 0
        END                                                             AS payout_amount,
        theoretical_win_amount,
        house_edge_pct,
        randomizer
    FROM transaction_values
),
transaction_metrics AS (
    SELECT
        seq_id,
        session_id,
        player_id,
        game_id,
        transaction_type,
        transaction_ts,
        bet_amount,
        payout_amount,
        theoretical_win_amount,
        house_edge_pct,
        randomizer,
        CASE
            WHEN transaction_type IN ('BET','BONUS') THEN
                ROUND(
                    (bet_amount * house_edge_pct) * (0.7 + randomizer),
                    2
                )
            WHEN transaction_type = 'WIN' THEN
                ROUND(
                    -payout_amount * (0.1 + randomizer / 2),
                    2
                )
            WHEN transaction_type = 'COMP' THEN
                ROUND(
                    -payout_amount,
                    2
                )
        END                                                             AS net_amount,
        CASE
            WHEN transaction_type = 'BET' THEN ROUND(bet_amount * house_edge_pct, 2)
            WHEN transaction_type = 'WIN' THEN ROUND(payout_amount * house_edge_pct * -1, 2)
            ELSE ROUND(payout_amount * house_edge_pct, 2)
        END                                                             AS theoretical_win_amount,
        CASE
            WHEN transaction_type = 'WIN' THEN 'WIN'
            WHEN transaction_type = 'BET' THEN 'LOSS'
            WHEN transaction_type = 'COMP' THEN 'COMP'
            ELSE 'BONUS'
        END                                                             AS outcome,
        transaction_type IN ('BONUS','COMP')                             AS is_bonus
    FROM transaction_amounts
)
INSERT INTO TRANSACTIONS (
    transaction_id,
    session_id,
    player_id,
    game_id,
    transaction_ts,
    transaction_type,
    bet_amount,
    payout_amount,
    net_amount,
    theoretical_win_amount,
    outcome,
    is_bonus,
    created_at
)
SELECT
    seq_id + 1,
    session_id,
    player_id,
    game_id,
    transaction_ts,
    transaction_type,
    bet_amount,
    payout_amount,
    net_amount,
    theoretical_win_amount,
    outcome,
    is_bonus,
    CURRENT_TIMESTAMP()
FROM transaction_metrics;

