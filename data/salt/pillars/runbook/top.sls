runbook:
  '*':
    - general
    - general.hosts
    - stathat
  '*rethinkdb*':
    - rethinkdb
  '*redis*':
    - redis
  '*control*':
    - runbook.monitors.broker
    - runbook.monitors.control
    - redis
  '*monitorbroker*':
    - runbook.monitors.broker
  '*worker*':
    - runbook.monitors.broker
  '*actionbroker*':
    - runbook.actions.broker
  '*actioner*':
    - runbook.actions.broker
    - rethinkdb
    - redis
    - mailchimp
    - mandrill
  '*bridge*':
    - runbook.actions.broker
    - runbook.bridge
    - runbook.bridge.mgmt
    - rethinkdb
    - redis
    - mailchimp
    - mandrill
  '*web*':
    - redis
    - rethinkdb
    - mailchimp
    - mandrill
    - runbook.web
