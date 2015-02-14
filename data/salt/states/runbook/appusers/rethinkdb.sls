rethinkuser:
  user.present:
    - name: rethinkdb
    - fullname: RethinkDB
    - shell: /usr/sbin/nologin
    - home: /home/rethinkdb
    - createhome: True
    - uid: 3000
    - gid: 600
