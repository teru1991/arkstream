# setup.ps1
$ErrorActionPreference = "Stop"

Write-Host "`n📦 Python仮想環境の構築..."
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Python が見つかりません。"
    exit 1
}
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r config/requirements.txt
Write-Host "✅ Python環境構築完了"

Write-Host "`n🐳 Dockerコンテナ起動..."
docker-compose -f docker\docker-compose.yml -f docker\docker-compose.monitoring.yml up -d
Write-Host "✅ Docker起動完了"

Write-Host "`n🧪 Kafkaトピック初期化..."
if (Test-Path ".\docker\scripts\init_kafka_topics.sh") {
    bash .\docker\scripts\init_kafka_topics.sh
    Write-Host "✅ Kafkaトピック初期化完了"
} else {
    Write-Warning "⚠️ Kafka初期化スクリプトが見つかりません（スキップ）"
}

Write-Host "`n🧱 Rust依存のビルド..."
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Rust (cargo) が見つかりません。"
    exit 1
}
cargo build
Write-Host "✅ Rustビルド完了"
