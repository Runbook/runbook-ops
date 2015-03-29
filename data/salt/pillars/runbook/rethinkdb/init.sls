rethink:
  db: "crdb"
  authkey: "RethinkDatabases"
  cluster:
    192.168.36.12: 29015
    192.168.36.13: 29016
    193.168.36.19: 29017
    192.168.36.20: 29018
    192.168.36.21: 29019
  cluster_exposed_ports:
    rethinkdb-redis-dev-dc01-001: 29015
    rethinkdb-redis-dev-dc02-001: 29016
    rethinkdb-dev-dc01-002: 29017
    rethinkdb-dev-dc02-002: 29018
    rethinkdb-dev-dc01-003: 29019
  cluster_local_ports:
    rethinkdb-redis-dev-dc01-001: 29115
    rethinkdb-redis-dev-dc02-001: 29116
    rethinkdb-dev-dc01-002: 29117
    rethinkdb-dev-dc02-002: 29118
    rethinkdb-dev-dc01-003: 29119
