#!/bin/bash
set -e

echo "🔐 Vault secrets migration script"

# DB secrets
vault kv put secret/profinaut/db \
  POSTGRES_USER=ark_user \
  POSTGRES_PASSWORD=s3cret \
  MONGO_URI=mongodb://localhost:27017

# Kafka secrets
vault kv put secret/profinaut/kafka \
  KAFKA_BROKER=kafka:9092 \
  KAFKA_API_KEY=sample-api-key \
  KAFKA_SECRET=sample-secret

# GPG signing key (you should replace this with your actual key)
vault kv put secret/profinaut/release \
  SIGNING_KEY="$(cat ./signingkey.asc)"

echo "✅ Vault secrets migrated successfully."
