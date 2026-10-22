# renovate: datasource=docker depName=kong
ARG KONG_VERSION=3.4.2

FROM kong:${KONG_VERSION}

# The base image runs as the kong user. Package changes need root.
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Distrust the two roots that the compromised eMudhra intermediates chain to
# (CVE-2026-111943). TLS clients here do not check revocation by default, so
# the CA revoking the intermediates is not enough. The build fails if either
# root is still present.
RUN set -eu; \
    for cert in Comodo_AAA_Services_root emSign_ECC_Root_CA_-_G3; do \
      sed -i "s|^mozilla/${cert}.crt$|!mozilla/${cert}.crt|" /etc/ca-certificates.conf; \
    done; \
    update-ca-certificates --fresh; \
    for cert in Comodo_AAA_Services_root emSign_ECC_Root_CA_-_G3; do \
      test ! -e "/etc/ssl/certs/${cert}.pem"; \
    done

# Keep the upstream entrypoint, command, ports, stop signal and healthcheck.
USER kong
