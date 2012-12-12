#!/bin/bash

APP=$1
KEY=$2
REGION=us-west-1

function help {
  echo "usage: setup.sh APP_NAME EXISTING_SSH_KEY"
}

if [ "$APP" == "" ]; then
  echo "App name not specified."
  help
  exit 1
fi

if [ "$KEY" == "" ]; then
  echo "Key not specified."
  help
  exit 1
fi

composer -n $APP -r $REGION -k $KEY -a $AWS_ACCESS_KEY_ID -s $AWS_SECRET_ACCESS_KEY
