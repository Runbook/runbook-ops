/data/runbook/monitors/control/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

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
      control: {{ pillar['control'] }}


{% for queue,appdetails in pillar['control']['intervals'].iteritems() %}

/data/runbook/monitors/control/config/{{ appdetails['appname'] }}.yml:
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
      interval: {{ queue }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}

/data/runbook/monitors/control/config/supervisord-{{ appdetails['appname'] }}.conf:
  file.managed:
    - source: salt://runbook/monitors/control/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      appdetails: {{ appdetails }}

# Stop and Remove current container
{{ appdetails['appname'] }}-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force {{ appdetails['appname'] }}
    - onlyif: /usr/bin/docker ps | /bin/grep -q "{{ appdetails['appname'] }}"
    - order: 142
    - stateful: False
    - watch:
      - git: runbook_source
      - file: /data/runbook/monitors/control/Dockerfile
      - file: /data/runbook/monitors/control/config/{{ appdetails['appname'] }}.yml
      - file: /data/runbook/monitors/control/config/supervisord-{{ appdetails['appname'] }}.conf
      - file: /data/runbook/monitors/control/config/stunnel-client.conf
      - file: /data/runbook/monitors/control/config/ssl

/etc/supervisor/conf.d/{{ appdetails['appname'] }}.conf:
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
        name: {{ appdetails['appname'] }}
        docker_args: --name {{ appdetails['appname'] }} control /usr/bin/supervisord -c /config/supervisord-{{ appdetails['appname'] }}.conf


{% endfor %}

# Build image
control:
  cmd.wait:
    - name: /usr/bin/docker kill control; /usr/bin/docker rmi --force control; /usr/bin/docker build -t control --no-cache=True /data/runbook/monitors/control
    - order: 143
    - require:
      - pkg: docker.io
    - watch:
      - git: runbook_source
{% for queue,appdetails in pillar['control']['intervals'].iteritems() %}
      - file: /data/runbook/monitors/control/config/{{ appdetails['appname'] }}.yml
      - file: /data/runbook/monitors/control/config/supervisord-{{ appdetails['appname'] }}.conf
{% endfor %}
      - file: /data/runbook/monitors/control/Dockerfile
      - file: /data/runbook/monitors/control/config/stunnel-client.conf
      - file: /data/runbook/monitors/control/config/ssl


## Build if image isn't present
control-build2:
  cmd.run:
    - name: /usr/bin/docker build -t control --no-cache=True /data/runbook/monitors/control
    - unless: /usr/bin/docker images | grep -q "control"
    - require:
      - git: runbook_source
{% for queue,appdetails in pillar['control']['intervals'].iteritems() %}
      - file: /data/runbook/monitors/control/config/{{ appdetails['appname'] }}.yml
      - file: /data/runbook/monitors/control/config/supervisord-{{ appdetails['appname'] }}.conf
{% endfor %}
      - file: /data/runbook/monitors/control/Dockerfile
      - file: /data/runbook/monitors/control/config/stunnel-client.conf
      - file: /data/runbook/monitors/control/config/ssl
      

supervisor-control:
  service.running:
    - name: supervisor
    - watch:
{% for queue,appdetails in pillar['control']['intervals'].iteritems() %}
      - file: /etc/supervisor/conf.d/{{ appdetails['appname'] }}.conf
{% endfor %}
