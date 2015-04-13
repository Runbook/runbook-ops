#!/bin/bash

if [ -z $1 ]
then
  echo "`basename $0` environment"
  exit 1
else
  ENVIRONMENT=$1
  SKIPPULL=0
  if [ $2 == "--skippull" ]
  then
    SKIPPULL=1
  fi
fi

cd /root/runbook-ops
if [ $? -ne 0 ]
then
  echo "Error: Changing directory to runbook-ops"
  exit 1
fi

git checkout $ENVIRONMENT && git pull && cp -vR /root/runbook-ops/* /
if [ $? -ne 0 ]
then
  echo "Error: Pulling latest data"
  exit 1
fi

cd /root/runbook-secretops
if [ $? -ne 0 ]
then
  echo "Error: Changing directory to runbook-ops"
  exit 1
fi

if [ $SKIPPULL -eq 0 ]
then
  git checkout $ENVIRONMENT && git pull && cp -vR /root/runbook-secretops/* /
else
  git checkout $ENVIRONMENT && cp -vR /root/runbook-secretops/* /
fi
if [ $? -ne 0 ]
then
  echo "Error: Pulling latest data"
  exit 1
fi 

