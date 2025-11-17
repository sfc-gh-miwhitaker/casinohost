/*******************************************************************************
 * DEMO PROJECT: Casino Host Intelligence
 * Script: Generate synthetic gaming sessions
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Populate RAW_INGESTION.GAMING_SESSIONS with 2M session records driven by
 *   player tier, game preference, and comp economics. Results emulate realistic
 *   visit cadence, wagering, and host touch points.
 *
 * OBJECTS MODIFIED:
 *   - RAW_INGESTION.GAMING_SESSIONS (2M rows)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA RAW_INGESTION;

TRUNCATE TABLE GAMING_SESSIONS;

WITH session_base AS (
    SELECT
        SEQ8()                                     AS seq_id,
        UNIFORM(0, 180, RANDOM())                 AS days_ago,
        UNIFORM(0, 1440, RANDOM())                AS minute_offset,
        NORMALLY_DISTRIBUTED_RANDOM(1.0, 0.3, RANDOM()) AS session_intensity_factor
    FROM TABLE(GENERATOR(ROWCOUNT => 2000000))
),
player_map AS (
    SELECT
        sb.seq_id,
        sb.seq_id + 1                                                        AS session_id,
        MOD(sb.seq_id, 50000) + 1                                            AS player_slot,
        sb.days_ago,
        sb.minute_offset,
        LEAST(GREATEST(sb.session_intensity_factor, 0.4), 2.5)               AS intensity_factor
    FROM session_base sb
),
session_enriched AS (
    SELECT
        pm.session_id,
        p.player_id,
        p.player_tier,
        p.preferred_game_type,
        p.average_session_minutes,
        p.average_daily_theoretical,
        p.visit_frequency_per_month,
        pm.days_ago,
        pm.minute_offset,
        pm.intensity_factor,
        CASE
            WHEN p.player_tier = 'Diamond' THEN 0.38
            WHEN p.player_tier = 'Platinum' THEN 0.32
            WHEN p.player_tier = 'Gold' THEN 0.28
            WHEN p.player_tier = 'Silver' THEN 0.23
            ELSE 0.18
        END                                                                AS comp_percentage,
        CASE
            WHEN p.preferred_game_type = 'Slots' THEN 0.09
            WHEN p.preferred_game_type = 'Table' THEN 0.045
            WHEN p.preferred_game_type = 'Poker' THEN 0.025
            ELSE 0.06
        END                                                                AS house_edge_pct
    FROM player_map pm
    JOIN PLAYERS p
      ON p.player_id = pm.player_slot
),
session_metrics AS (
    SELECT
        session_id,
        player_id,
        player_tier,
        preferred_game_type,
        house_edge_pct,
        comp_percentage,
        LEAST(GREATEST(
            NORMALLY_DISTRIBUTED_RANDOM(
                average_session_minutes * intensity_factor,
                average_session_minutes * 0.25,
                RANDOM()
            ),
            20
        ), 600)                                                            AS session_duration_minutes,
        average_daily_theoretical,
        LEAST(GREATEST(
            average_daily_theoretical * intensity_factor
            * NORMALLY_DISTRIBUTED_RANDOM(1.0, 0.35, RANDOM()),
            40
        ), 75000)                                                          AS theoretical_win_amount,
        comp_percentage,
        visit_frequency_per_month,
        days_ago,
        minute_offset
    FROM session_enriched
)
INSERT INTO GAMING_SESSIONS (
    session_id,
    player_id,
    session_start_ts,
    session_end_ts,
    session_duration_minutes,
    total_wagered_amount,
    total_won_amount,
    net_win_amount,
    theoretical_win_amount,
    comp_points_earned,
    host_interaction_flag,
    favorite_game_type,
    day_part,
    visit_sequence_in_month,
    created_at
)
SELECT
    session_id,
    player_id,
    session_start_ts,
    session_end_ts,
    session_duration_minutes,
    total_wagered_amount,
    total_won_amount,
    net_win_amount,
    theoretical_win_amount,
    theoretical_win_amount * comp_percentage AS comp_points_earned,
    (player_tier IN ('Platinum','Diamond') OR RAND() < 0.08)             AS host_interaction_flag,
    preferred_game_type                                                   AS favorite_game_type,
    CASE
        WHEN EXTRACT(HOUR FROM session_start_ts) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM session_start_ts) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM session_start_ts) BETWEEN 17 AND 22 THEN 'Evening'
        ELSE 'Overnight'
    END                                                                   AS day_part,
    LEAST(GREATEST(
        ROUND(NORMALLY_DISTRIBUTED_RANDOM(visit_frequency_per_month, 1.5, RANDOM())),
        1
    ), 25)                                                                AS visit_sequence_in_month,
    CURRENT_TIMESTAMP()
FROM (
    SELECT
        session_id,
        player_id,
        preferred_game_type,
        player_tier,
        comp_percentage,
        visit_frequency_per_month,
        house_edge_pct,
        session_duration_minutes,
        theoretical_win_amount,
        CASE
            WHEN house_edge_pct > 0 THEN ROUND(theoretical_win_amount / house_edge_pct, 2)
            ELSE ROUND(theoretical_win_amount / 0.05, 2)
        END                                                           AS total_wagered_amount,
        session_timestamp_start                                       AS session_start_ts,
        DATEADD(minute, session_duration_minutes, session_timestamp_start)
                                                                     AS session_end_ts,
        ROUND(
            CASE
                WHEN house_edge_pct > 0 THEN (theoretical_win_amount / house_edge_pct)
                    - theoretical_win_amount
                ELSE theoretical_win_amount
            END
            + NORMALLY_DISTRIBUTED_RANDOM(0, theoretical_win_amount * 0.4, RANDOM()),
            2
        )                                                            AS total_won_amount,
        ROUND(
            CASE
                WHEN house_edge_pct > 0 THEN theoretical_win_amount
                ELSE theoretical_win_amount * 0.8
            END
            + NORMALLY_DISTRIBUTED_RANDOM(0, theoretical_win_amount * 0.25, RANDOM()),
            2
        )                                                            AS net_win_amount
    FROM (
        SELECT
            session_id,
            player_id,
            preferred_game_type,
            player_tier,
            comp_percentage,
            visit_frequency_per_month,
            house_edge_pct,
            session_duration_minutes,
            theoretical_win_amount,
            DATEADD(
                minute,
                minute_offset,
                TO_TIMESTAMP_NTZ(DATEADD(day, -days_ago, CURRENT_DATE()))
            )                                                        AS session_timestamp_start
        FROM session_metrics
    )
) FINAL;

