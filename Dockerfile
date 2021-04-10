FROM ubuntu:latest

WORKDIR /opt
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ 'Europe/Moscow'
RUN apt-get update -y
RUN echo $TZ > /etc/timezone && \
apt-get install -y tzdata make clang pkg-config libssl-dev build-essential ntp curl git && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata
RUN ntpq -p

# System packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        file \
        gcc \
        git \
        libc6-dev \
        liblzma-dev \
        libssl-dev \
        make \
        pkg-config \
        yarn \
        ; \
    apt-get autoremove; \
    rm -rf /var/lib/apt/lists/*

# Rust toolchain
# Make sure this is in sync with rust-toolchain!
ENV RUST_VERSION=nightly-2020-11-10 \
    RUST_BACKTRACE=1 \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUSTUP_HOME=/usr/local/rustup \
    RUSTUP_VERSION=1.22.1 \
    RUSTUP_SHA256=49c96f3f74be82f4752b8bffcf81961dea5e6e94ce1ccba94435f12e871c3bdb

RUN set -eux; \
    curl -LOf "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-gnu/rustup-init"; \
    echo "${RUSTUP_SHA256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; \
    rustup component add clippy rustfmt; \
    cargo install cargo-deny; \
    rm -rf /usr/local/cargo/registry; \
    rm /usr/local/cargo/.package-cache;

COPY . ./radicle-bins
CMD tail -f /dev/null
