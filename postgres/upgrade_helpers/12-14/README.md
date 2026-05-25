# postgres-upgrade 12 → 14

A `pg_upgrade` helper image that bundles PostgreSQL 12 and 14 binaries in a single container so `pg_upgrade` can perform an in-place major-version upgrade of a PostgreSQL 12 data directory to PostgreSQL 14. The image is built on `postgres:14-bookworm` with `postgresql-12` installed alongside it, exposing both binary trees via `PGBINOLD` (`/usr/lib/postgresql/12/bin`) and `PGBINNEW` (`/usr/lib/postgresql/14/bin`). The `docker-upgrade` entrypoint wraps `pg_upgrade` with the `initdb` and permission setup needed for the upgrade to run unattended.

The `Dockerfile` and `docker-upgrade` script were copied from [tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade) and are used under the terms of its MIT license; a verbatim copy of that license is included in this directory as [`LICENSE`](./LICENSE). The only local change is pinning the `postgresql-12` `.deb` to a specific pgdg version for reproducible builds.
