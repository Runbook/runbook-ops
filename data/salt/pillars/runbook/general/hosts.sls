hosts:
{% if "dev" in grains['nodename'] %}
  {% if "dc01" in grains['nodename'] %}
  redis: 192.168.36.12 
  monitor_broker:
    - 192.168.36.15
  {% endif %} 
  {% if "dc02" in grains['nodename'] %}
  redis: 192.168.36.13 
  monitor_broker:
    - 192.168.36.16
  {% endif %} 
  actionbroker:
    - 192.168.36.15
    - 192.168.36.16
{% endif %}
