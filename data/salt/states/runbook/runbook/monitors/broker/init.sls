/data/runbook/monitors/broker/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/monitors/broker/config/broker.yml:
  file.managed:
    - source: salt://runbook/monitors/broker/config/broker.yml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      local_control_port: {{ pillar['monitor_broker']['local_control_port'] }}
      local_worker_port: {{ pillar['monitor_broker']['local_worker_port'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}

/data/runbook/monitors/broker/config/stunnel-server.conf:
  file.managed:
    - source: salt://runbook/monitors/broker/config/stunnel-server.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_control_port: {{ pillar['monitor_broker']['exposed_control_port'] }}
      local_control_port: {{ pillar['monitor_broker']['exposed_control_port'] }}
      exposed_worker_port: {{ pillar['monitor_broker']['exposed_worker_port'] }}
      local_worker_port: {{ pillar['monitor_broker']['exposed_worker_port'] }}


/data/runbook/monitors/broker/Dockerfile:
  file.managed:
    - source: salt://runbook/monitors/broker/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_control_port: {{ pillar['monitor_broker']['exposed_control_port'] }}
      local_control_port: {{ pillar['monitor_broker']['exposed_control_port'] }}
      exposed_worker_port: {{ pillar['monitor_broker']['exposed_worker_port'] }}
      local_worker_port: {{ pillar['monitor_broker']['exposed_worker_port'] }}
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/monitors/broker/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/monitors/broker/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

# Stop and Remove current container
monitorbroker-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force monitorbroker
    - onlyif: /usr/bin/docker ps | /bin/grep -q "monitorbroker"
    - order: 112
    - watch:
      - git: runbook_source
      - file: /data/runbook/monitors/broker/Dockerfile
      - file: /data/runbook/monitors/broker/config/broker.yml
      - file: /data/runbook/monitors/broker/config/stunnel-server.conf
      - file: /data/runbook/monitors/broker/config/supervisord.conf
      - file: /data/runbook/monitors/broker/config/ssl

# Build image
monitorbroker:
  docker.built:
    - path: /data/runbook/monitors/broker
    - order: 113
    - watch:
      - cmd: monitorbroker-stop
      - file: /data/runbook/monitors/broker/Dockerfile
      - file: /data/runbook/monitors/broker/config/broker.yml
      - file: /data/runbook/monitors/broker/config/stunnel-server.conf
      - file: /data/runbook/monitors/broker/config/supervisord.conf
      - file: /data/runbook/monitors/broker/config/ssl

# Start container if it is not running
monitorbroker-start:
  cmd.run:
    - name: |
              /usr/bin/docker run -d -p "{{ pillar['monitor_broker']['exposed_control_port'] }}:{{ pillar['monitor_broker']['exposed_control_port'] }}" \
              -p "{{ pillar['monitor_broker']['exposed_worker_port'] }}:{{ pillar['monitor_broker']['exposed_worker_port'] }}" \
              --name monitorbroker monitorbroker
    - unless: /usr/bin/docker ps | /bin/grep -q "monitorbroker"
    - order: 114
    - require:
      - docker: monitorbroker
