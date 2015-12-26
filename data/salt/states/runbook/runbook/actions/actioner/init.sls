/data/runbook/actions/actioner/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/actions/actioner/data:
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
      action_broker: {{ pillar['action_broker'] }}
      redis: {{ pillar['redis'] }}
      rethink: {{ pillar['rethink'] }}
      runbook: {{ pillar['runbook'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}
      mailchimp: {{ pillar['mailchimp'] }}
      mandrill: {{ pillar['mandrill'] }}

/data/runbook/actions/actioner/config/stunnel-client.conf:
  file.managed:
    - source: salt://runbook/actions/actioner/config/stunnel-client.tmpl
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
    - order: 142
    - watch:
      - git: runbook_source
      - file: /data/runbook/actions/actioner/Dockerfile
      - file: /data/runbook/actions/actioner/config/actioner.yml
      - file: /data/runbook/actions/actioner/config/stunnel-client.conf
      - file: /data/runbook/actions/actioner/config/supervisord.conf
      - file: /data/runbook/actions/actioner/config/ssl

# Build image
actioner:
  cmd.wait:
    - name: /usr/bin/docker kill actioner; /usr/bin/docker rmi --force actioner; /usr/bin/docker build -t actioner --no-cache=True /data/runbook/actions/actioner
    - order: 143
    - require:
      - pkg: docker.io
    - watch:
      - git: runbook_source
      - cmd: actioner-stop
      - file: /data/runbook/actions/actioner/Dockerfile
      - file: /data/runbook/actions/actioner/config/actioner.yml
      - file: /data/runbook/actions/actioner/config/stunnel-client.conf
      - file: /data/runbook/actions/actioner/config/supervisord.conf
      - file: /data/runbook/actions/actioner/config/ssl

## Build if image isn't present
actioner-build2:
  cmd.run:
    - name: /usr/bin/docker build -t actioner --no-cache=True /data/runbook/actions/actioner
    - unless: /usr/bin/docker images | grep -q "actioner"
    - require:
      - git: runbook_source
      - file: /data/runbook/actions/actioner/Dockerfile
      - file: /data/runbook/actions/actioner/config/actioner.yml
      - file: /data/runbook/actions/actioner/config/stunnel-client.conf
      - file: /data/runbook/actions/actioner/config/supervisord.conf
      - file: /data/runbook/actions/actioner/config/ssl

/etc/supervisor/conf.d/actioner.conf:
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
        name: actioner
        docker_args: --name actioner actioner

supervisor-actioner:
  service.running:
    - name: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/actioner.conf
