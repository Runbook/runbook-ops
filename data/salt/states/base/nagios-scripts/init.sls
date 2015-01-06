nagios-plugins-basic:
  pkg:
    - installed

/usr/lib/nagios/plugins/check_logfiles:
  file.managed:
    - source: salt://nagios-scripts/deploy/usr/lib/nagios/plugins/check_logfiles
    - mode: 755
    - user: root
    - group: root
    - makedirs: True
