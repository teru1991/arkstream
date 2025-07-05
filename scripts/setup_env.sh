#!/bin/bash

# 環境を指定（dev または prod）
if [ "$1" == "prod" ]; then
  export VAULT_ADDR="https://127.0.0.1:8200"
  export VAULT_TOKEN="your-prod-token-here"
elif [ "$1" == "dev" ]; then
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN="root"
else
  echo "Usage: $0 {dev|prod}"
  exit 1
fi
