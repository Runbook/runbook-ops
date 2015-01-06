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
