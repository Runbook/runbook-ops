rethink:
  db: "crdb"
  authkey: "RethinkDatabases"
  cluster:
    192.168.36.12: 29015
    192.168.36.13: 29016
  cluster_exposed_ports:
    rethinkdb-redis-dev-dc01-001: 29015
    rethinkdb-redis-dev-dc02-001: 29016
  cluster_local_ports:
    rethinkdb-redis-dev-dc01-001: 29115
    rethinkdb-redis-dev-dc02-001: 29116
