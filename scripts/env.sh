export PG_MASTER_HOST="192.168.2.10"
export PG_MASTER_POST=5432

export MASTER_ROOT_PASSWORD="vagrant"

export PG_APP_HOME="/etc/docker-postgresql"
export PG_VERSION=9.6
export PG_USER=postgres
export PG_PASSWORD=123
export PG_HOME=/var/lib/postgresql
export PG_RUNDIR=/run/postgresql
export PG_LOGDIR=/var/log/postgresql
export PG_CERTDIR=/etc/postgresql/certs

export PG_SHAREDIR=/usr/share/postgresql/${PG_VERSION}
export PG_ETCDIR=/etc/postgresql/${PG_VERSION}/main
export PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin
export PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

export PG_DUPLICATE_USER=copydb
export PG_DUPLICATE_PASSWORD=123