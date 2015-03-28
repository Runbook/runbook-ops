rethinkdb:
  pkgrepo:
    - managed
    - humanname: RethinkDB Repo
    - name: deb http://download.rethinkdb.com/apt {{ grains['lsb_distrib_codename'] }} main
    - dist: {{ grains['lsb_distrib_codename'] }}
    - key_url: http://download.rethinkdb.com/apt/pubkey.gpg
  pkg:
    - installed
    - require:
        - user: rethinkdb
        - group: rethinkdb
  service:
    - dead
    - enable: False

/data/rethinkdb/data/instances/{{ pillar['rethink']['db'] }}:
  file.directory:
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

/data/rethinkdb/config/rethink.conf:
  file.managed:
    - source: salt://rethinkdb/config/rethink.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      rethink_cluster: {{ pillar['rethink']['cluster'] }}
      dbpath: {{ pillar['rethink']['db'] }}
      cluster_exposed_port: {{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}
      cluster_local_port: {{ pillar['rethink']['cluster_local_ports'][grains['nodename']] }}
      server_name: {{ grains['nodename'] }}-{{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}

/data/rethinkdb/config/stunnel-server.conf:
  file.managed:
    - source: salt://rethinkdb/config/stunnel-server.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      cluster_exposed_port: {{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}
      cluster_local_port: {{ pillar['rethink']['cluster_local_ports'][grains['nodename']] }}

/data/rethinkdb/config/stunnel-client.conf:
  file.managed:
    - source: salt://rethinkdb/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      cluster_local_port: {{ pillar['rethink']['cluster_local_ports'][grains['nodename']] }}
      cluster_exposed_port: {{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}
      rethink_cluster: {{ pillar['rethink']['cluster'] }}
    
/data/rethinkdb/config/supervisord.conf:
  file.managed:
    - source: salt://rethinkdb/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

/data/rethinkdb/Dockerfile:
  file.managed:
    - source: salt://rethinkdb/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      cluster_exposed_port: {{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}
      cluster_local_port: {{ pillar['rethink']['cluster_local_ports'][grains['nodename']] }}
      instance: {{ pillar['rethink']['db'] }}


rethinkdb-stop:
  cmd.wait:
    - name: /usr/bin/docker rm --force --volumes=false rethinkdb
    - onlyif: /usr/bin/docker ps | /bin/grep -q "rethinkdb"
    - order: 91
    - watch:
      - file: /data/rethinkdb/Dockerfile
      - file: /data/rethinkdb/config/rethink.conf
      - file: /data/rethinkdb/config/stunnel-client.conf
      - file: /data/rethinkdb/config/stunnel-server.conf
      - file: /data/rethinkdb/config/supervisord.conf
      - file: /data/rethinkdb/config/ssl

rethinkdb-build:
  cmd.wait:
    - name: /usr/bin/docker build -t rethinkdb /data/rethinkdb
    - order: 93
    - watch:
      - file: /data/rethinkdb/Dockerfile
      - file: /data/rethinkdb/config/rethink.conf
      - file: /data/rethinkdb/config/stunnel-client.conf
      - file: /data/rethinkdb/config/stunnel-server.conf
      - file: /data/rethinkdb/config/supervisord.conf
      - file: /data/rethinkdb/config/ssl

start-rethinkdb:
  cmd.run:
    - name: |
              /usr/bin/docker run -d -p "28015:28015" \
              -p "{{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}:{{ pillar['rethink']['cluster_exposed_ports'][grains['nodename']] }}" \
              -p "127.0.0.1:8080:8080" \
              -p "127.0.0.1:{{ pillar['rethink']['cluster_local_ports'][grains['nodename']] }}:{{ pillar['rethink']['cluster_local_ports'][grains['nodename']] }}" \
              -v "/data/rethinkdb/data:/data/rethinkdb/data" \
              --name rethinkdb \
              rethinkdb
    - unless:  /usr/bin/docker ps | /bin/grep -q "rethinkdb"
    - order: 94
