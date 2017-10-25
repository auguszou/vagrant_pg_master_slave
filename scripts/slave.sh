sed -i 's/^max_connections.*$/max_connections = 1024/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^hot_standby.*$/hot_standby = on/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^max_standby_streaming_delay.*$/max_standby_streaming_delay = 30s/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^wal_receiver_status_interval.*$/wal_receiver_status_interval = 1s/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^hot_standby_feedback.*$/hot_standby_feedback = on/g' ${PG_ETCDIR}/postgresql.conf

PGPASSWORD=${PG_PASSWORD} pg_basebackup -F p --progress -D ${PG_DATADIR} -h ${PG_MASTER_HOST} -p ${PG_MASTER_POST} -U ${PG_DUPLICATE_USER} -w -a

cp /usr/share/postgresql/9.6/recovery.conf.sample ${PG_DATADIR}/recovery.conf

sed -i "s/^standby_mode.*$/standby_mode = on/g" ${PG_DATADIR}/recovery.conf
sed -i "s/^recovery_target_timeline.*$/recovery_target_timeline = 'latest'/g" ${PG_DATADIR}/recovery.conf
sed -i "s/^primary_conninfo.*$/primary_conninfo = 'host=${PG_MASTER_HOST} port=${PG_MASTER_POST} user=${PG_DUPLICATE_USER} password=${PG_DUPLICATE_PASSWORD}'/g" ${PG_DATADIR}/recovery.conf
# sed -i "s/^sslmode.*$/sslmode = 'on'/g" ${PG_DATADIR}/recovery.conf

/etc/init.d/postgres restart