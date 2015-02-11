runbook:
  '*':
    - general
    - stathat
  '*rethinkdb*':
    - rethinkdb
    - rethinkdb.cluster
  '*redis*':
    - redis
  '*control*':
    - runbook.monitors.broker
  '*monitorbroker*':
    - runbook.monitors.broker
  '*worker*':
    - runbook.monitors.broker
  '*actionbroker*':
    - runbook.actions.broker
  '*actioner*':
    - runbook.actions.broker
