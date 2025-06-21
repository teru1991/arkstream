#!/bin/bash

TOPICS=("tick_data" "order_book" "trade_log")
BROKER="localhost:9092"
KAFKA_CONTAINER="arkstream-kafka"

for topic in "${TOPICS[@]}"
do
  echo "📡 Creating topic: $topic"
  docker exec "$KAFKA_CONTAINER" \
    /opt/bitnami/kafka/bin/kafka-topics.sh --create --topic "$topic" \
    --bootstrap-server "$BROKER" \
    --replication-factor 1 --partitions 1 \
    --if-not-exists
done
