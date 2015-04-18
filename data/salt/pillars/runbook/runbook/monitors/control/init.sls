control:
  intervals:
    30seccheck:
      appname: 30second-control
      queue: 30seccheck
      sleep: 30
    2mincheck:
      appname: 2minute-control
      queue: 2mincheck
      sleep: 120
    5mincheck:
      appname: 5minute-control
      queue: 5mincheck
      sleep: 300
    30mincheck:
      appname: 30minute-control
      queue: 30mincheck
      sleep: 1800
  zones:
    {% if "dev" in grains['nodename'] %}
    dc01: Development Zone 1
    dc02: Development Zone 2 
    {% elif "staging" in grains['nodename'] %}
    dc01: Staging Zone 1
    dc02: Staging Zone 2 
    {% elif "prod" in grains['nodename'] %}
    dc01: DigitalOcean - NYC
    dc02: DigitalOcean - SFO
    {% else %}
    dc01: Development Zone 1
    {% endif %}
