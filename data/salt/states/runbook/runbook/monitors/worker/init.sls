/data/runbook/monitors/worker/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/monitors/worker/config/worker.yml:
  file.managed:
    - source: salt://runbook/monitors/worker/config/worker.yml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      monitor_broker: {{ pillar['monitor_broker'] }}
      action_broker: {{ pillar['action_broker'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}

/data/runbook/monitors/worker/config/stunnel-client.conf:
  file.managed:
    - source: salt://runbook/monitors/worker/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      monitor_broker: {{ pillar['monitor_broker'] }}
      action_broker: {{ pillar['action_broker'] }}
      hosts: {{ pillar['hosts'] }}


/data/runbook/monitors/worker/Dockerfile:
  file.managed:
    - source: salt://runbook/monitors/worker/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/monitors/worker/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/monitors/worker/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

# Stop and Remove current container
monitorworker-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force monitorworker
    - onlyif: /usr/bin/docker ps | /bin/grep -q "monitorworker"
    - order: 112
    - watch:
      - git: runbook_source
      - file: /data/runbook/monitors/worker/Dockerfile
      - file: /data/runbook/monitors/worker/config/worker.yml
      - file: /data/runbook/monitors/worker/config/stunnel-client.conf
      - file: /data/runbook/monitors/worker/config/supervisord.conf
      - file: /data/runbook/monitors/worker/config/ssl

# Build image
monitorworker:
  cmd.wait:
    - name: /usr/bin/docker kill monitorworker; /usr/bin/docker rmi --force monitorworker; /usr/bin/docker build -t monitorworker --no-cache=True /data/runbook/monitors/worker
    - order: 113
    - require:
      - pkg: docker.io
    - watch:
      - git: runbook_source
      - cmd: monitorworker-stop
      - file: /data/runbook/monitors/worker/Dockerfile
      - file: /data/runbook/monitors/worker/config/worker.yml
      - file: /data/runbook/monitors/worker/config/stunnel-client.conf
      - file: /data/runbook/monitors/worker/config/supervisord.conf
      - file: /data/runbook/monitors/worker/config/ssl

## Build if image isn't present
monitorworker-build2:
  cmd.run:
    - name: /usr/bin/docker build -t monitorworker --no-cache=True /data/runbook/monitors/worker
    - unless: /usr/bin/docker images | grep -q "monitorworker"
    - require:
      - git: runbook_source
      - cmd: monitorworker-stop
      - file: /data/runbook/monitors/worker/Dockerfile
      - file: /data/runbook/monitors/worker/config/worker.yml
      - file: /data/runbook/monitors/worker/config/stunnel-client.conf
      - file: /data/runbook/monitors/worker/config/supervisord.conf
      - file: /data/runbook/monitors/worker/config/ssl

/etc/supervisor/conf.d/monitorworker.conf:
  file.managed:
    - source: salt://supervisor/config/supervisord.tmpl
    - user: root
    - group: root
    - mode: 640
    - require:
      - pkg: supervisor
    - template: jinja
    - context:
      container:
        name: monitorworker
        docker_args: --name monitorworker monitorworker

supervisor-monitorworker:
  service.running:
    - name: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/monitorworker.conf
