# renovate: datasource=docker depName=nginx/nginx-unprivileged
ARG NGINX_VERSION=1.31.8

FROM nginx/nginx-unprivileged:${NGINX_VERSION}

# The base image runs as the unprivileged nginx user (101). Package changes need root.
USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Keep the upstream entrypoint, command, ports and stop signal.
USER 101
