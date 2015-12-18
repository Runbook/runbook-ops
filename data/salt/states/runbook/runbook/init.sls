/data/runbook:
  file.directory:
    - user: root
    - group: root
    - mode: 700

runbook_source:
  git.latest:
    - name: https://github.com/Runbook/runbook.git
    - rev: {{ pillar['git_branch'] }}
    - target: /data/runbook/code
    - require:
        - file: /data/runbook
