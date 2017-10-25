sed -i 's/^wal_level.*$/wal_level = hot_standby/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^fsync.*$/fsync = on/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^max_wal_senders.*$/max_wal_senders = 1/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^wal_keep_segments.*$/wal_keep_segments = 256/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^wal_sender_timeout.*$/wal_sender_timeout = 60s/g' ${PG_ETCDIR}/postgresql.conf
sed -i 's/^max_connections.*$/max_connections = 512/g' ${PG_ETCDIR}/postgresql.conf

/etc/init.d/postgres restart