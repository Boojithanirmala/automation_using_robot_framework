"""Credential helper for Robot Framework.

Save as: resources/libraries/env_helper.py
Install:  pip install python-dotenv
"""
import os
from pathlib import Path

from dotenv import load_dotenv

# Load the .env that sits in the project root (robot-login-suite/.env)
load_dotenv(Path(__file__).resolve().parents[2] / ".env")


def get_credentials(level):
    """Return (username, password) for an approval level, e.g. 'L1'.

    Reads USER_<LEVEL> and PASS_<LEVEL> from .env.
    """
    key = str(level).upper()
    user = os.getenv(f"USER_{key}")
    password = os.getenv(f"PASS_{key}")
    if not user or not password:
        raise ValueError(
            f"Credentials for '{key}' not found. Add USER_{key} and PASS_{key} to .env"
        )
    return user, password