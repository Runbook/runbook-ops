salt-master:
  pkg:
    - latest
  service:
    - running
    - enable: True

salt-api:
  pkg:
    - latest
  service:
    - running
    - enable: True

{% set configs = ['logging.conf', 'file_ignore_regex.conf', 'file_roots.conf', 'pillar_roots.conf', 'salt-api.conf', 'reactor.conf'] %}
{% for file in configs %}
/etc/salt/master.d/{{ file }}:
  file.managed:
    - source: salt://salt/config/etc/salt/master.d/{{ file }}
    - user: root
    - group: root
    - mode: 644
{% endfor %}


/etc/cron.d/salt-batchstate:
  file:
    - managed
    - source: salt://salt/config/etc/cron.d/salt-batchstate
    - user: root
    - group: root
    - mode: 644
