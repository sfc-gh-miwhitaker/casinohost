from typing import Dict


def fetch_single(cursor, query: str) -> Dict:
    cursor.execute(query)
    row = cursor.fetchone()
    if row is None:
        return {}
    columns = [col[0] for col in cursor.description]
    return dict(zip(columns, row))


def test_churn_training_dataset_distribution(snowflake_cursor):
    row = fetch_single(
        snowflake_cursor,
        """
        SELECT
            COUNT(*) AS total_rows,
            SUM(CASE WHEN churn_label = 1 THEN 1 ELSE 0 END) AS churned,
            SUM(CASE WHEN churn_label = 0 THEN 1 ELSE 0 END) AS active
        FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.PLAYER_CHURN_TRAINING
        """,
    )
    assert row["TOTAL_ROWS"] > 10000
    assert row["CHURNED"] > 0
    assert row["ACTIVE"] > 0


def test_churn_scores_probability_range(snowflake_cursor):
    snowflake_cursor.execute(
        """
        SELECT MIN(churn_probability) AS min_prob,
               MAX(churn_probability) AS max_prob
        FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_CHURN_SCORES
        """
    )
    min_prob, max_prob = snowflake_cursor.fetchone()
    assert 0.0 <= min_prob <= 1.0
    assert 0.0 <= max_prob <= 1.0
    assert max_prob - min_prob > 0.1


def test_ltv_segment_coverage(snowflake_cursor):
    snowflake_cursor.execute(
        """
        SELECT ltv_segment, COUNT(*) AS cnt
        FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_LTV_SCORES
        GROUP BY 1
        """
    )
    segments = {row[0] for row in snowflake_cursor.fetchall()}
    expected = {"VIP", "High Value", "Growth", "Core", "Dormant"}
    assert expected.issubset(segments)

