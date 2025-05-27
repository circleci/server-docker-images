FROM bitnami/rabbitmq:latest AS build

FROM bitnami/rabbitmq:3.12

COPY --from=build /opt/bitnami/erlang /opt/bitnami/erlang

RUN
