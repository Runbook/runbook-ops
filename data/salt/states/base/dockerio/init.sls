docker.io:
  pkgrepo:
    - managed
    - humanname: Docker Repo
    - name: deb https://get.docker.com/ubuntu docker main
    - keyserver: keyserver.ubuntu.com
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
  pkg:
    - installed

docker:
  service:
    - running
    - enable: True

docker-py:
  pip.installed:
    - name: docker-py < 0.5
    - require:
      - pkg: python-pip

