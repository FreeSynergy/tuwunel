# FreeSynergy packaging for Tuwunel — Matrix Homeserver
# Build: podman build -t ghcr.io/freesynergy/tuwunel:latest .
FROM docker.io/library/rust:1-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential clang libclang-dev cmake \
    libssl-dev pkg-config libsqlite3-dev librocksdb-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .
RUN cargo build --release -p tuwunel

FROM docker.io/library/debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/tuwunel /usr/local/bin/tuwunel

RUN useradd -r -s /bin/false tuwunel && \
    mkdir -p /etc/tuwunel /var/lib/tuwunel && \
    chown -R tuwunel:tuwunel /etc/tuwunel /var/lib/tuwunel

VOLUME ["/etc/tuwunel", "/var/lib/tuwunel"]
EXPOSE 8448 8008

USER tuwunel
ENTRYPOINT ["/usr/local/bin/tuwunel"]
CMD ["--config", "/etc/tuwunel/tuwunel.toml"]
