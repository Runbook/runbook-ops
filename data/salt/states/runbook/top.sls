runbook:
  '*':
    - certs
  '*rethinkdb*':
    - appusers.rethinkdb
    - appgroups.rethinkdb
    - certs.rethink
    - rethinkdb
  '*redis*':
    - certs.redis
    - redis
  '*web*':
    - runbook
  '*control*':
    - runbook
    - certs.monitors.control
  '*monitorbroker*':
    - runbook
    - runbook.monitors.broker
    - certs.monitors.broker
  '*worker*':
    - runbook
    - certs.monitors.worker
  '*actioner*':
    - runbook
    - certs.actions.actioner
