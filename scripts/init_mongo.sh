#!/usr/bin/env bash
set -e

# Vault からパスワード取得
# export PROFINAUT_DB_PASSWORD=$(vault kv get -field=password secret/profinaut/mongo)

export PROFINAUT_DB_PASSWORD="${PROFINAUT_DB_PASSWORD:-changeme}"

echo "🚀 MongoDB 初期化開始"

docker exec -i profinaut_mongo mongosh <<EOF
use admin
db.createUser({
  user: "profinautuser",
  pwd: "${PROFINAUT_DB_PASSWORD}",
  roles: [{ role: "readWrite", db: "profinaut" }]
})
EOF

echo "✅ MongoDB 初期化完了"
