/data/runbook/actions/broker/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/actions/broker/config/broker.yml:
  file.managed:
    - source: salt://runbook/actions/broker/config/broker.yml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      local_sink_port: {{ pillar['action_broker']['local_sink_port'] }}
      local_actioner_port: {{ pillar['action_broker']['local_actioner_port'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}

/data/runbook/actions/broker/config/stunnel-server.conf:
  file.managed:
    - source: salt://runbook/actions/broker/config/stunnel-server.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_sink_port: {{ pillar['action_broker']['exposed_sink_port'] }}
      local_sink_port: {{ pillar['action_broker']['exposed_sink_port'] }}
      exposed_actioner_port: {{ pillar['action_broker']['exposed_actioner_port'] }}
      local_actioner_port: {{ pillar['action_broker']['exposed_actioner_port'] }}


/data/runbook/actions/broker/Dockerfile:
  file.managed:
    - source: salt://runbook/actions/broker/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_sink_port: {{ pillar['action_broker']['exposed_sink_port'] }}
      local_sink_port: {{ pillar['action_broker']['exposed_sink_port'] }}
      exposed_actioner_port: {{ pillar['action_broker']['exposed_actioner_port'] }}
      local_actioner_port: {{ pillar['action_broker']['exposed_actioner_port'] }}
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/actions/broker/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/actions/broker/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

# Stop and Remove current container
actionbroker-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force actionbroker
    - onlyif: /usr/bin/docker ps | /bin/grep -q "actionbroker"
    - order: 122
    - watch:
      - git: runbook_source
      - file: /data/runbook/actions/broker/Dockerfile
      - file: /data/runbook/actions/broker/config/broker.yml
      - file: /data/runbook/actions/broker/config/stunnel-server.conf
      - file: /data/runbook/actions/broker/config/supervisord.conf
      - file: /data/runbook/actions/broker/config/ssl

# Build image
actionbroker:
  docker.built:
    - path: /data/runbook/actions/broker
    - order: 123
    - watch:
      - cmd: actionbroker-stop
      - file: /data/runbook/actions/broker/Dockerfile
      - file: /data/runbook/actions/broker/config/broker.yml
      - file: /data/runbook/actions/broker/config/stunnel-server.conf
      - file: /data/runbook/actions/broker/config/supervisord.conf
      - file: /data/runbook/actions/broker/config/ssl

# Start container if it is not running
actionbroker-start:
  cmd.run:
    - name: |
              /usr/bin/docker run -d -p "{{ pillar['action_broker']['exposed_sink_port'] }}:{{ pillar['action_broker']['exposed_sink_port'] }}" \
              -p "{{ pillar['action_broker']['exposed_actioner_port'] }}:{{ pillar['action_broker']['exposed_actioner_port'] }}" \
              --name actionbroker actionbroker
    - unless: /usr/bin/docker ps | /bin/grep -q "actionbroker"
    - order: 124
    - require:
      - docker: actionbroker
