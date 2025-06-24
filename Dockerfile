# ========================================
# 🌱 Build Stage
# ========================================
FROM rust:1.77 AS builder

# 環境変数（Vault CLIなどのデバッグ用）
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV MONGO_URI=${MONGO_URI}
ENV KAFKA_BROKER=${KAFKA_BROKER}

WORKDIR /usr/src/app

# Cargo先にコピー（ビルドキャッシュ最適化）
COPY Cargo.toml Cargo.lock ./
COPY vault/Cargo.toml vault/Cargo.toml

# 必要なファイル構成を作ってビルド
RUN mkdir -p vault/src && echo 'fn main() {}' > vault/src/main.rs
RUN cargo build --release --package vault_test || echo "initial build placeholder"
RUN rm -rf vault/src

# 残りのファイル全てコピー
COPY . .

# vault_test を example としてビルド
RUN cargo build --release --example vault_test

# ========================================
# 🏃 Runtime Stage
# ========================================
FROM debian:bookworm-slim

# Vaultバイナリが依存する ca-certificates のみ必要
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# 実行バイナリのコピー（正しいビルド出力場所を指定）
COPY --from=builder /usr/src/app/target/release/examples/vault_test /usr/local/bin/vault_test

# 実行
CMD ["vault_test"]
