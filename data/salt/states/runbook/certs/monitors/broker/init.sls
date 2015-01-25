/data/runbook/monitors/broker/config/ssl:
  file.recurse:
    - source: salt://certs/config/data/ssl
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
