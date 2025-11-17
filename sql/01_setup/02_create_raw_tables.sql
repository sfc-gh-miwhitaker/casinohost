/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Create raw layer base tables for synthetic data population
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Define core raw-layer schemas for players, games, gaming sessions,
 *   transactional wagering, and comps history. These tables are populated by
 *   synthetic data generation scripts and feed downstream staging/analytics.
 *
 * OBJECTS CREATED:
 *   - RAW_INGESTION.PLAYERS
 *   - RAW_INGESTION.GAMES
 *   - RAW_INGESTION.GAMING_SESSIONS
 *   - RAW_INGESTION.TRANSACTIONS
 *   - RAW_INGESTION.COMPS_HISTORY
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA RAW_INGESTION;

CREATE OR REPLACE TABLE PLAYERS (
    player_id NUMBER(38,0) NOT NULL COMMENT 'Synthetic surrogate key generated via SEQ8()',
    player_guid STRING NOT NULL COMMENT 'UUID-style identifier for cross-system joins',
    loyalty_join_date DATE NOT NULL COMMENT 'Date player entered loyalty program; uniform distribution across last 3 years',
    player_tier STRING NOT NULL COMMENT 'Current tier (Bronze, Silver, Gold, Platinum, Diamond) sampled by industry distribution',
    age_group STRING COMMENT 'Demographic bracket (e.g., 21-29, 30-39) generated using weighted demographics',
    gender STRING COMMENT 'Self-reported gender distribution (M/F/Non-Binary/Prefer Not)',
    home_state STRING COMMENT 'Two-letter state code sampled from US distribution',
    home_zip STRING COMMENT 'ZIP code approximated via random selection aligned to state',
    preferred_game_type STRING COMMENT 'Top-level preference (Slots/Table/Poker/Sports)',
    average_session_minutes NUMBER(6,2) COMMENT 'Average minutes per session; log-normal distribution by tier',
    visit_frequency_per_month NUMBER(6,2) COMMENT 'Average visits per month; increases with higher tiers',
    average_daily_theoretical NUMBER(12,2) COMMENT 'Average daily theoretical loss estimate in USD',
    lifetime_theoretical NUMBER(14,2) COMMENT 'Cumulative theoretical win across tenure',
    lifetime_actual_loss NUMBER(14,2) COMMENT 'Actual net loss (casino take) aggregated from sessions',
    lifetime_comp_value NUMBER(12,2) COMMENT 'Historical comp value issued to player',
    marketing_opt_in BOOLEAN COMMENT 'Flag for marketing communication opt-in',
    host_assigned BOOLEAN COMMENT 'Indicates whether a dedicated host is assigned',
    host_employee_id STRING COMMENT 'Identifier of assigned host if applicable',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record create timestamp',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record last update timestamp',
    PRIMARY KEY (player_id)
) COMMENT = 'DEMO: Casino host intelligence - master record of player profiles and loyalty attributes';

CREATE OR REPLACE TABLE GAMES (
    game_id NUMBER(38,0) NOT NULL COMMENT 'Unique identifier for each game',
    game_code STRING NOT NULL COMMENT 'Short system code for game',
    game_name STRING NOT NULL COMMENT 'Display name for game',
    game_type STRING NOT NULL COMMENT 'Category: Slots, Table, Poker, Sportsbook',
    house_edge_pct NUMBER(6,3) NOT NULL COMMENT 'Theoretical house edge percentage',
    volatility_rating STRING NOT NULL COMMENT 'Low/Medium/High classification',
    min_bet_amount NUMBER(10,2) COMMENT 'Minimum wager allowed',
    max_bet_amount NUMBER(12,2) COMMENT 'Maximum wager allowed',
    average_session_length_minutes NUMBER(6,2) COMMENT 'Expected average session length',
    is_active BOOLEAN COMMENT 'Indicates if game is currently available on the floor',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record create timestamp',
    PRIMARY KEY (game_id)
) COMMENT = 'DEMO: Casino host intelligence - catalog of casino games with risk and betting parameters';

