Postgres master-slave backup
=========================

### test
1. `vagrant up`

#### master
1. login master1, `vagrant ssh master1`

1. login pg, `psql postgres -U postgres -h localhost`

1. check replication status, `select * from pg_stat_replication;`

1. create table `create table person(id integer, name varchar(64));`

1. insert data `insert into person values(1, 'alice');`

#### slave
1. login slave1, `vagrant ssh master2`

1. login pg, `psql postgres -U postgres -h localhost`

1. query table `select * from person;`

### setup steps

#### master
1. update postgresql.conf
```
listen_addresses = '*'
wal_level = hot_standby
fsync = on
max_wal_senders = 8
wal_keep_segments = 256
wal_sender_timeout = 60s
max_connections = 512
synchronous_commit = local
synchronous_standby_names = '*'
archive_mode = on
archive_command = 'cp %p ${PG_DATADIR}/archive/%f'
```

2. create deplicate role `copydb`
```sql
create role copydb with replication login encrypted password '${PG_DUPLICATE_PASSWORD}';
```

3. grant access privileges, add this line to pg_hba.conf
```
host     replication     copydb          192.168.2.0/24          md5
```

4. create archive directory, and update owner
```bash
mkdir -p ${PG_DATADIR}/archive
chmod 700 ${PG_DATADIR}/archive && chown postgres:postgres ${PG_DATADIR}/archive
```

5. restart postgres server
```bash
/etc/init.d/postgresql restart
```

#### slave
1. update postgresql.conf
```
listen_addresses = '*'
max_connections = 1024
wal_level = hot_standby
hot_standby = on
hot_standby_feedback = on
max_standby_streaming_delay = 30s
wal_receiver_status_interval = 1s
synchronous_commit = local
synchronous_standby_names = ''
```

2. sync master data directory to slave
```
SELECT pg_start_backup('mybackup_label', true); # executed in master server pg cmd
rsync -ac --exclude=*pg_xlog* --exclude postmaster.pid root@${PG_MASTER_HOST}:${PG_DATADIR} ${PG_DATADIR} # executed in slave server cmd
SELECT pg_stop_backup(); # executed in master server pg cmd
```
or
```bash
pg_basebackup -D ${PG_DATADIR} -h ${PG_MASTER_HOST} -P -U copydb --xlog-method=stream
```

3. update ${PG_DATADIR}/recovery.conf
```
standby_mode = on
recovery_target_timeline = 'latest'
primary_conninfo = 'host=${PG_MASTER_HOST} port=${PG_MASTER_POST} user=copydb password=${PG_DUPLICATE_PASSWORD}'
restore_command = 'cp ${PG_DATADIR}/archive/%f %p'
trigger_file = '${PG_DATADIR}/postgresql.trigger.5432'
```

4. update postgres data directory owner
```bash
chown -R postgres:postgres ${PG_DATADIR}
```

5. restart master postgres server and slave postgres server
```bash
/etc/init.d/postgresql restart
ssh root@${PG_MASTER_HOST} /etc/init.d/postgresql restart
```