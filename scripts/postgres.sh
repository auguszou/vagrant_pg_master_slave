source /vagrant/scripts/env.sh

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list
apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get install -yy postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION}

mkdir -p ${PG_DATADIR}
if [[ -d ${PG_DATADIR} ]]; then
  find ${PG_DATADIR} -type f -exec chmod 0600 {} \;
  find ${PG_DATADIR} -type d -exec chmod 0700 {} \;
fi
chown -R ${PG_USER}:${PG_USER} ${PG_HOME}

# cp ${PG_SHAREDIR}/postgresql.conf.sample ${PG_ETCDIR}/postgresql.conf
# cp ${PG_SHAREDIR}/pg_hba.conf.sample ${PG_ETCDIR}/pg_hba.conf
# cp ${PG_SHAREDIR}/pg_ident.conf.sample ${PG_ETCDIR}/pg_ident.conf

apt-get clean && apt-get autoclean
rm -rf /var/lib/apt/lists/*

update_pwd="alter user postgres with encrypted password '${PG_PASSWORD}';"
PGPASSWORD=${PG_PASSWORD} psql -d postgres -U ${PG_USER} -w -a -c "${update_pwd}"

add_user="create role '${PG_DUPLICATE_USER}' with login createdb replication encrypted password '${PG_DUPLICATE_PASSWORD}';"
PGPASSWORD=${PG_PASSWORD} psql -d postgres -U ${PG_USER} -w -a -c "${add_user}"

echo "host  all  all 192.168.2.0/24 md5" >> ${PG_ETCDIR}/pg_hba.conf

sed -i 's/^[#]listen_addresses.*$/listen_addresses = \'*\'/g' ${PG_ETCDIR}/postgresql.conf

# su - ${PG_USR} -l -c "${PG_BINDIR}/pg_ctl -D ${PG_DATADIR} -w start"

/etc/init.d/postgresql stop
