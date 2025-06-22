# ========================================
# 📦 ArkStream - Makefile
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

# ========================================
# 🧹 初期セットアップ
# ========================================

.PHONY: setup
setup:
	@echo "🚀 フルセットアップを開始..."
	bash $(SETUP_SCRIPT)

.PHONY: init-env
init-env:
	@echo "📁 .env ファイルを初期化します"
	bash $(ENV_SCRIPT)

# ========================================
# 🐳 Docker 操作
# ========================================

.PHONY: docker-up
docker-up:
	@echo "🐳 Dockerコンテナを起動します"
	docker-compose -f $(DOCKER_COMPOSE) -f $(DOCKER_MONITOR) up -d

.PHONY: docker-down
docker-down:
	@echo "🛑 Dockerコンテナを停止します"
	docker-compose -f $(DOCKER_COMPOSE) -f $(DOCKER_MONITOR) down

.PHONY: docker-logs
docker-logs:
	@echo "📜 Dockerログを表示します"
	docker-compose -f $(DOCKER_COMPOSE) -f $(DOCKER_MONITOR) logs -f

.PHONY: docker-ps
docker-ps:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

.PHONY: kafka-status
kafka-status:
	@echo "📡 Kafkaステータス確認中..."
	nc -zv localhost 9092 || echo "⚠️ Kafka が起動していない可能性があります"

# ========================================
# 🧱 Rust ビルド / テスト
# ========================================

.PHONY: build
build:
	@echo "🔨 Rustビルドを開始します"
	cargo build

.PHONY: test
test:
	@echo "🧪 Rustテストを実行します"
	cargo test

.PHONY: clean
clean:
	@echo "🧹 ビルド成果物を削除します"
	cargo clean

# ========================================
# 🧼 Lint / Format チェック
# ========================================

.PHONY: lint
lint:
	@echo "🔍 Lint / Format チェック"
	@echo "📦 Python: ruff"
	ruff src/ || true
	@echo "🦀 Rust: clippy"
	cargo clippy || true
	@echo "📘 TypeScript: eslint"
	npx eslint frontend/ --ext .ts,.tsx || true

.PHONY: format-readme
format-readme:
	@echo "📝 README整形"
	npx prettier --write README.md

# ========================================
# 🔄 Kafkaトピック初期化
# ========================================

.PHONY: init-kafka
init-kafka:
	@echo "📡 Kafkaトピックを初期化します"
	cd docker/scripts && bash init_kafka_topics.sh

# ========================================
# 🐍 Python仮想環境
# ========================================

.PHONY: venv
venv:
	@echo "🐍 Python仮想環境を作成します"
	python3 -m venv .venv
	. .venv/bin/activate && pip install -r config/requirements.txt

# ========================================
# 🔐 Vault 操作（MODE=dev 対応）
# ========================================

VAULT_CONTAINER := $(if $(filter $(MODE),dev),arkstream-vault-dev,arkstream-vault)

.PHONY: vault-up
vault-up:
	@echo "🔐 Vault ($(VAULT_CONTAINER)) を起動します"
	docker-compose -f $(DOCKER_COMPOSE) up -d $(VAULT_CONTAINER)

.PHONY: vault-down
vault-down:
	@echo "🛑 Vault ($(VAULT_CONTAINER)) を停止します"
	docker-compose -f $(DOCKER_COMPOSE) stop $(VAULT_CONTAINER)

.PHONY: vault-init
vault-init:
	@echo "🚀 Vault 初期化スクリプトを実行します (MODE=$(MODE))"
	VAULT_MODE=$(MODE) bash vault/scripts/vault_init.sh

.PHONY: vault-test
vault-test:
	@echo "🧪 Vault API を Python でテストします"
	python3 vault/tests/vault_test.py

.PHONY: vault-test-binance
vault-test-binance:
	@echo "🧪 BinanceテストデータをVaultに投入します"
	bash vault/scripts/vault_test_binance.sh


# ========================================
# ♻️ Docker Cleanup
# ========================================

.PHONY: prune
prune:
	@echo "♻️ Dockerボリューム・ネットワークのクリーンアップ"
	docker system prune -af --volumes

# ========================================
# 📦 ArkStream - Makefile
# ========================================

.PHONY: help

help:
	@echo ""
	@echo "📘 ArkStream Makefile ヘルプ"
	@echo "---------------------------------------------"
	@grep -E '^\.PHONY: [a-zA-Z0-9_-]+.*$$' Makefile | sed 's/\.PHONY: //' | tr ' ' '\n' | while read target; do \
		desc=$$(grep -A 1 "^\.PHONY: $$target" Makefile | tail -n1 | sed -E 's/^\s*@?echo\s+"(.*)"/\1/' | sed 's/@echo "//;s/"//'); \
		printf "🛠  make %-16s - %s\n" "$$target" "$$desc"; \
	done
	@echo ""

.PHONY: pre-commit-run
pre-commit-run:
	@echo "✅ pre-commit を実行します"
	pre-commit run --all-files

.PHONY: pre-commit-install
pre-commit-install:
	@echo "📦 pre-commit をインストールします"
	pre-commit install

.PHONY: format
format:
	@echo "🎨 Format all source code"
	@echo "🐍 Python: black"
	black src/ || true
	@echo "🦀 Rust: rustfmt"
	cargo fmt || true
	@echo "📘 TypeScript: eslint --fix"
	npx eslint frontend/ --ext .ts,.tsx --fix || true

.PHONY: check
check:
	@echo "🔍 Running pre-commit checks"
	pre-commit run --all-files

# ========================================
# ✅ pre-commit セットアップ & チェック
# ========================================

.PHONY: init-pre-commit
init-pre-commit:
	@echo "🛠️ pre-commit を初期化します"
	bash scripts/init_pre_commit.sh

.PHONY: check
check:
	@echo "🔍 pre-commit 全チェックを実行します"
	pre-commit run --all-files

.PHONY: update-pre-commit-rev
update-pre-commit-rev:
	@bash scripts/update_pre_commit_rev.sh

.PHONY: update-pre-commit-revs
update-pre-commit-revs:
	@bash scripts/update_all_pre_commit_revs.sh

.PHONY: init-lint-config
init-lint-config:
	@echo "🧼 Linter/Formatter 設定ファイルを初期化します"
	bash scripts/init_lint_config.sh

# ========================================
# 📁 フロントエンド初期化
# ========================================

.PHONY: frontend-init
frontend-init:
	@echo "🌐 frontend を初期化します"
	rm -rf frontend
	npx create-react-app frontend --template typescript
	cd frontend && npm install --save-dev eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-react
	@echo "✅ frontend 初期化が完了しました"

.PHONY: frontend-lint
frontend-lint:
	@echo "🔍 フロントエンドの ESLint チェックを実行します"
	cd frontend && npx eslint src --ext .ts,.tsx

.PHONY: frontend-format
frontend-format:
	@echo "🎨 フロントエンドのコード整形を実行します"
	cd frontend && npx eslint src --ext .ts,.tsx --fix

.PHONY: frontend-start
frontend-start:
	@echo "🚀 React アプリを起動します"
	cd frontend && npm start

.PHONY: frontend-install
frontend-install:
	@echo "📦 frontend の依存パッケージをインストールします"
	cd frontend && npm install

.PHONY: init-lint-config
init-lint-config:
	@echo "🧼 Linter/Formatter 設定ファイルを初期化します"
	bash scripts/init_lint_config.sh
