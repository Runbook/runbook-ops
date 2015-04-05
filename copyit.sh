#!/bin/bash

if [ -z $1 ]
then
  echo "`basename $0` environment"
  exit 1
else
  ENVIRONMENT=$1
fi

for x in runbook-ops runbook-secretops
do
  cd /root/$x
  git checkout $ENVIRONMENT
  cp -vR /root/$x/* /
done
