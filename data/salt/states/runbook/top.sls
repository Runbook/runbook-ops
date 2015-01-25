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
  'web*':
    - runbook
  'control*':
    - runbook
    - runbook.monitors.broker
    - certs.monitors.broker
    - certs.monitors.control
  'worker*':
    - runbook
    - certs.monitors.worker
    - certs.actions.actioner
