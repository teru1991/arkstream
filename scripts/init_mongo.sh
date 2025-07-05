#!/usr/bin/env bash
set -e

# Vault からパスワード取得
# export ARK_DB_PASSWORD=$(vault kv get -field=password secret/arkstream/mongo)

export ARK_DB_PASSWORD="${ARK_DB_PASSWORD:-changeme}"

echo "🚀 MongoDB 初期化開始"

docker exec -i arkstream_mongo mongosh <<EOF
use admin
db.createUser({
  user: "arkuser",
  pwd: "${ARK_DB_PASSWORD}",
  roles: [{ role: "readWrite", db: "arkstream" }]
})
EOF

echo "✅ MongoDB 初期化完了"
