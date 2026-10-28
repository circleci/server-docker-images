# renovate: datasource=docker depName=nginxinc/nginx-unprivileged
ARG NGINX_VERSION=1.30.1

FROM nginxinc/nginx-unprivileged:${NGINX_VERSION}

# The base image runs as the unprivileged nginx user (101). Package changes need root.
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Keep the upstream entrypoint, command, ports and stop signal.
USER 101
