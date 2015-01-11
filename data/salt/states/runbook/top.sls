runbook:
  '*':
    - certs
  'db*':
    - appusers.rethinkdb
    - appgroups.rethinkdb
    - certs.rethink
    - certs.redis
    - redis
    - rethinkdb
