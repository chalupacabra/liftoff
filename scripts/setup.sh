#!/bin/bash

APP=$1
KEY=$2
SECRET=$3
REGION=us-west-1

function help {
  echo "usage: setup.sh APP_NAME EXISTING_SSH_KEY_NAME ENCRYPTION_SECRET"
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

if [ "$SECRET" == "" ]; then
  echo "SECRET not specified."
  help
  exit 1
fi

composer -n $APP -r $REGION -k $KEY --aws-access-key $AWS_ACCESS_KEY_ID --aws-secret-key $AWS_SECRET_ACCESS_KEY -s $SECRET
