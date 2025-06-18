#!/bin/bash
set -e

echo -e "\n🔍 環境チェック..."
command -v python3 &> /dev/null || { echo "❌ Python3 not found"; exit 1; }
command -v cargo &> /dev/null || { echo "❌ Rust (cargo) not found"; exit 1; }
command -v docker-compose &> /dev/null || { echo "❌ docker-compose not found"; exit 1; }

echo -e "\n📦 Python仮想環境の構築..."
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r config/requirements.txt
echo "✅ Python環境構築完了"

echo -e "\n🐳 Dockerコンテナ起動..."
docker-compose -f docker/docker-compose.yml -f docker/docker-compose.monitoring.yml up -d
echo "✅ Docker起動完了"

echo -e "\n🧪 Kafkaトピック初期化..."
if [ -f docker/scripts/init_kafka_topics.sh ]; then
  chmod +x docker/scripts/init_kafka_topics.sh
  ./docker/scripts/init_kafka_topics.sh
  echo "✅ Kafkaトピック初期化完了"
else
  echo "⚠️ Kafka初期化スクリプトが見つかりません（スキップ）"
fi

echo -e "\n🧱 Rust依存のビルド..."
cargo build
echo "✅ Rustビルド完了"
