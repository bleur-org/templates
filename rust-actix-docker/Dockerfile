# Build stage
FROM rust:1.92-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    musl-dev \
    postgresql-dev \
    openssl-dev \
    pkgconfig

# Create app directory
WORKDIR /app

# Copy manifests
COPY Cargo.toml Cargo.lock ./
COPY crates/ ./crates/

# Build the application in release mode
RUN cargo build --release --bin server

# Runtime stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    libgcc \
    libpq \
    ca-certificates

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Create app directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/server /usr/local/bin/server

# Copy config file (optional, can be mounted as volume)
COPY config.toml ./config.toml

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (default from your config)
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8001/ || exit 1

# Run the binary
CMD ["server", "run", "/app/config.toml"]
