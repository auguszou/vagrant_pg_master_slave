source /vagrant/scripts/env.sh

sed -i "s/^max_connections.*$/max_connections = 1024/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]wal_level.*$/wal_level = hot_standby/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]hot_standby.*$/hot_standby = on/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]max_standby_streaming_delay.*$/max_standby_streaming_delay = 30s/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]wal_receiver_status_interval.*$/wal_receiver_status_interval = 1s/g" ${PG_ETCDIR}/postgresql.conf
# sed -i "/^hot_standby.*$/a hot_standby_feedback = on" ${PG_ETCDIR}/postgresql.conf
echo "hot_standby_feedback = on" >> ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]synchronous_commit.*$/synchronous_commit = local/g" ${PG_ETCDIR}/postgresql.conf
sed -i "s/^[#]synchronous_standby_names.*$/synchronous_standby_names = ''/g" ${PG_ETCDIR}/postgresql.conf

mkdir -p ~/.ssh/
cat > ~/.ssh/config <<EOF
Host 192.168.2.*
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    CheckHostIP=no
EOF

start_backup="SELECT pg_start_backup('mybackup_label', true);"
PGPASSWORD=${PG_PASSWORD} psql -d postgres -U ${PG_USER} -h ${PG_MASTER_HOST} -w -a -c "${start_backup}"

sshpass -p ${MASTER_ROOT_PASSWORD} rsync -ac --exclude=*pg_xlog* --exclude postmaster.pid root@${PG_MASTER_HOST}:${PG_DATADIR} ${PG_DATADIR}

stop_backup="SELECT pg_stop_backup();"
PGPASSWORD=${PG_PASSWORD} psql -d postgres -U ${PG_USER} -h ${PG_MASTER_HOST} -w -a -c "${stop_backup}"

rm -rf ${PG_DATADIR}/*
PGPASSWORD=${PG_PASSWORD} pg_basebackup -D ${PG_DATADIR} -h ${PG_MASTER_HOST} -P -U ${PG_DUPLICATE_USER} --xlog-method=stream

cp ${PG_SHAREDIR}/recovery.conf.sample ${PG_DATADIR}/recovery.conf

sed -i "s/^[#]standby_mode.*$/standby_mode = on/g" ${PG_DATADIR}/recovery.conf
sed -i "s/^[#]recovery_target_timeline.*$/recovery_target_timeline = 'latest'/g" ${PG_DATADIR}/recovery.conf
sed -i "s/^[#]primary_conninfo.*$/primary_conninfo = 'host=${PG_MASTER_HOST} port=${PG_MASTER_POST} user=${PG_DUPLICATE_USER} password=${PG_DUPLICATE_PASSWORD}'/g" ${PG_DATADIR}/recovery.conf
# sed -i "s/^[#]sslmode.*$/sslmode = 'on'/g" ${PG_DATADIR}/recovery.conf
sed -i "s/^[#]restore_command.*$/restore_command = 'cp \/var\/lib\/postgresql\/${PG_VERSION}\/main\/archive\/%f %p'/g" ${PG_DATADIR}/recovery.conf
sed -i "s/^[#]trigger_file.*$/trigger_file = \/var\/lib\/postgresql\/${PG_VERSION}\/main\/postgresql.trigger.5432'/g" ${PG_DATADIR}/recovery.conf

/etc/init.d/postgresql restart

sshpass -p ${MASTER_ROOT_PASSWORD} ssh root@${PG_MASTER_HOST} /etc/init.d/postgresql restart