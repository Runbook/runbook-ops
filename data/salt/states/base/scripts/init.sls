/root/scripts:
  file.recurse:
    - source: salt://scripts/config/root/scripts
    - user: root
    - group: root
    - file_mode: 750
    - dir_mode: 750
    - include_empty: True
    - makedirs: True
