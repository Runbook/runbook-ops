## Groups should be the same on all servers
## easier to avoid conflicts

rethinkdb-group:
  group.present:
    - name: rethinkdb
    - gid: 600

devops:
  group.present:
    - gid: 700
    - order: 3

/etc/sudoers.d/devops:
  file.managed:
    - source: salt://groups/config/etc/sudoers.d/devops.conf
    - user: root
    - group: root
    - mode: 440 
