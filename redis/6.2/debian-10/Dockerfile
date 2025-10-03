# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0
# Modifications copyright (C) 2025 Circle Internet Services, Inc.

# Build stage for Redis
FROM docker.io/bitnami/minideb:buster as redis-builder
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list
RUN install_packages build-essential wget make gcc ca-certificates
RUN wget -O redis.tar.gz https://github.com/redis/redis/archive/refs/tags/6.2.20.tar.gz \
    && tar -xzf redis.tar.gz \
    && cd redis-6.2.20 \
    && make \
    && make install PREFIX=/opt/bitnami/redis \
    && mkdir -p /opt/bitnami/redis/etc \
    && cp redis.conf /opt/bitnami/redis/etc/redis-default.conf \
    && strip /opt/bitnami/redis/bin/* \
    && cd .. \
    && rm -rf redis-6.2.20 redis.tar.gz

# Build stage for wait-for-port
FROM docker.io/bitnami/minideb:buster as wait-for-port-builder
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list
RUN install_packages wget ca-certificates
RUN wget -O wait-for-port.tar.gz https://github.com/bitnami/wait-for-port/releases/download/v1.0.1/wait-for-port-linux-amd64.tar.gz \
    && tar -xzf wait-for-port.tar.gz \
    && find . -name "*wait*" -type f -executable -exec cp {} /usr/local/bin/wait-for-port \; \
    && chmod +x /usr/local/bin/wait-for-port

# Build stage for gosu
FROM docker.io/bitnami/minideb:buster as gosu-builder
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list
RUN install_packages wget ca-certificates
RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu

# Final runtime stage
FROM docker.io/bitnami/minideb:buster
LABEL maintainer="Bitnami <containers@bitnami.com>"

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

COPY prebuildfs /

# Update source lists
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list

# Install only runtime dependencies (minimal set)
RUN install_packages ca-certificates libc6 libssl1.1

# Copy compiled binaries from build stages (only essentials)
COPY --from=redis-builder /opt/bitnami/redis/bin /opt/bitnami/redis/bin
COPY --from=redis-builder /opt/bitnami/redis/etc /opt/bitnami/redis/etc
COPY --from=wait-for-port-builder /usr/local/bin/wait-for-port /usr/local/bin/wait-for-port
COPY --from=gosu-builder /usr/local/bin/gosu /usr/local/bin/gosu

RUN chmod g+rwX /opt/bitnami
RUN ln -s /opt/bitnami/scripts/redis/entrypoint.sh /entrypoint.sh
RUN ln -s /opt/bitnami/scripts/redis/run.sh /run.sh

COPY rootfs /
RUN /opt/bitnami/scripts/redis/postunpack.sh

ENV BITNAMI_APP_NAME="redis" \
    BITNAMI_IMAGE_VERSION="6.2.1-debian-10-r13" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/redis/bin:$PATH"

EXPOSE 6379

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/redis/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/redis/run.sh" ]
