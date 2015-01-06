rethinkuser:
  user.present:
    - name: rethinkdb
    - fullname: RethinkDB
    - shell: /bin/bash
    - home: /home/rethinkdb
    - createhome: True
    - uid: 3000
    - gid: 600
