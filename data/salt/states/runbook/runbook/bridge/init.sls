/data/runbook/bridge/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/bridge/config/bridge.yml:
  file.managed:
    - source: salt://runbook/bridge/config/bridge.yml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      action_broker: {{ pillar['action_broker'] }}
      bridge: {{ pillar['bridge'] }}
      redis: {{ pillar['redis'] }}
      rethink: {{ pillar['rethink'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}
      mailchimp: {{ pillar['mailchimp'] }}
      mandrill: {{ pillar['mandrill'] }}
      general:
        datacenter: {{ pillar['datacenter'] }}

/data/runbook/bridge/config/stunnel-client.conf:
  file.managed:
    - source: salt://runbook/bridge/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      action_broker: {{ pillar['action_broker'] }}
      rethink: {{ pillar['rethink'] }}
      redis: {{ pillar['redis'] }}
      hosts: {{ pillar['hosts'] }}


/data/runbook/bridge/Dockerfile:
  file.managed:
    - source: salt://runbook/bridge/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/bridge/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/bridge/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

/data/runbook/bridge/config/mgmtrun.sh:
  file.managed:
    - source: salt://runbook/bridge/config/mgmtrun.sh
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

# Stop and Remove current container
bridge-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force bridge
    - onlyif: /usr/bin/docker ps | /bin/grep -q "bridge"
    - order: 142
    - stateful: False
    - watch:
      - git: runbook_source
      - file: /data/runbook/bridge/Dockerfile
      - file: /data/runbook/bridge/config/bridge.yml
      - file: /data/runbook/bridge/config/stunnel-client.conf
      - file: /data/runbook/bridge/config/supervisord.conf
      - file: /data/runbook/bridge/config/mgmtrun.sh
      - file: /data/runbook/bridge/config/ssl

# Build image
bridge:
  cmd.wait:
    - name: /usr/bin/docker kill bridge; /usr/bin/docker rmi --force bridge; /usr/bin/docker build -t bridge --no-cache=True /data/runbook/bridge
    - order: 143
    - require:
      - pkg: docker.io
      - service: docker.io
    - watch:
      - git: runbook_source
      - cmd: bridge-stop
      - file: /data/runbook/bridge/Dockerfile
      - file: /data/runbook/bridge/config/bridge.yml
      - file: /data/runbook/bridge/config/stunnel-client.conf
      - file: /data/runbook/bridge/config/supervisord.conf
      - file: /data/runbook/bridge/config/mgmtrun.sh
      - file: /data/runbook/bridge/config/ssl

## Build if image isn't present
bridge-build2:
  cmd.run:
    - name: /usr/bin/docker build -t bridge --no-cache=True /data/runbook/bridge
    - unless: /usr/bin/docker images | grep -q "bridge"
    - require:
      - git: runbook_source
      - cmd: bridge-stop
      - file: /data/runbook/bridge/Dockerfile
      - file: /data/runbook/bridge/config/bridge.yml
      - file: /data/runbook/bridge/config/stunnel-client.conf
      - file: /data/runbook/bridge/config/supervisord.conf
      - file: /data/runbook/bridge/config/mgmtrun.sh
      - file: /data/runbook/bridge/config/ssl

/etc/supervisor/conf.d/bridge.conf:
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
        name: bridge
        docker_args: --name bridge bridge

supervisor-bridge:
  service.running:
    - name: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/bridge.conf
