#!/bin/bash
set -e

# ==========================
# 📄 .env.vault 読み込み
# ==========================
ENV_FILE="$(dirname "$0")/../../.env/.env.vault"
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo "❌ .env.vault ファイルが見つかりません: $ENV_FILE"
  exit 1
fi

# ==========================
# 🚦 モード選択プロンプト（VAULT_MODEが未指定なら）
# ==========================
if [ -z "$VAULT_MODE" ]; then
  echo "Vault モードを選択してください: [1] dev, [2] prod"
  read -p "選択肢 (1/2): " choice
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
# 💡 Vault接続設定（モードごと）
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

# =======================
# 🔄 Vault接続チェック
# =======================
RETRY_COUNT=20
for i in $(seq 1 $RETRY_COUNT); do
  if vault status > /dev/null 2>&1; then
    echo "✅ Vault に接続成功"
    break
  else
    echo "⏳ Vault 起動待機中... ($i/${RETRY_COUNT})"
    sleep 2
  fi
  if [ "$i" -eq "$RETRY_COUNT" ]; then
    echo "❌ Vault に接続できませんでした。Dockerが起動済みか確認してください。"
    exit 1
  fi
done

# =======================
# 🔐 シークレット投入
# =======================
VAULT_PATH="secret/arkstream"

put_secret() {
  local path=$1
  shift
  echo "🔑 ${path##*/} のシークレットを登録中..."
  vault kv put "${VAULT_PATH}/${path}" "$@" > /dev/null
}

put_secret binance \
  ARKSTREAM_BINANCE_API_KEY="your_binance_api_key" \
  ARKSTREAM_BINANCE_SECRET_KEY="your_binance_secret_key"

put_secret okx \
  ARKSTREAM_OKX_API_KEY="your_okx_api_key" \
  ARKSTREAM_OKX_SECRET_KEY="your_okx_secret_key" \
  ARKSTREAM_OKX_PASSPHRASE="your_passphrase"

put_secret coinbase \
  ARKSTREAM_COINBASE_API_KEY="your_coinbase_api_key" \
  ARKSTREAM_COINBASE_SECRET_KEY="your_coinbase_secret_key"

put_secret postgres \
  POSTGRES_USER="user" \
  POSTGRES_PASSWORD="pass" \
  DATABASE_URL="postgresql://user:pass@localhost:5432/market_data"

put_secret mongodb \
  MONGO_URI="mongodb://localhost:27017"

put_secret discord \
  ARKSTREAM_DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/xxxxx/yyyyy"

echo "✅ すべてのシークレットが Vault に投入されました"
