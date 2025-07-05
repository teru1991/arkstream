#!/usr/bin/env bash
set -e

# Vault からパスワード取得
# export ARK_DB_PASSWORD=$(vault kv get -field=password secret/arkstream/postgres)

# 環境変数で渡す場合
export ARK_DB_PASSWORD="${ARK_DB_PASSWORD:-changeme}"

echo "🚀 PostgreSQL 初期化開始"

docker exec -i arkstream_postgres psql -U postgres <<EOF
CREATE DATABASE arkstream;
CREATE USER arkuser WITH ENCRYPTED PASSWORD '${ARK_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE arkstream TO arkuser;
EOF

echo "✅ PostgreSQL 初期化完了"
