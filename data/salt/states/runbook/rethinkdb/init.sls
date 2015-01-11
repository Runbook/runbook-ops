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

{% for instance in pillar['rethink_instances'] %}

/data/rethinkdb/{{ instance }}/data:
  file.directory:
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

/data/rethinkdb/{{ instance }}/config/rethink.conf:
  file.managed:
    - source: salt://rethinkdb/config/rethink.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      rethink_cluster: {{ pillar[instance]['rethink_cluster'] }}
      dbpath: {{ instance }}
      cluster_port: {{ pillar[instance]['rethink_cluster_ports'][grains['nodename']] }}
      local_port: {{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}

/data/rethinkdb/{{ instance }}/config/stunnel-server.conf:
  file.managed:
    - source: salt://rethinkdb/config/stunnel-server.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      exposed_port: {{ pillar[instance]['rethink_cluster_ports'][grains['nodename']] }}
      local_port: {{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}

/data/rethinkdb/{{ instance }}/config/stunnel-client.conf:
  file.managed:
    - source: salt://rethinkdb/config/stunnel-client.tmpl
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      local_port: {{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}
      cluster_port: {{ pillar[instance]['rethink_cluster_ports'][grains['nodename']] }}
      rethink_cluster: {{ pillar[instance]['rethink_cluster'] }}
    
/data/rethinkdb/{{ instance }}/config/supervisord.conf:
  file.managed:
    - source: salt://rethinkdb/config/supervisord.conf
    - user: root
    - group: root
    - mode: 640
    - makedirs: True

/data/rethinkdb/{{ instance }}/Dockerfile:
  file.managed:
    - source: salt://rethinkdb/config/Dockerfile
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
      cluster_port: {{ pillar[instance]['rethink_cluster_ports'][grains['nodename']] }}
      local_port: {{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}
      instance: {{ instance }}


rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}-stop:
  cmd.run:
    - name: /usr/bin/docker rm --force --volumes=false rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}
    - onlyif: /usr/bin/docker ps | /bin/grep -q "rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}"
    - order: 91
    - onchanges:
      - file: /data/rethinkdb/{{ instance }}/Dockerfile
      - file: /data/rethinkdb/{{ instance }}/config/rethink.conf
      - file: /data/rethinkdb/{{ instance }}/config/stunnel-client.conf
      - file: /data/rethinkdb/{{ instance }}/config/stunnel-server.conf
      - file: /data/rethinkdb/{{ instance }}/config/supervisord.conf
      - file: /data/rethinkdb/{{ instance }}/config/ssl

rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}:
  docker.built:
    - path: /data/rethinkdb/{{ instance }}
    - order: 93
    - onchanges:
      - file: /data/rethinkdb/{{ instance }}/Dockerfile
      - file: /data/rethinkdb/{{ instance }}/config/rethink.conf
      - file: /data/rethinkdb/{{ instance }}/config/stunnel-client.conf
      - file: /data/rethinkdb/{{ instance }}/config/stunnel-server.conf
      - file: /data/rethinkdb/{{ instance }}/config/supervisord.conf
      - file: /data/rethinkdb/{{ instance }}/config/ssl

start-rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}:
  cmd.run:
    - name: |
              /usr/bin/docker run -d -p "28015:28015" -p "{{ pillar[instance]['rethink_cluster_ports'][grains['nodename']] }}:{{ pillar[instance]['rethink_cluster_ports'][grains['nodename']] }}" \
              -p "127.0.0.1:8080:8080" -p "127.0.0.1:{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}:{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}" \
              -v "/data/rethinkdb/{{ instance }}/data:/data/rethinkdb/instances/{{ instance }}" \
              --name rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }} \
              rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}
    - unless:  /usr/bin/docker ps | /bin/grep -q "rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}"
    - order: 94
    - require:
      - docker: rethinkdb-{{ instance }}-{{ pillar[instance]['rethink_local_ports'][grains['nodename']] }}

{% endfor %}
