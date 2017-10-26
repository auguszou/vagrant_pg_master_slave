source /vagrant/scripts/env.sh

sed -i 's/^max_connections.*$/max_connections = 1024/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^hot_standby.*$/hot_standby = on/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^max_standby_streaming_delay.*$/max_standby_streaming_delay = 30s/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^wal_receiver_status_interval.*$/wal_receiver_status_interval = 1s/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^hot_standby_feedback.*$/hot_standby_feedback = on/g' ${PG_ETCDIR}/postgresql.conf

# PGPASSWORD=${PG_PASSWORD} pg_basebackup -F p --progress -D ${PG_DATADIR} -h ${PG_MASTER_HOST} -p ${PG_MASTER_POST} -U ${PG_DUPLICATE_USER} -w -a

cp ${PG_SHAREDIR}/recovery.conf.sample ${PG_ETCDIR}/recovery.conf

sed -i "s/^standby_mode.*$/standby_mode = on/g" ${PG_ETCDIR}/recovery.conf
sed -i "s/^recovery_target_timeline.*$/recovery_target_timeline = 'latest'/g" ${PG_ETCDIR}/recovery.conf
sed -i "s/^primary_conninfo.*$/primary_conninfo = 'host=${PG_MASTER_HOST} port=${PG_MASTER_POST} user=${PG_DUPLICATE_USER} password=${PG_DUPLICATE_PASSWORD}'/g" ${PG_ETCDIR}/recovery.conf
# sed -i "s/^sslmode.*$/sslmode = 'on'/g" ${PG_DATADIR}/recovery.conf

sshpass -p ${MASTER_ROOT_PASSWORD} rsync -cva --inplace --exclude=*pg_xlog* ${PG_MASTER_HOST}:${PG_DATADIR} ${PG_DATADIR}

/etc/init.d/postgresql restart

export cmd_ssh="sshpass -p ${MASTER_ROOT_PASSWORD} ssh -o StrictHostKeyChecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null root@${PG_MASTER_HOST}"
${cmd_ssh} /etc/init.d/postgresql restart