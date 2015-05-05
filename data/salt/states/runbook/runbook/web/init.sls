/data/runbook/web/config:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/data/runbook/web/config/nginx:
  file.recurse:
    - source: salt://runbook/web/config/nginx
    - user: root
    - group: root
    - file_mode: 640
    - dir_mode: 750
    - include_empty: True

/data/runbook/web/config/web.cfg:
  file.managed:
    - source: salt://runbook/web/config/web.cfg
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      web: {{ pillar['web'] }}
      redis: {{ pillar['redis'] }}
      rethink: {{ pillar['rethink'] }}
      stathat_env: {{ pillar['stathat_env'] }}
      stathat_ezkey: {{ pillar['stathat_ezkey'] }}
      mailchimp: {{ pillar['mailchimp'] }}
      mandrill: {{ pillar['mandrill'] }}

/data/runbook/web/config/stunnel-client.conf:
  file.managed:
    - source: salt://runbook/web/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      rethink: {{ pillar['rethink'] }}
      redis: {{ pillar['redis'] }}
      hosts: {{ pillar['hosts'] }}


/data/runbook/web/Dockerfile:
  file.managed:
    - source: salt://runbook/web/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      git_branch: {{ pillar['git_branch'] }}

/data/runbook/web/config/supervisord.conf:
  file.managed:
    - source: salt://runbook/web/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

/data/runbook/web/config/uwsgi.cfg:
  file.managed:
    - source: salt://runbook/web/config/uwsgi.cfg
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

/data/runbook/web/config/genstatic.py:
  file.managed:
    - source: salt://runbook/web/config/genstatic.py
    - user: root
    - group: root
    - mode: 640
    - makedirs: True


/data/runbook/web/config/nginx/sites-enabled/cloudrout.es.conf:
  file.managed:
    - source: salt://runbook/web/config/nginx/sites-enabled/httpsonlytemplate.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      domain: cloudrout.es
      webuser: runstatic


/data/runbook/web/config/nginx/sites-enabled/runbook.io.conf:
  file.managed:
    - source: salt://runbook/web/config/nginx/sites-enabled/httpsonlytemplate.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      domain: runbook.io
      webuser: runstatic

/data/runbook/web/config/nginx/sites-enabled/dash.cloudrout.es.conf:
  file.managed:
    - source: salt://runbook/web/config/nginx/sites-enabled/uwsgitemplate.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      domain: dash.cloudrout.es
      webuser: runapp
      static_user: runstatic


/data/runbook/web/config/nginx/sites-enabled/dash.runbook.io.conf:
  file.managed:
    - source: salt://runbook/web/config/nginx/sites-enabled/uwsgitemplate.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      domain: dash.runbook.io
      webuser: runapp
      static_user: runstatic

# Stop and Remove current container
web-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force web
    - onlyif: /usr/bin/docker ps | /bin/grep -q "web"
    - order: 142
    - require:
      - pkg: docker.io
      - service: docker.io
    - watch:
      - git: runbook_source
      - file: /data/runbook/web/Dockerfile
      - file: /data/runbook/web/config/web.cfg
      - file: /data/runbook/web/config/stunnel-client.conf
      - file: /data/runbook/web/config/supervisord.conf
      - file: /data/runbook/web/config/uwsgi.cfg
      - file: /data/runbook/web/config/ssl
      - file: /data/runbook/web/config/nginx/sites-enabled/dash.runbook.io.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/runbook.io.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/dash.cloudrout.es.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/cloudrout.es.conf

# Build image
web:
  cmd.wait:
    - name: /usr/bin/docker kill web; /usr/bin/docker rmi --force web; /usr/bin/docker build -t web --no-cache=True /data/runbook/web
    - order: 143
    - require:
      - pkg: docker.io
      - service: docker.io
    - watch:
      - git: runbook_source
      - cmd: web-stop
      - file: /data/runbook/web/Dockerfile
      - file: /data/runbook/web/config/web.cfg
      - file: /data/runbook/web/config/stunnel-client.conf
      - file: /data/runbook/web/config/supervisord.conf
      - file: /data/runbook/web/config/ssl
      - file: /data/runbook/web/config/nginx/sites-enabled/dash.runbook.io.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/runbook.io.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/dash.cloudrout.es.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/cloudrout.es.conf

## Build if image isn't present
web-build2:
  cmd.run:
    - name: /usr/bin/docker build -t web --no-cache=True /data/runbook/web
    - unless: /usr/bin/docker images | grep -q "web"
    - require:
      - git: runbook_source
      - cmd: web-stop
      - file: /data/runbook/web/Dockerfile
      - file: /data/runbook/web/config/web.cfg
      - file: /data/runbook/web/config/stunnel-client.conf
      - file: /data/runbook/web/config/supervisord.conf
      - file: /data/runbook/web/config/ssl
      - file: /data/runbook/web/config/nginx/sites-enabled/dash.runbook.io.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/runbook.io.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/dash.cloudrout.es.conf
      - file: /data/runbook/web/config/nginx/sites-enabled/cloudrout.es.conf

/etc/supervisor/conf.d/web.conf:
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
        name: web
        docker_args: -p 443:8443 -p 80:8080  --name web web

supervisor-web:
  service.running:
    - name: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/web.conf
