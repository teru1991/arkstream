#!/bin/bash
set -e

echo "🔧 Vault (dev) テスト - Binance テストデータ投入開始"

# 📄 .env.api_binance 読み込み
ENV_FILE=".env/.env.api_binance"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ $ENV_FILE が見つかりません"
  exit 1
fi

# 読み込み
set -o allexport
source "$ENV_FILE"
set +o allexport

# 🛠️ Vault (devモード前提)
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="root"

# ✅ 接続確認
if ! vault status > /dev/null 2>&1; then
  echo "❌ Vault に接続できません（VAULT_ADDR=$VAULT_ADDR）"
  exit 1
fi

echo "✅ Vault に接続成功 (devモード)"

# 🔐 シークレット投入
vault kv put secret/profinaut/binance_test \
  BINANCE_KEYS="$BINANCE_KEYS" \
  BINANCE_SECRETS="$BINANCE_SECRETS"

echo "✅ テストデータ投入完了: secret/profinaut/binance_test"

# 📤 データ取得テスト
echo "🔎 取得結果:"
vault kv get secret/profinaut/binance_test
