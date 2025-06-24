# 🏗 Stage 1: Build
FROM rust:1.87 as builder

WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src && echo 'fn main() {}' > src/main.rs && cargo build --release || true
COPY . .

# bin crate をビルド（vault_testはCargo.tomlに[[bin]]またはmain.rsが必要）
RUN cargo build --release --bin vault_test

# 🐧 Stage 2: Runtime
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/app/target/release/vault_test /usr/local/bin/vault_test

CMD ["vault_test"]
