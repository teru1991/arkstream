# ベースイメージ（FROM を大文字に修正）
FROM rust:1.77 AS builder

# ビルド引数の受け取り（安全な方法に切り替えることは後述）
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

# 作業ディレクトリ
WORKDIR /usr/src/app

# Cargo 関連ファイルを先にコピー（依存解決用）
COPY Cargo.toml Cargo.lock ./
COPY vault/Cargo.toml vault/Cargo.toml
RUN mkdir src && echo 'fn main() {}' > src/main.rs && cargo build --release && rm -rf src

# 残りのプロジェクト全体をコピー（.dockerignore に注意）
COPY . .

# 本ビルド
RUN cargo build --release -p vault_test

# 実行用の軽量イメージにコピー
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/target/release/vault_test /usr/local/bin/vault_test

CMD ["vault_test"]
