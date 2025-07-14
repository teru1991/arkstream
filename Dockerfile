# 🏗 Stage 1: Build
FROM rust:1.87 as builder

WORKDIR /usr/src/app

# 依存解決をキャッシュ
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src && echo 'fn main() {}' > src/main.rs && cargo build --release || true

# アプリのソースコピー
COPY . .

# vault_test ビルド
RUN cargo build --release --bin vault_test

# 🐧 Stage 2: Runtime
FROM debian:bookworm-slim

# CA証明書のみインストール
RUN apt-get update \
    && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# vault_test をコピー
COPY --from=builder /usr/src/app/target/release/vault_test /usr/local/bin/vault_test

# ✅ ビルド時に渡すARG（必要な場合）
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

# ✅ 実行時に利用するENV
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV MONGO_URI=${MONGO_URI}
ENV KAFKA_BROKER=${KAFKA_BROKER}

# デフォルトCMD
CMD ["vault_test"]