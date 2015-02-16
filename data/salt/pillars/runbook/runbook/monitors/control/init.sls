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
    dc01: Development Zone 1
    dc02: Development Zone 2 
