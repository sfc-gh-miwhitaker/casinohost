from typing import Dict

import pytest


def fetch_single(cursor, query: str) -> Dict:
    cursor.execute(query)
    row = cursor.fetchone()
    if row is None:
        return {}
    columns = [col[0] for col in cursor.description]
    return dict(zip(columns, row))


def test_raw_row_counts(snowflake_cursor):
    results = fetch_single(
        snowflake_cursor,
        """
        SELECT
            (SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.RAW_INGESTION.PLAYERS) AS players,
            (SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.RAW_INGESTION.GAMING_SESSIONS) AS sessions,
            (SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.RAW_INGESTION.TRANSACTIONS) AS transactions,
            (SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.RAW_INGESTION.COMPS_HISTORY) AS comps
        """,
    )
    assert results["PLAYERS"] >= 50000
    assert results["SESSIONS"] >= 2000000
    assert results["TRANSACTIONS"] >= 10000000
    assert results["COMPS"] >= 500000


def test_dim_player_not_empty(snowflake_cursor):
    row = fetch_single(
        snowflake_cursor,
        """
        SELECT COUNT(*) AS total_players,
               AVG(total_theoretical_amount) AS avg_theo
        FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.DIM_PLAYER
        """,
    )
    assert row["TOTAL_PLAYERS"] >= 50000
    assert row["AVG_THEO"] > 0


def test_view_player_features_columns(snowflake_cursor):
    snowflake_cursor.execute(
        """
        SELECT *
        FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_FEATURES
        LIMIT 1
        """
    )
    columns = [col[0] for col in snowflake_cursor.description]
    expected = {
        "PLAYER_ID",
        "PLAYER_TIER",
        "SESSIONS_LAST_30D",
        "TOTAL_WAGERED_LAST_30D",
        "HOST_TOUCHES_LAST_30D",
    }
    assert expected.issubset(set(columns))


@pytest.mark.parametrize(
    "view_name",
    [
        "SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES",
        "SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_LTV_SCORES",
        "SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS",
    ],
)
def test_views_have_rows(snowflake_cursor, view_name):
    snowflake_cursor.execute(f"SELECT COUNT(*) FROM {view_name}")
    assert snowflake_cursor.fetchone()[0] > 0, f"{view_name} should contain data"

