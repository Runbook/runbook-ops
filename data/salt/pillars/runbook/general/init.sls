{% if "dev" in grains['nodename'] %}
git_branch: develop
{% elif "staging" in grains['nodename'] %}
git_branch: staging
{% elif "prod" in grains['nodename'] %}
git_branch: master
{% endif %}
{% if "dc01" in grains['nodename'] %}
datacenter: dc01
{% elif "dc02" in grains['nodename'] %}
datacenter: dc02
{% elif "dc03" in grains['nodename'] %}
datacenter: dc03
{% elif "dc04" in grains['nodename'] %}
datacenter: dc04
{% elif "dc05" in grains['nodename'] %}
datacenter: dc05
{% endif %}

