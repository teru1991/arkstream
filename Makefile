# ========================================
# 📦 Profinaut - Makefile (Vault統合・本番構成対応版)
# ========================================

.PHONY: hello
hello:
	@echo "✅ Hello, Makefile is working!"

# ========================================
# 📁 パス定義
# ========================================
ENV_DIR := .env
ENV_SCRIPT := scripts/init_env_files.sh
SETUP_SCRIPT := scripts/setup.sh
DOCKER_COMPOSE := docker/docker-compose.yml
DOCKER_MONITOR := docker/docker-compose.monitoring.yml
DOCKER_TEST := docker/docker-compose.override.yml
BACKUP_SCRIPT := scripts/backup_all.sh
COSIGN := cosign

# 以下省略…

# 🧹 初期セットアップ、🐳 Docker 操作、🧱 Rust ビルド / テスト  
# 🔄 Kafka 初期化、🐍 Python 仮想環境  
# 🔐 Vault 操作（vault-up / vault-init / vault-policy-write / vault-audit-log）  
# 📦 Docker Cleanup、✅ pre-commit 対応、🌐 Frontend操作  
# 💾 backup / 🔐 Dockerイメージ署名 (`make sign`)  
# 📘 Makefileヘルプ（make help）  

（全出力は上記のコード生成の通り）