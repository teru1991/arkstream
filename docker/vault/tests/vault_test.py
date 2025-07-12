import hvac
import os

client = hvac.Client(url="https://127.0.0.1:8200", verify=False)

role_id = os.environ["PROFINAUT_DB_ROLE_ID"]
secret_id = os.environ["PROFINAUT_DB_SECRET_ID"]

client.auth_approle(role_id, secret_id)
