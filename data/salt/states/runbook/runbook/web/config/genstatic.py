#!/usr/bin/python
# Generate static html files from uwsgi service
# Benjamin Cane - 2014/11/02

import requests as r
import os
import sys


headers = { 'host' : 'dash.runbook.io' }
url = 'https://localhost:8443'
endpoints = [
    '/',
    '/pages/tos',
    '/pages/monitors',
    '/pages/pricing',
    '/pages/reactions',
    '/pages/faq'
]
output = "/data/runstatic/public_html"
replacements = {
    'href="/login"' : 'href="https://dash.runbook.io/login"',
    'href="/signup"' : 'href="https://dash.runbook.io/signup"',
}

for uri in endpoints:
    req = r.get(url = url + uri, headers=headers, verify=False)
    print("Got status code %d while fetching %s") % (req.status_code, uri)
    if req.status_code == 200:
        path = output + uri
        if not os.path.isdir(path):
            os.makedirs(path)
        print("Writing to %s") % path + "/index.html"
        fh = open(path + "/index.html", "w")
        text = req.text
        for replace in replacements.keys():
          text = text.replace(replace, replacements[replace])
        fh.write(text)
        fh.close()
    else:
      print("Skipping %s") % uri
      sys.exit(1)
