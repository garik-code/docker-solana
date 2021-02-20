FROM node
LABEL AUTHOR="Shachindra shachindra@revoticengineering.com"

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates curl file \
    build-essential git wget \
    autoconf automake autotools-dev libtool xutils-dev && \
    rm -rf /var/lib/apt/lists/*

ENV SSL_VERSION=1.1.1j

RUN curl https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz -O && \
    tar -xzf openssl-$SSL_VERSION.tar.gz && \
    cd openssl-$SSL_VERSION && ./config && make depend && make install && \
    cd .. && rm -rf openssl-$SSL_VERSION*

ENV OPENSSL_LIB_DIR=/usr/local/ssl/lib \
    OPENSSL_INCLUDE_DIR=/usr/local/ssl/include \
    OPENSSL_STATIC=1

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain nightly -y

RUN git clone https://github.com/solana-labs/solana.git
RUN wget https://github.com/solana-labs/solana/releases/download/v1.5.8/solana-release-x86_64-unknown-linux-gnu.tar.bz2
RUN tar jxf solana-release-x86_64-unknown-linux-gnu.tar.bz2
RUN rm solana-release-x86_64-unknown-linux-gnu.tar.bz2

ENV PATH=$PWD/solana-release/bin:$PATH
ENV PATH=/root/.cargo/bin:$PATH
ENV USER root

RUN npm install -g node-gyp
RUN npm install -g neon-cli

WORKDIR /root

CMD ["bash"]