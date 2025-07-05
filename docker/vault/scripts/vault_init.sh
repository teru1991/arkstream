#!/usr/bin/env bash
set -e

# ==========================
# 📄 .env.vault 読み込み
# ==========================
ENV_FILE="$(dirname "$0")/../../.env.vault"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
else
  echo "❌ .env.vault ファイルが見つかりません: $ENV_FILE"
  exit 1
fi

# ==========================
# 🚦 モード選択
# ==========================
if [ -z "$VAULT_MODE" ]; then
  echo "Vault モードを選択してください: [1] dev, [2] prod"
  read -rp "選択肢 (1/2): " choice
  if [ "$choice" = "1" ]; then
    VAULT_MODE="dev"
  elif [ "$choice" = "2" ]; then
    VAULT_MODE="prod"
  else
    echo "❌ 無効な選択です。"
    exit 1
  fi
fi

# ==========================
# 💡 Vault接続設定
# ==========================
if [ "$VAULT_MODE" = "dev" ]; then
  export VAULT_ADDR="$VAULT_ADDR_DEV"
  export VAULT_TOKEN="$VAULT_TOKEN_DEV"
else
  export VAULT_ADDR="$VAULT_ADDR_PROD"
  export VAULT_TOKEN="$VAULT_TOKEN_PROD"
fi

echo "🔧 モード: $VAULT_MODE"
echo "🚀 Vault に初期シークレットを投入します..."

# ==========================
# 🔄 Vault接続チェック
# ==========================
RETRY_COUNT=30
SLEEP_INTERVAL=3

set +e
for i in $(seq 1 $RETRY_COUNT); do
  vault status >/dev/null 2>&1
  STATUS=$?
  if [ $STATUS -eq 0 ]; then
    echo "✅ Vault に接続成功"
    break
  fi
  echo "⏳ Vault 起動待機中... ($i/$RETRY_COUNT)"
  sleep $SLEEP_INTERVAL
done
set -e

if [ $STATUS -ne 0 ]; then
  echo "❌ Vault に接続できませんでした。Dockerが起動済みか確認してください。"
  exit 1
fi

# ==========================
# 🔐 シークレット投入
# ==========================
VAULT_PATH="secret/arkstream"

put_secret() {
  local path=$1
  shift
  echo "🔑 ${path##*/} のシークレットを登録中..."
  vault kv put -mount=secret "${VAULT_PATH}/${path}" "$@" >/dev/null
}

# Binance
put_secret binance \
  ARKSTREAM_BINANCE_API_KEY="${BINANCE_API_KEY:-your_binance_api_key}" \
  ARKSTREAM_BINANCE_SECRET_KEY="${BINANCE_SECRET_KEY:-your_binance_secret_key}"

# OKX
put_secret okx \
  ARKSTREAM_OKX_API_KEY="${OKX_API_KEY:-your_okx_api_key}" \
  ARKSTREAM_OKX_SECRET_KEY="${OKX_SECRET_KEY:-your_okx_secret_key}" \
  ARKSTREAM_OKX_PASSPHRASE="${OKX_PASSPHRASE:-your_passphrase}"

# Coinbase
put_secret coinbase \
  ARKSTREAM_COINBASE_API_KEY="${COINBASE_API_KEY:-your_coinbase_api_key}" \
  ARKSTREAM_COINBASE_SECRET_KEY="${COINBASE_SECRET_KEY:-your_coinbase_secret_key}"

# PostgreSQL
put_secret postgres \
  POSTGRES_USER="${POSTGRES_USER:-arkstream}" \
  POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-changeme}" \
  DATABASE_URL="postgresql://${POSTGRES_USER:-arkstream}:${POSTGRES_PASSWORD:-changeme}@localhost:5432/market_data"

# MongoDB
put_secret mongodb \
  MONGO_URI="mongodb://localhost:27017"

# Discord Webhook
put_secret discord \
  ARKSTREAM_DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/xxxxx/yyyyy}"

echo "✅ すべてのシークレットが Vault に投入されました"
