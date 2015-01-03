/etc/apt/trusted.gpg.d/draios.gpg:
  file.managed:
    - source: salt://sysdig/config/etc/apt/trusted.gpg.d/draios.gpg
    - user: root
    - group: root
    - mode: 644

/etc/apt/sources.list.d/draios.list:
  file.managed:
    - source: salt://sysdig/config/etc/apt/sources.list.d/draios.list
    - user: root
    - group: root
    - mode: 644

linux-headers-{{ grains['kernelrelease'] }}:
  pkg:
    - installed

sysdig:
  pkg:
    - installed
    - require:
      - file: /etc/apt/trusted.gpg.d/draios.gpg
      - file: /etc/apt/sources.list.d/draios.list
      - pkg: linux-headers-{{ grains['kernelrelease'] }}
