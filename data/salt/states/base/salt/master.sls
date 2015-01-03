salt-master:
  pkg:
    - latest
  service:
    - running
    - enable: True

salt-api:
  service:
    - running
    - enable: True

/etc/salt/master.d/nodegroups.conf:
  file.managed:
    - source: salt://saltconfig/config/etc/salt/master.d/nodegroups.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      nodegroups: {{ pillar['allnodegroups'] }}

{% set configs = ['logging.conf', 'file_ignore_regex.conf', 'file_roots.conf', 'pillar_roots.conf', 'salt-api.conf', 'reactor.conf'] %}
{% for file in configs %}
/etc/salt/master.d/{{ file }}:
  file.managed:
    - source: salt://saltconfig/config/etc/salt/master.d/{{ file }}
    - user: root
    - group: root
    - mode: 644
{% endfor %}


/etc/cron.d/salt-batchstate:
  file:
    - managed
    - source: salt://saltconfig/config/etc/cron.d/salt-batchstate
    - user: root
    - group: root
    - mode: 644
