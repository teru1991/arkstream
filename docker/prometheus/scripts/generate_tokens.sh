#!/bin/bash

mkdir -p ../../prometheus/tokens

echo -n "${SIGNAL_CF_ACCESS_ID}:${SIGNAL_CF_ACCESS_SECRET}" > ./prometheus/tokens/profinaut-signal-token.txt
echo -n "${TRADE_CF_ACCESS_ID}:${TRADE_CF_ACCESS_SECRET}" > ./prometheus/tokens/profinaut-trade-token.txt
echo -n "${VAULT_CF_ACCESS_ID}:${VAULT_CF_ACCESS_SECRET}" > ./prometheus/tokens/profinaut-vault-token.txt
echo -n "${METRICS_CF_ACCESS_ID}:${METRICS_CF_ACCESS_SECRET}" > ./prometheus/tokens/profinaut-metrics-token.txt
