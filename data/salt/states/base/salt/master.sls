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
    - template: jinja
    - context:
      saltapi: {{ pillar['saltapi'] }}
{% endfor %}


/etc/cron.d/salt-batchstate:
  file:
    - managed
    - source: salt://salt/config/etc/cron.d/salt-batchstate
    - user: root
    - group: root
    - mode: 644

/etc/cron.d/salt-provisionnew:
  file:
    - managed
    - source: salt://salt/config/etc/cron.d/salt-provisionnew
    - user: root
    - group: root
    - mode: 644
