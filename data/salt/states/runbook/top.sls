runbook:
  '*':
    - certs
    - supervisor
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
    - runbook.web
    - certs.web
  '*bridge*':
    - runbook
    - runbook.bridge
    - certs.bridge
  '*control*':
    - runbook
    - runbook.monitors.control
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
    - runbook.actions.actioner
    - certs.actions.actioner
  '*actionbroker*':
    - runbook
    - runbook.actions.broker
    - certs.actions.broker
  '*all*':
    - runbook
    - appusers.rethinkdb
    - appgroups.rethinkdb
    - certs.rethink
    - rethinkdb
    - certs.redis
    - redis
    - runbook.web
    - certs.web
    - runbook.bridge
    - certs.bridge
    - runbook.monitors.control
    - certs.monitors.control
    - runbook.monitors.broker
    - certs.monitors.broker
    - certs.monitors.worker
    - runbook.actions.actioner
    - certs.actions.actioner
    - runbook.actions.broker
    - certs.actions.broker
