#!/bin/bash

# N.b., any global environment variables are defined in `/opt/bitnami/postgresql-env.sh`
echo "shared_preload_libraries = 'pg_cron'" >>"${POSTGRESQL_CONF_FILE}"
echo "cron.database_name = 'conductor_production'" >>"${POSTGRESQL_CONF_FILE}" # this is used by workflows-conductor
