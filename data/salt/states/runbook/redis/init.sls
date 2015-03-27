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
    - name: /usr/bin/docker rm --force --volumes=false redis-{{ pillar['redis']['local_port'] }}
    - onlyif: /usr/bin/docker ps | /bin/grep -q "redis-{{ pillar['redis']['local_port'] }}"
    - order: 102
    - watch:
      - file: /data/redis/Dockerfile
      - file: /data/redis/config/redis.conf
      - file: /data/redis/config/stunnel-server.conf
      - file: /data/redis/config/supervisord.conf
      - file: /data/redis/config/ssl

# Build redis image
redis-build:
  docker.built:
    - name: redis
    - path: /data/redis
    - order: 103
    - watch:
      - file: /data/redis/Dockerfile
      - file: /data/redis/config/redis.conf
      - file: /data/redis/config/stunnel-server.conf
      - file: /data/redis/config/supervisord.conf
      - file: /data/redis/config/ssl

# Start redis container if it is not running
redis-start:
  cmd.run:
    - name: |
              /usr/bin/docker run -d -p "{{ pillar['redis']['exposed_port'] }}:{{ pillar['redis']['exposed_port'] }}" \
              -v "/data/redis:/data/redis" --name "redis" \
              redis
    - unless: /usr/bin/docker ps | /bin/grep redis
    - order: 104
    - require:
      - docker: redis-build
