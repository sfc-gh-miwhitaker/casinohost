import os
from pathlib import Path
from typing import Dict, Optional

import pytest
import snowflake.connector
from cryptography.hazmat.primitives import serialization


def _load_private_key(path: str, passphrase: Optional[str]) -> bytes:
    key_path = Path(path).expanduser()
    with key_path.open("rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=passphrase.encode() if passphrase else None,
        )
    return private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )


def _connection_kwargs() -> Optional[Dict[str, object]]:
    base_env = {
        "account": os.getenv("SNOWFLAKE_ACCOUNT"),
        "user": os.getenv("SNOWFLAKE_USER"),
        "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
        "database": os.getenv("SNOWFLAKE_DATABASE", "SNOWFLAKE_EXAMPLE"),
        "schema": os.getenv("SNOWFLAKE_SCHEMA", "ANALYTICS_LAYER"),
        "role": os.getenv("SNOWFLAKE_ROLE", "SFE_CASINO_DEMO_ADMIN"),
    }
    missing = [key for key, value in base_env.items() if value is None]
    if missing:
        return None

    connection_args: Dict[str, object] = {k: v for k, v in base_env.items()}

    authenticator = os.getenv("SNOWFLAKE_AUTHENTICATOR")
    if authenticator:
        connection_args["authenticator"] = authenticator

    password = os.getenv("SNOWFLAKE_PASSWORD")
    private_key_path = os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH")

    if password:
        connection_args["password"] = password
    elif private_key_path:
        passphrase = os.getenv("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE")
        connection_args["private_key"] = _load_private_key(private_key_path, passphrase)
    else:
        return None

    return connection_args


@pytest.fixture(scope="session")
def snowflake_connection():
    kwargs = _connection_kwargs()
    if kwargs is None:
        pytest.skip(
            "Snowflake connection details not provided. "
            "Set SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_WAREHOUSE and either "
            "SNOWFLAKE_PASSWORD or SNOWFLAKE_PRIVATE_KEY_PATH environment variables."
        )
    connect_args = {
        "account": kwargs["account"],
        "user": kwargs["user"],
        "warehouse": kwargs["warehouse"],
        "database": kwargs["database"],
        "schema": kwargs["schema"],
        "role": kwargs["role"],
    }
    if "authenticator" in kwargs:
        connect_args["authenticator"] = kwargs["authenticator"]

    if "password" in kwargs:
        connect_args["password"] = kwargs["password"]
    elif "private_key" in kwargs:
        connect_args["private_key"] = kwargs["private_key"]
    else:
        pytest.skip("Snowflake credentials missing (password or private key).")

    ctx = snowflake.connector.connect(**connect_args)
    try:
        yield ctx
    finally:
        ctx.close()


@pytest.fixture(scope="session")
def snowflake_cursor(snowflake_connection):
    with snowflake_connection.cursor() as cur:
        yield cur

