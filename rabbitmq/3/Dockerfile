FROM bitnami/rabbitmq:latest AS build

FROM bitnami/rabbitmq:3.13

COPY --from=build /opt/bitnami/erlang /opt/bitnami/erlang

USER root

RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

USER 1001
