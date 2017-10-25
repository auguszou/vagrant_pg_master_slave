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
export

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list
apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION}

cp ${PG_SHAREDIR}/postgresql.conf.sample /etc/postgresql/${PG_VERSION}/main/postgresql.conf
cp ${PG_SHAREDIR}/pg_hba.conf.sample /etc/postgresql/${PG_VERSION}/main/pg_hba.conf
cp ${PG_SHAREDIR}/pg_ident.conf.sample /etc/postgresql/${PG_VERSION}/main/pg_ident.conf

rm -rf ${PG_HOME}
rm -rf /var/lib/apt/lists/*

update_pwd="alter user postgres with encrypted password '${PG_PASSWORD}';"
PGPASSWORD=${PG_PASSWORD} psql -d postgres -U ${PG_USER} -w -a -c "${update_pwd}"

add_user="create role '${PG_DUPLICATE_USER}' with login createdb replication encrypted password '${PG_DUPLICATE_PASSWORD}';"
PGPASSWORD=${PG_PASSWORD} psql -d postgres -U ${PG_USER} -w -a -c "${add_user}"

echo "\nhost  all  all 192.168.2.0/24 md5" >> ${PG_DATADIR}/pg_hba.conf

sed -i 's/^listen_addresses.*$/listen_addresses = '*'/g' ${PG_DATADIR}/postgresql.conf

/etc/init.d/postgresql stop
