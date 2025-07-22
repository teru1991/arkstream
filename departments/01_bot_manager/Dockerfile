FROM rustlang/rust:nightly-slim as builder
WORKDIR /usr/src/app
COPY . .
RUN apt-get update && apt-get install -y pkg-config libssl-dev && \
    cargo build --release

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y libssl1.1 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /usr/src/app/target/release/bot_manager .
ENV RUST_LOG=info
EXPOSE 8080
CMD ["./bot_manager"]
