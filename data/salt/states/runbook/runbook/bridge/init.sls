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

# Stop and Remove current container
bridge-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force bridge
    - onlyif: /usr/bin/docker ps | /bin/grep -q "bridge"
    - order: 142
    - watch:
      - git: runbook_source
      - file: /data/runbook/bridge/Dockerfile
      - file: /data/runbook/bridge/config/bridge.yml
      - file: /data/runbook/bridge/config/stunnel-client.conf
      - file: /data/runbook/bridge/config/supervisord.conf
      - file: /data/runbook/bridge/config/ssl

# Build image
bridge:
  docker.built:
    - path: /data/runbook/bridge
    - order: 143
    - watch:
      - cmd: bridge-stop
      - file: /data/runbook/bridge/Dockerfile
      - file: /data/runbook/bridge/config/bridge.yml
      - file: /data/runbook/bridge/config/stunnel-client.conf
      - file: /data/runbook/bridge/config/supervisord.conf
      - file: /data/runbook/bridge/config/ssl

# Start container if it is not running
bridge-start:
  cmd.run:
    - name: |
              /usr/bin/docker run -d \
              --name bridge bridge
    - unless: /usr/bin/docker ps | /bin/grep -q "bridge"
    - order: 144
    - require:
      - docker: bridge
