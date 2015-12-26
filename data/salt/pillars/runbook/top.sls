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
    - runbook.runbook
    - runbook.monitors.broker
  '*actionbroker*':
    - runbook.actions.broker
  '*actioner*':
    - runbook.actions.broker
    - runbook.runbook
    - rethinkdb
    - redis
    - mailchimp
    - mandrill
  '*bridge*':
    - runbook.actions.broker
    - runbook.bridge
    - runbook.bridge.mgmt
    - runbook.runbook
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
    - runbook.runbook
  '*all*':
    - rethinkdb
    - redis
    - runbook.runbook
    - runbook.monitors.broker
    - runbook.monitors.control
    - runbook.actions.broker
    - mailchimp
    - mandrill
    - runbook.bridge
    - runbook.bridge.mgmt
    - runbook.web
