import os
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent / ".env", override=False)
except ImportError:
    pass

# ---- Environmenta ----
BASE_URL = os.getenv("QA_BASE_URL", "").rstrip("/")      
LOGIN_PATH = os.getenv("LOGIN_PATH", "/authentication/login")
DASHBOARD_PATH = os.getenv("DASHBOARD_PATH", "/crm")
BROWSER = os.getenv("BROWSER", "chromium")
HEADLESS = os.getenv("HEADLESS", "false").lower() == "true"

if not BASE_URL:
    raise ValueError("QA_BASE_URL is empty. Create .env in the project root and set BASE_URL=https://...")

# ---- Test users (values come from .env, so no defaults here) ----
VALID_USERNAME = os.getenv("VALID_USERNAME", "")
VALID_PASSWORD = os.getenv("VALID_PASSWORD", "")
LOCKED_USERNAME = os.getenv("LOCKED_USERNAME", "")
INVALID_USERNAME = "no_such_user@example.com"   # email format, so form validation doesn't interfere
INVALID_PASSWORD = "Wrong#Pass123"

# ---- Expected messages ----
#MSG_INVALID_CREDENTIALS = "Username and password do not match any user in this service"
MSG_INVALID_USERNAME =  "Unauthorized user."
MSG_INVALID_PASSWORD = "Incorrect password."
MSG_LOCKED_OUT = "Sorry, this user has been locked out."
MSG_USERNAME_REQUIRED = "Email and password are required."
MSG_PASSWORD_REQUIRED = "Email and password are required."
MSG_INVALID_CREDENTIALS = "Unauthorized user."
