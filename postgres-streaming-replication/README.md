postgres streaming replication for vagrant

## required

+ Vagrant
+ Virtual Box

## vagrant up

```
cd vagrant/
vagrant up --provider virtualbox
```

※以下は全て仮想OS上で実行する

## pg1(host) with vagrant(user)

```
$ git clone https://github.com/Thirosue/ansible-samples.git
$ cd ansible-samples/postgres-streaming-replication/
$ ansible-playbook -i hosts main.yml -vv
```

## pg1(host) with postgres(user)

create repl user

```
$ pg_ctl start -D /var/lib/pgsql/data/
$ psql
postgres=# CREATE USER repl_user REPLICATION PASSWORD 'password';
CREATE ROLE
postgres=# \q
```

create backup and db sync (pg1 -> pg2)

```
$ mkdir /var/lib/pgsql/bk
$ pg_basebackup -h localhost -U repl_user -D /var/lib/pgsql/bk/ -P --xlog
36413/36413 kB (100%), 1/1 tablespace

$ cd /var/lib/pgsql/
$ tar cvfz bk.tgz bk/
$ scp bk.tgz vagrant@192.168.202.2:
```

## pg2(host) with root(user)

db sync (pg1 -> pg2)

```
$ mv bk.tgz /var/lib/pgsql/
$ tar xvfz bk.tgz
$ rm -rf /var/lib/pgsql/data/
$ mv bk /var/lib/pgsql/data/
```

add replication conf

```
$ echo 'hot_standby = on' >> /var/lib/pgsql/data/postgresql.conf
$ echo 'standby_mode = on' >> /var/lib/pgsql/data/recovery.conf
$ echo "primary_conninfo = 'host=192.168.202.1 port=5432 user=repl_user application_name=192.168.202.2'" >> /var/lib/pgsql/data/recovery.conf
```

chmod

```
$ chown postgres.postgres -R /var/lib/pgsql
$ chmod 700 -R /var/lib/pgsql
```

## pg2(host) with postgre(user)

start slave db

```
$ pg_ctl start -D /var/lib/pgsql/data/
```

success logging

```
$ bash-4.2$ tail -f /var/lib/pgsql/data/pg_log/postgresql-2017-05-01.log

28351 2017-05-01 08:34:43 EDTLOG:  received smart shutdown request
28354 2017-05-01 08:34:43 EDTLOG:  shutting down
28354 2017-05-01 08:34:43 EDTLOG:  database system is shut down
28386 2017-05-01 08:35:49 EDTLOG:  database system was shut down in recovery at 2017-05-01 08:34:43 EDT
28386 2017-05-01 08:35:49 EDTLOG:  entering standby mode
28386 2017-05-01 08:35:49 EDTLOG:  redo starts at 0/2000020
28386 2017-05-01 08:35:49 EDTLOG:  consistent recovery state reached at 0/3000000
28384 2017-05-01 08:35:49 EDTLOG:  database system is ready to accept read only connections
28390 2017-05-01 08:35:49 EDTLOG:  streaming replication successfully connected to primary
```

※以下はreplictionの確認

## pg1(host) with postgres(user)

```
$ psql
postgres=# create database test;
CREATE DATABASE
postgres=# \q

$ pgbench -i test
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
creating tables...
10000 tuples done.
20000 tuples done.
30000 tuples done.
40000 tuples done.
50000 tuples done.
60000 tuples done.
70000 tuples done.
80000 tuples done.
90000 tuples done.
100000 tuples done.
set primary key...
NOTICE:  ALTER TABLE / ADD PRIMARY KEY will create implicit index "pgbench_branches_pkey" for table "pgbench_branches"
NOTICE:  ALTER TABLE / ADD PRIMARY KEY will create implicit index "pgbench_tellers_pkey" for table "pgbench_tellers"
NOTICE:  ALTER TABLE / ADD PRIMARY KEY will create implicit index "pgbench_accounts_pkey" for table "pgbench_accounts"
vacuum...done.

$ psql test
psql (9.2.18)
"help" でヘルプを表示します.

test=# \d
                リレーションの一覧
 スキーマ |       名前       |    型    |  所有者
----------+------------------+----------+----------
 public   | pgbench_accounts | テーブル | postgres
 public   | pgbench_branches | テーブル | postgres
 public   | pgbench_history  | テーブル | postgres
 public   | pgbench_tellers  | テーブル | postgres
(4 行)

test=# select count(1) from pgbench_accounts;
 count
--------
 100000
(1 行)
```

## pg2(host) with postgres(user)

```
$ psql test
psql (9.2.18)
"help" でヘルプを表示します.

test=# \d
                リレーションの一覧
 スキーマ |       名前       |    型    |  所有者
----------+------------------+----------+----------
 public   | pgbench_accounts | テーブル | postgres
 public   | pgbench_branches | テーブル | postgres
 public   | pgbench_history  | テーブル | postgres
 public   | pgbench_tellers  | テーブル | postgres
(4 行)

test=# select count(1) from pgbench_accounts;
 count
--------
 100000
(1 行)
```