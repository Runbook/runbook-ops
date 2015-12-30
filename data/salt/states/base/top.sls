base:
  '*':
    - pip
    - swap
    - datadir
    - dockerio
    - git
    - groups
    - iotop
    - iptables
    - manpages
    - nagios-scripts
    - ntpd
    - rdiff-backup
    - salt
    - screen
    - scripts
    - ssh
    - sysdig
    - sysstat
    - telnet
    - timezone
    - unzip
    - users
    - users.devops
    - vimrc
    - wget
  'salt*':
    - salt.master
  'all*':
    - salt.master
