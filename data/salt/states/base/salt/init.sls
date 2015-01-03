salt-minion:
  pkg:
    - latest
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/salt/minion.d/master.conf

/etc/salt/minion.d/master.conf:
  file.managed:
    - source: salt://salt/config/etc/salt/minion.d/master.conf
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - context:
      saltmasters: {{ pillar['saltmasters'] }}

