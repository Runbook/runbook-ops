/root/scripts/RunbookWraps:
  file.recurse:
    - source: salt://webhooks/deploy/root/scripts/RunbookWraps
    - user: root
    - group: root
    - include_empty: True

/root/scripts/RunbookWraps/conf:
  file.directory:
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

/root/scripts/RunbookWraps/conf/base.yml:
  file.managed:
    - source: salt://webhooks/config/root/scripts/RunbookWraps/conf/base.yml
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - context:
      webhooks: {{ pillar['webhooks'] }}

/etc/cron.d/runwraps-base:
  file.managed:
    - source: salt://webhooks/config/etc/cron.d/runwraps-base
    - user: root
    - group: root
    - mode: 640
