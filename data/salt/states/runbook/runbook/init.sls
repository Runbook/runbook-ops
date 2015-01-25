/data/runbook:
  file.directory:
    - user: root
    - group: root
    - mode: 700

runbook_source:
  git.latest:
    - name: https://github.com/asm-products/cloudroutes-service.git
    - rev: {{ pillar['git_branch'] }}
    - target: /data/runbook
    - require:
        - file: /data/runbook
