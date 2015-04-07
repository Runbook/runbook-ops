supervisor:
  pkg:
    - installed
  service:
    - running
    - enable: True

/etc/cron.d/docker-kill:
  file.managed:
    - source: salt://supervisor/config/etc/cron.d/docker-kill
    - user: root
    - group: root
    - mode: 644
