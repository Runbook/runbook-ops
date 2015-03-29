testuser:
  user.present:
    - fullname: Sample User
    - shell: /bin/bash
    - home: /home/testuser
    - createhome: True
    - uid: 4001
    - gid: 100
    - password: SAMPLEONLYTHISSHOULDBEASALTENCRYPTEDVALUE
    - enforce_password: True
    - groups:
      - adm
      - devops
      - users

/home/testuser/.vimrc:
  file.managed:
    - source: salt://users/config/.vimrc
    - user: testuser
    - group: devops
    - mode: 644
