export PG_APP_HOME="/etc/docker-postgresql"
export PG_VERSION=9.6
export PG_USER=postgres
export PG_HOME=/var/lib/postgresql
export PG_RUNDIR=/run/postgresql
export PG_LOGDIR=/var/log/postgresql
export PG_CERTDIR=/etc/postgresql/certs

export PG_ETCDIR=${PG_HOME}/${PG_VERSION}/main
export PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin
export PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list
apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION}

ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf
ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf
ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf
rm -rf ${PG_HOME}
rm -rf /var/lib/apt/lists/*

cmd="alter user postgres with password '123';"
su - ${PG_USER} -c "psql ${PG_USER} -U ${PG_USER} -c \"${cmd}\""

sed -i 's/^listen_addresses.*$/listen_addresses = '*'/g' ${PG_ETCDIR}/postgresql.conf
echo "\nhost  all  all 0.0.0.0/0 md5" >> ${PG_ETCDIR}/pg_hba.conf

/etc/init.d/postgres restart
