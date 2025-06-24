# ========================================
# 🛠 Build stage
# ========================================
FROM rust:1.77 AS builder

# 👇 セキュアではないので、開発/テスト用にのみ使用（本番では削除推奨）
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV MONGO_URI=${MONGO_URI}
ENV KAFKA_BROKER=${KAFKA_BROKER}

WORKDIR /usr/src/app

# 必要なCargo.toml/Cargo.lockを先にコピーしてビルドキャッシュを効かせる
COPY Cargo.toml Cargo.lock ./
COPY vault/Cargo.toml vault/Cargo.toml

# ダミーmainで依存解決
RUN mkdir src && echo 'fn main() {}' > src/main.rs
RUN cargo build --release || true  # ダミーmainで一旦解決
RUN rm -rf src

# 📦 プロジェクトの全体コードをコピー
COPY . .

# ✅ vault_test example のビルド（ここが重要）
RUN cargo build --release --example vault_test

# ========================================
# 🏃 Runtime stage
# ========================================
FROM debian:bookworm-slim

# Rustのバイナリ実行に必要なライブラリのみ残す
RUN apt-get update && apt-get install -y \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 🔽 vault_test バイナリのみコピー
COPY --from=builder /usr/src/app/target/release/examples/vault_test /usr/local/bin/vault_test

# 🔽 実行環境に渡したいならここに ENV で注入（Vaultから取得したものを runtimeで渡す想定）
# ENV POSTGRES_USER=...  # 本番ではここに secrets を直接書かない！

# ✅ デフォルト実行コマンド
CMD ["vault_test"]
