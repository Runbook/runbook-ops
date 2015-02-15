/data/runbook/monitors/control/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/monitors/control/config/control.yml:
  file.managed:
    - source: salt://runbook/monitors/control/config/control.yml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      monitor_broker: {{ pillar['monitor_broker'] }}
      redis: {{ pillar['redis'] }}
      control: {{ pillar['control'] }}
      general:
        datacenter: {{ pillar['datacenter'] }}
      interval: 30seccheck
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}

/data/runbook/monitors/control/config/stunnel-client.conf:
  file.managed:
    - source: salt://runbook/monitors/control/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      monitor_broker: {{ pillar['monitor_broker'] }}
      redis: {{ pillar['redis'] }}
      hosts: {{ pillar['hosts'] }}

/data/runbook/monitors/control/Dockerfile:
  file.managed:
    - source: salt://runbook/monitors/control/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/monitors/control/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/monitors/control/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

# Stop and Remove current container
control-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force control
    - onlyif: /usr/bin/docker ps | /bin/grep -q "control"
    - order: 142
    - watch:
      - git: runbook_source
      - file: /data/runbook/monitors/control/Dockerfile
      - file: /data/runbook/monitors/control/config/control.yml
      - file: /data/runbook/monitors/control/config/stunnel-client.conf
      - file: /data/runbook/monitors/control/config/supervisord.conf
      - file: /data/runbook/monitors/control/config/ssl

# Build image
control:
  docker.built:
    - path: /data/runbook/monitors/control
    - order: 143
    - watch:
      - cmd: control-stop
      - file: /data/runbook/monitors/control/Dockerfile
      - file: /data/runbook/monitors/control/config/control.yml
      - file: /data/runbook/monitors/control/config/stunnel-client.conf
      - file: /data/runbook/monitors/control/config/supervisord.conf
      - file: /data/runbook/monitors/control/config/ssl

# Start container if it is not running
control-start:
  cmd.run:
    - name: |
              /usr/bin/docker run -d \
              --name control control
    - unless: /usr/bin/docker ps | /bin/grep -q "control"
    - order: 144
    - require:
      - docker: control
