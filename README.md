Postgres master-slave backup
=========================

### test
1. `vagrant up`

1. login master1, `vagrant ssh master1`

1. login pg, `psql postgres -U postgres -h localhost`

1. check replication status, `select * from pg_stat_replication;`