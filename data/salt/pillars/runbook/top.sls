runbook:
  '*':
    - general
    - stathat
  '*db*':
    - rethinkdb
    - rethinkdb.cluster
  '*redis*':
    - redis
  '*control*':
    - runbook.monitors.broker
  '*worker*':
    - runbook.monitors.broker
