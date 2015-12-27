schedule:
  purge-history:
    function: cmd.run
    minutes: 30
    args:
      - /usr/bin/docker run --rm=True bridge /code/mgmtrun.sh /src/bridge/mgmtscripts/purge_history.py /config/bridge.yml
  purge-events:
    function: cmd.run
    minutes: 30
    args:
      - /usr/bin/docker run --rm=True bridge /code/mgmtrun.sh /src/bridge/mgmtscripts/purge_events.py /config/bridge.yml
  mailchimp_subscribe:
    function: cmd.run
    minutes: 15 
    args:
      - /usr/bin/docker run --rm=True bridge /code/mgmtrun.sh /src/bridge/mgmtscripts/mailchimp_subscribe.py /config/bridge.yml
  get_stats:
    function: cmd.run
    minutes: 60
    args:
      - /usr/bin/docker run --rm=True bridge /code/mgmtrun.sh /src/bridge/mgmtscripts/get_stats.py /config/bridge.yml
  create_db:
    function: cmd.run
    minutes: 60 
    args:
      - /usr/bin/docker run --rm=True bridge /code/mgmtrun.sh /src/bridge/mgmtscripts/create_db.py --travis /config/bridge.yml
