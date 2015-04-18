/root/scripts/RunbookWraps:
  file.recurse:
    - source: salt://runbook/deploy/root/scripts/RunbookWraps
    - user: root
    - group: root
    - include_empty: True

pyopenssl:
  pip.installed:
    - require:
      - pkg: python-pip

ndg-httpsclient:
  pip.installed:
    - require:
      - pkg: python-pip

pyasnl:
  pip.installed:
    - require:
      - pkg: python-pip

/root/scripts/RunbookWraps/conf:
  file.directory:
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

/root/scripts/RunbookWraps/conf/base.yml:
  file.managed:
    - source: salt://runbook/config/root/scripts/RunbookWraps/conf/base.yml
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - context:
      webhooks: {{ pillar['webhooks'] }}

/etc/cron.d/runwraps-base:
  file.managed:
    - source: salt://runbook/config/etc/cron.d/runwraps-base
    - user: root
    - group: root
    - mode: 640
