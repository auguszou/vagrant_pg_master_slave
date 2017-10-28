source /vagrant/scripts/env.sh

update_pwd="alter user postgres with encrypted password '${PG_PASSWORD}';"
PGPASSWORD=${PG_PASSWORD} sudo -u postgres psql -d postgres -U ${PG_USER} -w -a -c "${update_pwd}"

add_user="create role ${PG_DUPLICATE_USER} with replication login encrypted password '${PG_DUPLICATE_PASSWORD}';"
PGPASSWORD=${PG_PASSWORD} sudo -u postgres psql -d postgres -U ${PG_USER} -w -a -c "${add_user}"

echo "host     all             postgres        192.168.2.0/24          md5" >> ${PG_ETCDIR}/pg_hba.conf
echo "host     replication     ${PG_DUPLICATE_USER}          192.168.2.0/24          md5" >> ${PG_ETCDIR}/pg_hba.conf

sed -i "s/^[#]wal_level.*$/wal_level = hot_standby/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]fsync.*$/fsync = on/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]max_wal_senders.*$/max_wal_senders = 8/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]wal_keep_segments.*$/wal_keep_segments = 256/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]wal_sender_timeout.*$/wal_sender_timeout = 60s/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]max_connections.*$/max_connections = 512/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]synchronous_commit.*$/synchronous_commit = local/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]synchronous_standby_names.*$/synchronous_standby_names = '*'/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]archive_mode.*$/archive_mode = on/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]archive_command.*$/archive_command = 'cp %p \/var\/lib\/postgresql\/${PG_VERSION}\/main\/archive\/%f'/g" ${PG_ETCDIR}/postgresql.conf

mkdir -p ${PG_DATADIR}/archive
chmod 700 ${PG_DATADIR}/archive && chown postgres:postgres ${PG_DATADIR}/archive

/etc/init.d/postgresql restart