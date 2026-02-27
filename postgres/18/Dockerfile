# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0
# Modifications copyright (C) 2026 Circle Internet Services, Inc.

FROM buildpack-deps:bullseye as build

COPY prebuildfs /

ENV POSTGRESQL_BASE_DIR "/opt/bitnami/postgresql"
ENV PATH="${POSTGRESQL_BASE_DIR}/bin:${PATH}"

# Install PostgreSQL
ENV POSTGRESQL_VERSION 18.2
RUN install_packages bison clang dirmngr flex gosu gnupg libclang-dev libicu-dev libipc-run-perl libkrb5-dev libldap2-dev liblz4-dev locales libpam-dev libperl-dev libpython3-dev libreadline-dev libssl-dev libxml2-dev libxslt1-dev llvm llvm-dev meson ninja-build postgresql-server-dev-all python3-dev tcl-dev uuid-dev
RUN curl -sSL "https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.tar.gz" | tar -xz && \
	cd "postgresql-${POSTGRESQL_VERSION}" && \
	./configure \
		--prefix="${POSTGRESQL_BASE_DIR}" \
		--enable-tap-tests \
		--with-uuid=e2fs \
		--with-pgport=5432 \
		--with-system-tzdata=/usr/share/zoneinfo \
		--with-includes=/usr/local/include \
		--with-libraries=/usr/local/lib \
		--with-gssapi \
		--with-ldap \
		--with-pam \
		--with-tcl \
		--with-perl \
		--with-python \
		--with-openssl \
		--with-libxml \
		--with-libxslt \
		--with-icu \
		--with-lz4 && \
	make -j $(nproc) world-bin && \
	make -j $(nproc) install-world-bin && \
	make clean

# Install pgAudit
ENV POSTGRESQL_PGAUDIT_VERSION 18.0
RUN curl -sSL "https://github.com/pgaudit/pgaudit/archive/${POSTGRESQL_PGAUDIT_VERSION}.tar.gz" | tar -xz && \
    cd pgaudit-${POSTGRESQL_PGAUDIT_VERSION} && \
    make -j $(nproc) USE_PGXS=1 && \
    make -j $(nproc) USE_PGXS=1 install

# Install pgAutoFailover
# TODO: pin to a release tag once hapostgres/pg_auto_failover cuts a release with PG18 support
RUN curl -sSL "https://github.com/hapostgres/pg_auto_failover/archive/refs/heads/main.tar.gz" | tar -xz && \
    cd pg_auto_failover-main && \
    make -j $(nproc) && \
    make -j $(nproc) install && \
    make clean

# Install pgBackRest
ENV POSTGRESQL_PGBACKREST_VERSION 2.58.0
RUN curl -sSL "https://github.com/pgbackrest/pgbackrest/archive/release/${POSTGRESQL_PGBACKREST_VERSION}.tar.gz" | tar -xz && \
    cd pgbackrest-release-${POSTGRESQL_PGBACKREST_VERSION} && \
    meson setup build --prefix="${POSTGRESQL_BASE_DIR}" && \
    ninja -C build && \
    ninja -C build install

ENV NSS_WRAPPER_VERSION 1.1.15
RUN install_packages cmake
RUN curl -sSL "https://ftp.samba.org/pub/cwrap/nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz" | tar -xz && \
    mkdir -p nss_wrapper-${NSS_WRAPPER_VERSION}.tmp && \
    cd nss_wrapper-${NSS_WRAPPER_VERSION}.tmp && \
    cmake ../nss_wrapper-${NSS_WRAPPER_VERSION} -DCMAKE_INSTALL_PREFIX="${POSTGRESQL_BASE_DIR}" && \
    make -j $(nproc) install && \
    make clean

# Install pg_partman
# N.b., pinned to v4.x as v5.x dropped the 'daily' interval type, breaking existing migrations.
ENV POSTGRESQL_PGPARTMAN_VERSION 4.7.4
RUN curl -sSL "https://github.com/pgpartman/pg_partman/archive/refs/tags/v${POSTGRESQL_PGPARTMAN_VERSION}.tar.gz" | tar -xz && \
	cd pg_partman-${POSTGRESQL_PGPARTMAN_VERSION} && \
	make -j $(nproc) install && \
	make clean

# Strip binaries and object files
RUN install_packages binutils
RUN find "${POSTGRESQL_BASE_DIR}" -type f -name '*.o' -o -perm /u=x,g=x,o=x -exec strip {} \; || true

FROM debian:11-slim

ARG EXTRA_LOCALES
ARG TARGETARCH
ARG WITH_ALL_LOCALES="no"

LABEL maintainer="On-Prem Team <on-prem@circleci.com>"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux"

COPY prebuildfs /
COPY --from=build /opt/bitnami/postgresql /opt/bitnami/postgresql
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libbsd0 libbz2-1.0 libedit2 libffi7 libgcc-s1 libgmp10 libgnutls30 libhogweed6 libicu67 libidn2-0 libldap-2.4-2 liblz4-1 liblzma5 libmd0 libncurses6 libnettle8 libp11-kit0 libpcre3 libreadline8 libsasl2-2 libsqlite3-0 libssl1.1 libstdc++6 libtasn1-6 libtinfo6 libunistring2 libuuid1 libxml2 libxslt1.1 libzstd1 locales procps zlib1g
RUN mkdir -p /tmp/bitnami/pkg/cache/ && cd /tmp/bitnami/pkg/cache/
RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
RUN update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

COPY rootfs /
RUN /opt/bitnami/scripts/postgresql/postunpack.sh
RUN /opt/bitnami/scripts/locales/add-extra-locales.sh
ENV APP_VERSION="18.2.0" \
    BITNAMI_APP_NAME="postgresql" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    NSS_WRAPPER_LIB="/opt/bitnami/common/lib/libnss_wrapper.so" \
    PATH="/opt/bitnami/postgresql/bin:$PATH"

RUN useradd -r -u 1001 -g root postgres

VOLUME [ "/bitnami/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d" ]

EXPOSE 5432

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/postgresql/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]
