#!/bin/bash

set -e

MODE="${VAULT_MODE:-dev}"

if [[ "$MODE" == "dev" ]]; then
  echo "🟢 Starting Vault in DEV mode..."
  docker-compose -f docker-compose.vault.dev.yml up -d
else
  echo "🔵 Starting Vault in PROD mode..."
  docker-compose -f docker-compose.vault.prod.yml up -d
fi
