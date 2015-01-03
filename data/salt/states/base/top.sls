base:
  '*':
    - datadir
    - dockerio
    - git
    - iotop
    - iptables
    - manpages
    - nagios-scripts
    - ntpd
    - salt
    - screen
    - scripts
    - sysdig
    - sysstat
    - telnet
    - top.sls
    - unzip
    - vimrc
    - wget
  'salt*':
    - salt.master
