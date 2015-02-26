#!/bin/bash
## Management Script Runner for Production Docker instances
# Start Stunnel
# Run provided script

## Start Stunnel
/usr/bin/stunnel4 /config/stunnel-client.conf &
STUNNEL_PID=$(echo $$)

## Wait for Stunnel to Connect
sleep 15

## Start Script
echo "Running: $*"
/usr/bin/python $*

## Clean up Stunnel
echo "Killing Stunnel"
kill $STUNNEL_PID
