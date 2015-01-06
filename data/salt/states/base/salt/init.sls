salt-minion:
  pkgrepo:
    - managed
    - humanname: SaltStack Repo
    - name: deb http://ppa.launchpad.net/saltstack/salt/ubuntu {{ grains['lsb_distrib_codename'] }} main
    - dist: {{ grains['lsb_distrib_codename'] }}
    - key_url: http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6
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

