FROM postgres:14-bookworm

RUN sed -i 's/$/ 12/' /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		postgresql-12='12.22-3.pgdg12+1' \
	; \
	rm -rf /var/lib/apt/lists/*

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

ENV PGBINOLD /usr/lib/postgresql/12/bin
ENV PGBINNEW /usr/lib/postgresql/14/bin

ENV PGDATAOLD /var/lib/postgresql/12/data
ENV PGDATANEW /var/lib/postgresql/14/data

RUN set -eux; \
	mkdir -p "$PGDATAOLD" "$PGDATANEW"; \
	chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]