# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0
# Modifications copyright (C) 2025 Circle Internet Services, Inc.

FROM docker.io/bitnami/minideb:bookworm

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

RUN install_packages ca-certificates curl libbrotli1 libcom-err2 libcurl4 libffi8 libgcc-s1 libgmp10 libgnutls30 libgssapi-krb5-2 libhogweed6 libidn2-0 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.5-0 libnettle8 libnghttp2-14 libp11-kit0 libpsl5 librtmp1 libsasl2-2 libssh2-1 libssl3 libtasn1-6 libunistring2 libzstd1 numactl procps zlib1g wget gnupg2
RUN mkdir -p /opt/bitnami/common/bin /tmp/downloads && cd /tmp/downloads && \
    curl -L -o yq https://github.com/mikefarah/yq/releases/download/v4.44.6/yq_linux_amd64 && \
    chmod +x yq && mv yq /opt/bitnami/common/bin/ && \
    \
    curl -L -o wait-for-port.tar.gz https://github.com/bitnami/wait-for-port/releases/download/v1.0.8/wait-for-port-linux-amd64.tar.gz && \
    tar -xzf wait-for-port.tar.gz && \
    find . -name "*wait*" -type f -executable -exec cp {} /opt/bitnami/common/bin/wait-for-port \; && \
    chmod +x /opt/bitnami/common/bin/wait-for-port && \
    \
    curl -L -o render-template.tar.gz https://github.com/bitnami/render-template/releases/download/v1.0.7/render-template-linux-amd64.tar.gz && \
    tar -xzf render-template.tar.gz && \
    find . -name "*render*" -type f -executable -exec cp {} /opt/bitnami/common/bin/render-template \; && \
    chmod +x /opt/bitnami/common/bin/render-template && \
    \
    curl -L -o mongosh.tgz https://downloads.mongodb.com/compass/mongosh-2.3.4-linux-x64.tgz && \
    tar -xzf mongosh.tgz && \
    cp mongosh-*/bin/* /opt/bitnami/common/bin/ && \
    \
    curl -L -o mongodb.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian12-7.0.15.tgz && \
    tar -xzf mongodb.tgz && \
    cp mongodb-linux-*/bin/* /opt/bitnami/common/bin/ && \
    \
    cd / && rm -rf /tmp/downloads

RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitnami/scripts/mongodb/postunpack.sh
ENV APP_VERSION="7.0.15" \
    BITNAMI_APP_NAME="mongodb" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/mongodb/bin:$PATH"

EXPOSE 27017

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mongodb/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mongodb/run.sh" ]
