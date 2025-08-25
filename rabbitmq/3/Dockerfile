# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0
# Modifications copyright (C) 2025 Circle Internet Services, Inc.

FROM debian:bookworm-slim AS builder

ARG ERLANG_VERSION=27.3.4.2
ARG RABBITMQ_VERSION=3.12.14

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl build-essential autoconf m4 libncurses-dev libssl-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Erlang from source
RUN curl -1sLf https://github.com/erlang/otp/releases/download/OTP-${ERLANG_VERSION}/otp_src_${ERLANG_VERSION}.tar.gz -o otp_src_${ERLANG_VERSION}.tar.gz && \
    tar -xzf otp_src_${ERLANG_VERSION}.tar.gz && \
    cd otp_src_${ERLANG_VERSION} && \
    ./configure --prefix=/opt/bitnami/erlang --enable-shared-zlib --enable-ssl-dynamic-linking --without-javac --without-wx --without-debugger --without-observer --without-et --without-dialyzer --without-typer --without-common_test --without-eunit --without-megaco --without-odbc --disable-static-libs && \
    make && \
    make install && \
    cd .. && \
    rm -rf otp_src_${ERLANG_VERSION} otp_src_${ERLANG_VERSION}.tar.gz && \
    find /opt/bitnami/erlang -type f -executable -exec strip --strip-debug {} \; 2>/dev/null || true

# Install RabbitMQ from source
RUN curl -1sLf https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz -o rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
    tar -xJf rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
    mv rabbitmq_server-${RABBITMQ_VERSION} /opt/bitnami/rabbitmq && \
    rm rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
    rm -rf /opt/bitnami/rabbitmq/share/doc /opt/bitnami/rabbitmq/share/man /opt/bitnami/rabbitmq/INSTALL* /opt/bitnami/rabbitmq/LICENSE* /opt/bitnami/rabbitmq/README*

FROM debian:bookworm-slim

ARG TARGETARCH
ARG RABBITMQ_VERSION=3.12.14

LABEL maintainer="On-Prem Team <on-prem@circleci.com>"

ENV HOME="/opt/bitnami/rabbitmq/.rabbitmq" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/erlang/bin:/opt/bitnami/rabbitmq/sbin:$PATH" \
    RABBITMQ_HOME="/opt/bitnami/rabbitmq" \
    RABBITMQ_LOGS="-" \
    RABBITMQ_SASL_LOGS="-"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

# Install runtime dependencies only
RUN install_packages ca-certificates curl libgcc-s1 libssl3 libstdc++6 libtinfo6 locales procps zlib1g

COPY --from=builder /opt/bitnami/erlang /opt/bitnami/erlang
COPY --from=builder /opt/bitnami/rabbitmq /opt/bitnami/rabbitmq

RUN useradd -u 1001 -g root -d /opt/bitnami/rabbitmq rabbitmq

RUN chmod g+rwX /opt/bitnami && \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8 && \
    find / -perm /6000 -type f -exec chmod a-s {} \; 2>/dev/null || true && \
    update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

COPY rootfs /
RUN /opt/bitnami/scripts/rabbitmq/postunpack.sh
RUN /opt/bitnami/scripts/locales/add-extra-locales.sh

ENV APP_VERSION="${RABBITMQ_VERSION}" \
    BITNAMI_APP_NAME="rabbitmq" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    RABBITMQ_ERLANG_COOKIE="RABBITMQCOOKIE"

EXPOSE 4369 5551 5552 5671 5672 15671 15672 25672

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/rabbitmq/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/rabbitmq/run.sh" ]
