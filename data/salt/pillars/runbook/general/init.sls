{% if "dev" in grains['nodename'] %}
git_branch: develop
{% elif "staging" in grains['nodename'] %}
git_branch: staging
{% elif "prod" in grains['nodename'] %}
git_branch: production
{% endif %}
