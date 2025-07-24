# ✅ ビルドステージ（Rust + OpenSSL対応）
FROM rust:1.73-slim-bullseye AS builder

WORKDIR /app
COPY . .

# ビルドに必要な依存をインストール
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev build-essential ca-certificates && \
    cargo build --release

# ✅ 実行ステージ（GLIBC対応 + 安全な最小構成）
FROM debian:bookworm-slim

# 最新GLIBC + OpenSSL 3対応
RUN apt-get update && \
    apt-get install -y libssl3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/bot_manager .

# 推奨: ユーザー追加（セキュリティ向上）
RUN useradd -m botuser
USER botuser

ENV RUST_LOG=info
EXPOSE 8080
ENTRYPOINT ["./bot_manager"]
