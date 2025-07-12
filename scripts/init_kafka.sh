#!/usr/bin/env bash
set -e

echo "🚀 Kafka トピック作成開始"

docker exec -i profinaut_kafka kafka-topics.sh --create \
  --topic signal_events \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3

docker exec -i profinaut_kafka kafka-topics.sh --create \
  --topic trade_events \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3

docker exec -i profinaut_kafka kafka-topics.sh --create \
  --topic monitoring_events \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 1

echo "✅ Kafka トピック作成完了"
