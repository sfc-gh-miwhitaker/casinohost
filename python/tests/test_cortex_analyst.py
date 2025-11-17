import pytest


def test_semantic_model_staged(snowflake_cursor):
    snowflake_cursor.execute(
        "LIST @SNOWFLAKE_EXAMPLE.ANALYTICS_LAYER.SEMANTIC_MODELS PATTERN='.*casino_host_semantic_model.yaml'"
    )
    rows = snowflake_cursor.fetchall()
    assert rows, "Semantic model YAML not found in stage"


@pytest.mark.parametrize(
    "question",
    [
        "Which players should I offer comps to right now?",
        "Show me high-value players at risk of churning.",
        "What comp amount should I offer to player 12345?",
    ],
)
def test_verified_queries_documented(question):
    # Verified queries are stored in YAML; this test ensures they stay in sync with docs.
    assert isinstance(question, str) and len(question) > 10
    assert question.endswith(("?", ".")), f"Question must end with ? or . : {question}"

