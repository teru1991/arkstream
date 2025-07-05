# vault/tests/vault_test_py.py
import os
import hvac

VAULT_ADDR = os.getenv("VAULT_ADDR", "http://127.0.0.1:8200")
VAULT_TOKEN = os.getenv("VAULT_TOKEN", "root")

client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)

if not client.is_authenticated():
    raise Exception("❌ Vault 認証に失敗しました")

print("✅ Vault 認証成功")

# 秘密取得
read_response = client.secrets.kv.v2.read_secret_version(path="arkstream/binance_test")
secrets = read_response["data"]["data"]

print("🔐 取得したシークレット:")
for key, value in secrets.items():
    print(f"  {key} = {value}")
