#!/bin/bash

set -euo pipefail

# Kafkaブローカーのアドレス（docker-compose内部名）
BROKER="kafka:9092"

# 作成するKafkaトピックのリスト
TOPICS=("tick_data" "order_book" "trade_log")

# トピック作成関数
create_topic() {
  local topic=$1
  echo "📡 Creating topic: $topic"

  /opt/bitnami/kafka/bin/kafka-topics.sh \
    --bootstrap-server "$BROKER" \
    --create \
    --if-not-exists \
    --replication-factor 1 \
    --partitions 1 \
    --topic "$topic"
}

# ループしてトピックを作成
for topic in "${TOPICS[@]}"; do
  create_topic "$topic"
done

echo "✅ Kafka topics initialized successfully."
