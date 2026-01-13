FROM rust:1.91-slim-bookworm AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev libpq-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY Cargo.toml Cargo.lock ./
COPY crates/ ./crates/

RUN cargo build --release --bin server || true

COPY . .

RUN cargo build --release --bin server && \
    strip --strip-all target/release/server

RUN cargo install diesel_cli --no-default-features --features postgres

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/target/release/server /usr/local/bin/server
COPY --from=builder /usr/local/cargo/bin/diesel /usr/local/bin/diesel
COPY --from=builder /build/crates/database/migrations ./migrations

RUN useradd -m -u 10001 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8001

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8001/ || exit 1

CMD sh -c '\
    if [ ! -f /app/config.toml ]; then \
        echo "Generating default config.toml..."; \
        server config generate /app/config.toml; \
    fi && \
    server server run /app/config.toml'
