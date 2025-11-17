def test_pipeline_artifacts_exist(snowflake_cursor):
    snowflake_cursor.execute(
        """
        SELECT COUNT(*) AS cnt
        FROM TABLE(INFORMATION_SCHEMA.TABLES())
        WHERE TABLE_CATALOG = 'SNOWFLAKE_EXAMPLE'
          AND TABLE_SCHEMA = 'ANALYTICS_LAYER'
          AND TABLE_NAME IN (
                'DIM_PLAYER','DIM_GAME',
                'FCT_GAMING_SESSION','FCT_TRANSACTION',
                'AGG_PLAYER_DAILY','AGG_PLAYER_LIFETIME',
                'PLAYER_CHURN_TRAINING'
          )
        """
    )
    assert snowflake_cursor.fetchone()[0] == 7


def test_recommendations_available_for_vips(snowflake_cursor):
    snowflake_cursor.execute(
        """
        SELECT COUNT(*) 
        FROM SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.V_PLAYER_RECOMMENDATIONS
        WHERE ltv_segment = 'VIP'
          AND suggested_comp_value_usd >= 100
        """
    )
    assert snowflake_cursor.fetchone()[0] > 0

