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

FROM builder AS diesel_builder
RUN cargo install diesel_cli --no-default-features --features postgres

# APP image with diesel CLI
FROM debian:bookworm-slim AS app
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/target/release/server /usr/local/bin/server
COPY --from=builder /build/config.toml /app/config.toml
COPY --from=diesel_builder /usr/local/cargo/bin/diesel /usr/local/bin/diesel
COPY --from=builder /build/crates/database/migrations /app/migrations
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 8001
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD curl -fsS http://localhost:8001/healthz || exit 1
CMD ["server", "server", "run", "/app/config.toml"]
