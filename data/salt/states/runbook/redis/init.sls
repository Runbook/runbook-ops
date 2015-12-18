/data/redis/data:
  file.directory:
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

/data/redis/config/redis.conf:
  file.managed:
    - source: salt://redis/config/redis.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      port: {{ pillar['redis']['local_port'] }}
      redis_pass: {{ pillar['redis']['pass'] }}

/data/redis/config/stunnel-server.conf:
  file.managed:
    - source: salt://redis/config/stunnel-server.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_port: {{ pillar['redis']['exposed_port'] }}
      local_port: {{ pillar['redis']['local_port'] }}

/data/redis/config/supervisord.conf:
  file.managed:
    - source: salt://redis/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

/data/redis/Dockerfile:
  file.managed:
    - source: salt://redis/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_port: {{ pillar['redis']['exposed_port'] }}
      local_port: {{ pillar['redis']['local_port'] }}

# Stop and Remove current redis container
redis-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force --volumes=false redis
    - onlyif: /usr/bin/docker ps | /bin/grep -q "redis"
    - order: 102
    - watch:
      - file: /data/redis/Dockerfile
      - file: /data/redis/config/redis.conf
      - file: /data/redis/config/stunnel-server.conf
      - file: /data/redis/config/supervisord.conf
      - file: /data/redis/config/ssl

# Build redis image
redis-build:
  cmd.wait:
    - name: /usr/bin/docker build -t runbook-redis /data/redis
    - order: 103
    - require:
      - pkg: docker.io
    - watch:
      - file: /data/redis/Dockerfile
      - file: /data/redis/config/redis.conf
      - file: /data/redis/config/stunnel-server.conf
      - file: /data/redis/config/supervisord.conf
      - file: /data/redis/config/ssl

## Build if image isn't present
redis-build2:
  cmd.run:
    - name: /usr/bin/docker build -t runbook-redis /data/redis
    - unless: /usr/bin/docker images | grep -q "runbook-redis"
    - require:
      - file: /data/redis/Dockerfile
      - file: /data/redis/config/redis.conf
      - file: /data/redis/config/stunnel-server.conf
      - file: /data/redis/config/supervisord.conf
      - file: /data/redis/config/ssl

/etc/supervisor/conf.d/redis.conf:
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
        name: redis
        docker_args: -p "{{ pillar['redis']['exposed_port'] }}:{{ pillar['redis']['exposed_port'] }}" -v "/data/redis:/data/redis" --name "redis" runbook-redis

supervisor-redis:
  service.running:
    - name: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/redis.conf
