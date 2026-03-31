# FreeSynergy packaging for Tuwunel (Matrix homeserver)
# Build: podman build -t ghcr.io/freesynergy/tuwunel:latest .
FROM docker.io/library/rust:1-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential clang libclang-dev cmake libssl-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .
RUN cargo build --release \
    --no-default-features \
    --features "gzip_compression,brotli_compression,zstd_compression,url_preview,media_thumbnail,release_max_log_level"

FROM docker.io/library/debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/tuwunel /usr/local/bin/tuwunel

RUN useradd -r -s /bin/false tuwunel && \
    mkdir -p /etc/tuwunel /var/lib/tuwunel && \
    chown -R tuwunel:tuwunel /etc/tuwunel /var/lib/tuwunel

VOLUME ["/etc/tuwunel", "/var/lib/tuwunel"]
EXPOSE 8448 6167

USER tuwunel
ENTRYPOINT ["/usr/local/bin/tuwunel"]
CMD ["--config", "/etc/tuwunel/config.toml"]