CREATE OR REPLACE TABLE GAMING_SESSIONS (
    session_id NUMBER(38,0) NOT NULL COMMENT 'Synthetic session identifier from SEQ8()',
    player_id NUMBER(38,0) NOT NULL COMMENT 'Foreign key to PLAYERS',
    session_start_ts TIMESTAMP_NTZ NOT NULL COMMENT 'Session start timestamp; follows player-specific cadence',
    session_end_ts TIMESTAMP_NTZ NOT NULL COMMENT 'Session end timestamp',
    session_duration_minutes NUMBER(8,2) NOT NULL COMMENT 'Duration; gamma distribution by preferred game',
    total_wagered_amount NUMBER(14,2) NOT NULL COMMENT 'Total wagered in USD during session',
    total_won_amount NUMBER(14,2) NOT NULL COMMENT 'Total payout to player',
    net_win_amount NUMBER(14,2) NOT NULL COMMENT 'Casino net win (wagered - won)',
    theoretical_win_amount NUMBER(14,2) NOT NULL COMMENT 'House edge applied to total wagered',
    comp_points_earned NUMBER(12,2) NOT NULL COMMENT 'Comp points based on theoretical × comp percentage',
    host_interaction_flag BOOLEAN COMMENT 'TRUE if host engaged with player during session',
    favorite_game_type STRING COMMENT 'Game type most frequently played in session',
    day_part STRING COMMENT 'Morning/Afternoon/Evening/Overnight label',
    visit_sequence_in_month NUMBER(4,0) COMMENT 'Ordinal visit count within the month',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record create timestamp',
    PRIMARY KEY (session_id)
) COMMENT = 'DEMO: Casino host intelligence - roll-up of wagering activity per player session including theoretical win and host touch points';

CREATE OR REPLACE TABLE TRANSACTIONS (
    transaction_id NUMBER(38,0) NOT NULL COMMENT 'Synthetic transaction identifier from SEQ8()',
    session_id NUMBER(38,0) NOT NULL COMMENT 'Foreign key to GAMING_SESSIONS',
    player_id NUMBER(38,0) NOT NULL COMMENT 'Foreign key to PLAYERS',
    game_id NUMBER(38,0) COMMENT 'Foreign key to GAMES',
    transaction_ts TIMESTAMP_NTZ NOT NULL COMMENT 'Timestamp of individual bet/payout',
    transaction_type STRING NOT NULL COMMENT 'BET, WIN, BONUS, COMP',
    bet_amount NUMBER(12,2) COMMENT 'Amount wagered',
    payout_amount NUMBER(12,2) COMMENT 'Amount won by player',
    net_amount NUMBER(12,2) COMMENT 'Casino net for transaction',
    theoretical_win_amount NUMBER(12,2) COMMENT 'Expected win derived from bet amount × house edge',
    outcome STRING COMMENT 'Win/Loss/Tie descriptor',
    is_bonus BOOLEAN COMMENT 'TRUE for bonus-driven wagers',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record create timestamp',
    PRIMARY KEY (transaction_id)
) COMMENT = 'DEMO: Casino host intelligence - granular wager and payout events linked to sessions and games';

CREATE OR REPLACE TABLE COMPS_HISTORY (
    comp_id NUMBER(38,0) NOT NULL COMMENT 'Synthetic comp identifier from SEQ8()',
    player_id NUMBER(38,0) NOT NULL COMMENT 'Foreign key to PLAYERS',
    comp_date DATE NOT NULL COMMENT 'Date comp was issued',
    comp_type STRING NOT NULL COMMENT 'Meal, Room, Show, Free Play, Cashback',
    comp_channel STRING COMMENT 'In-person, mobile app, outbound call, email',
    comp_value_amount NUMBER(10,2) NOT NULL COMMENT 'USD value of comp provided',
    host_employee_id STRING COMMENT 'Host who authorized the comp',
    issued_by_system STRING COMMENT 'Source system (Host, CRM, Auto)',
    redemption_status STRING COMMENT 'Issued, Redeemed, Expired, Cancelled',
    redemption_date DATE COMMENT 'Date comp was redeemed if applicable',
    trip_id STRING COMMENT 'Trip identifier to tie multiple comps to a visit',
    theoretical_basis_amount NUMBER(12,2) COMMENT 'Theoretical win amount used to justify comp',
    notes STRING COMMENT 'Freeform notes summarizing reason or guest feedback',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record create timestamp',
    PRIMARY KEY (comp_id)
) COMMENT = 'DEMO: Casino host intelligence - history of complimentary offers, issuers, and redemption outcomes';

