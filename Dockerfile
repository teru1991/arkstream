# 🏗 Stage 1: Build
FROM rust:1.87 as builder

WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src && echo 'fn main() {}' > src/main.rs && cargo build --release || true
COPY . .

# ✅ Vault Secrets (for Docker ARGs)
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
ENV MONGO_URI=$MONGO_URI
ENV KAFKA_BROKER=$KAFKA_BROKER

# bin crate をビルド
RUN cargo build --release --bin vault_test

# 🐧 Stage 2: Runtime
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/app/target/release/vault_test /usr/local/bin/vault_test

# ✅ 環境変数を明示的に再設定（任意）
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
ENV MONGO_URI=$MONGO_URI
ENV KAFKA_BROKER=$KAFKA_BROKER

CMD ["vault_test"]
