FROM rust:1.77 AS builder

ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG MONGO_URI
ARG KAFKA_BROKER

# 以下のENVは本番では極力避けること（安全性に留意）
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV MONGO_URI=${MONGO_URI}
ENV KAFKA_BROKER=${KAFKA_BROKER}

WORKDIR /usr/src/app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo 'fn main() {}' > src/main.rs
RUN cargo build --release && rm -rf src

COPY . .
RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/target/release/arkstream /usr/local/bin/arkstream

CMD ["arkstream"]
