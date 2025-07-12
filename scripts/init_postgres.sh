#!/usr/bin/env bash
set -e

# Vault からパスワード取得
# export PROFINAUT_DB_PASSWORD=$(vault kv get -field=password secret/profinaut/postgres)

# 環境変数で渡す場合
export PROFINAUT_DB_PASSWORD="${PROFINAUT_DB_PASSWORD:-changeme}"

echo "🚀 PostgreSQL 初期化開始"

docker exec -i profinaut_postgres psql -U postgres <<EOF
CREATE DATABASE profinaut;
CREATE USER arkuser WITH ENCRYPTED PASSWORD '${PROFINAUT_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE profinaut TO arkuser;
EOF

echo "✅ PostgreSQL 初期化完了"
