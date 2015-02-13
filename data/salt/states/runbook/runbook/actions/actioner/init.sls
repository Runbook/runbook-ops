/data/runbook/actions/actioner/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/actions/actioner/config/actioner.yml:
  file.managed:
    - source: salt://runbook/actions/actioner/config/actioner.yml
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_actioner_port: {{ pillar['action_broker']['exposed_actioner_port'] }}
      local_actioner_port: {{ pillar['action_broker']['local_actioner_port'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}

/data/runbook/actions/actioner/config/stunnel-client.conf:
  file.managed:
    - source: salt://runbook/actions/actioner/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_actioner_port: {{ pillar['action_broker']['exposed_actioner_port'] }}
      local_actioner_port: {{ pillar['action_broker']['local_actioner_port'] }}
      rethink: {{ pillar['rethink'] }}


/data/runbook/actions/actioner/Dockerfile:
  file.managed:
    - source: salt://runbook/actions/actioner/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/actions/actioner/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/actions/actioner/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

# Stop and Remove current container
actioner-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force actioner
    - onlyif: /usr/bin/docker ps | /bin/grep -q "actioner"
    - order: 132
    - watch:
      - git: runbook_source
      - file: /data/runbook/actions/actioner/Dockerfile
      - file: /data/runbook/actions/actioner/config/actioner.yml
      - file: /data/runbook/actions/actioner/config/stunnel-client.conf
      - file: /data/runbook/actions/actioner/config/supervisord.conf
      - file: /data/runbook/actions/actioner/config/ssl

# Build image
actioner:
  docker.built:
    - path: /data/runbook/actions/actioner
    - order: 133
    - watch:
      - cmd: actioner-stop
      - file: /data/runbook/actions/actioner/Dockerfile
      - file: /data/runbook/actions/actioner/config/actioner.yml
      - file: /data/runbook/actions/actioner/config/stunnel-client.conf
      - file: /data/runbook/actions/actioner/config/supervisord.conf
      - file: /data/runbook/actions/actioner/config/ssl

# Start container if it is not running
actioner-start:
  cmd.run:
    - name: |
              /usr/bin/docker run -d --name actioner actioner
    - unless: /usr/bin/docker ps | /bin/grep -q "actioner"
    - order: 124
    - require:
      - docker: actioner
