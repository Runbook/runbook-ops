ssh:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/ssh/sshd_config

/etc/ssh/sshd_config:
  file.replace:
    - pattern: |
        Port 22
    - repl: |
        Port {{ pillar['ssh_port'] }}

