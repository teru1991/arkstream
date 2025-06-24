FROM rust:1.77 AS builder

# 安全性の観点からARGはビルドステージ限定で使用（ENVは削除）
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

WORKDIR /usr/src/app

# 依存解決用に Cargo.* とサブクレートの Cargo.* を先にコピー
COPY Cargo.toml Cargo.lock ./
COPY vault/Cargo.toml vault/Cargo.toml

# 空のmain.rsを使ったビルドキャッシュ回避は使わず、直接ビルド時に無視
# （または以下のように--workspaceで全体の依存解決でもOK）
RUN mkdir src && echo 'fn main() {}' > src/main.rs && \
    echo '[package]\nname = "dummy"\nversion = "0.1.0"\nedition = "2021"\n\n[dependencies]' > Cargo.toml && \
    cargo build --release || true && rm -rf src Cargo.toml

# 残りの全ファイルをコピー
COPY . .

# 必要なクレートだけをビルド（例: vault_test）
RUN cargo build --release -p vault_test

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/target/release/vault_test /usr/local/bin/vault_test

CMD ["vault_test"]
