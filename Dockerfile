# 🏗 Stage 1: Build
FROM rust:1.87 as builder

WORKDIR /usr/src/app

# 依存解決をキャッシュ
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src && echo 'fn main() {}' > src/main.rs && cargo build --release

# アプリのソースコピー
COPY . .

# vault_test バイナリをビルド
RUN cargo build --release --bin vault_test

# 🐧 Stage 2: Runtime
FROM debian:bookworm-slim

LABEL maintainer="keiji@studiokeke.com"
LABEL org.opencontainers.image.source="https://github.com/StudioKeKe/profinaut"
LABEL org.opencontainers.image.description="Vault接続テスト用バイナリ vault_test"

# 必要最小限のパッケージのみ
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# vault_test をコピー
COPY --from=builder /usr/src/app/target/release/vault_test /usr/local/bin/vault_test

# ビルド時に渡されるARG（CIから--build-argで注入）
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

# 実行時の環境変数（VaultまたはDocker runで注入）
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV MONGO_URI=${MONGO_URI}
ENV KAFKA_BROKER=${KAFKA_BROKER}

# 作業ディレクトリ
WORKDIR /app

# 実行コマンド
ENTRYPOINT ["vault_test"]