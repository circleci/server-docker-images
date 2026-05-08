#!/bin/bash

# N.b., any global environment variables are defined in `/opt/bitnami/postgresql-env.sh`
echo "shared_preload_libraries = 'pg_partman_bgw'" >>"${POSTGRESQL_CONF_FILE}"
echo "pg_partman_bgw.interval = 3600" >>"${POSTGRESQL_CONF_FILE}"
echo "pg_partman_bgw.role = 'postgres'" >>"${POSTGRESQL_CONF_FILE}"
echo "pg_partman_bgw.dbname = 'conductor_production'" >>"${POSTGRESQL_CONF_FILE}"
