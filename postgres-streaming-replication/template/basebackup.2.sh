#/bin/sh -x
#
PORT=5432
master_node_host_name={{hostvars[inventory_hostname].slave}}
recovery_node_host_name={{hostvars[inventory_hostname].master}}
tmp=/tmp/mytemp$$
trap "rm -f $tmp" 0 1 2 3 15

psql -p $PORT -c "SELECT pg_start_backup('Streaming Replication', true)" postgres

rsync -C -a -c --delete --exclude postgresql.conf --exclude postmaster.pid \
--exclude postmaster.opts --exclude pg_log \
--exclude recovery.conf --exclude recovery.done \
--exclude pg_xlog \
/var/lib/pgsql/data/ $recovery_node_host_name:/var/lib/pgsql/data/

ssh -T $recovery_node_host_name mkdir /var/lib/pgsql/data/pg_xlog
ssh -T $recovery_node_host_name chmod 700 /var/lib/pgsql/data/pg_xlog
ssh -T $recovery_node_host_name rm -f /var/lib/pgsql/data/recovery.done

cat > $tmp <<EOF
standby_mode          = 'on'
primary_conninfo      = 'host=$master_node_host_name port=$PORT user=repl_user'
trigger_file = '/var/log/pgpool/trigger/trigger_file1'
EOF

scp $tmp $recovery_node_host_name:/var/lib/pgsql/data/recovery.conf

psql -p $PORT -c "SELECT pg_stop_backup()" postgres
