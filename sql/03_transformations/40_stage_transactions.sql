/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Stage wagering transactions
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Normalize RAW_INGESTION.TRANSACTIONS into STAGING_LAYER.STG_TRANSACTIONS with
 *   cleaned monetary fields and derived flags for analytics.
 *
 * OBJECTS CREATED:
 *   - STAGING_LAYER.STG_TRANSACTIONS
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE OR REPLACE TABLE STAGING_LAYER.STG_TRANSACTIONS AS
SELECT
    transaction_id,
    session_id,
    player_id,
    game_id,
    transaction_ts,
    INITCAP(transaction_type)                         AS transaction_type,
    ROUND(bet_amount, 2)                              AS bet_amount,
    ROUND(payout_amount, 2)                           AS payout_amount,
    ROUND(net_amount, 2)                              AS net_amount,
    ROUND(theoretical_win_amount, 2)                  AS theoretical_win_amount,
    INITCAP(outcome)                                  AS outcome,
    NVL(is_bonus, FALSE)                              AS is_bonus,
    CASE WHEN transaction_type = 'BET' THEN 1 ELSE 0 END AS is_bet_event,
    CASE WHEN transaction_type = 'WIN' THEN 1 ELSE 0 END AS is_win_event,
    CASE WHEN transaction_type = 'COMP' THEN 1 ELSE 0 END AS is_comp_event,
    CURRENT_TIMESTAMP()                               AS staged_at
FROM RAW_INGESTION.TRANSACTIONS;

