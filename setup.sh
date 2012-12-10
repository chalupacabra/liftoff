#!/bin/bash

DIR=`pwd`
DATABAG_PASSWORD=password

# Verify the instance meets necessary checks
. ./check.sh

# Read app name
read -p "Your application name (only letters, numbers and dashes): " APP_PREFIX
APP=`echo $APP_PREFIX | tr '[:upper:]' '[:lower:]'`

# Get SSH Key
read -p "SSH key name in AWS region you wish to deploy: " KEY_NAME

# Setup heirloom archive repositories
echo "Creating App Heirloom for $APP"
heirloom setup -b $APP -n $APP-app -r us-west-1 -r us-west-2 -r us-east-1 -l warn
if [ $? -ne 0 ]; then
  echo "Unable to setup heirloom app."
  exit 1
fi

# Hack until https://github.com/intuit/heirloom/issues/100 is closed
sleep 5

echo "Creating Chef Repo Heirloom for $APP"
heirloom setup -b $APP -n $APP-chef-repo -r us-west-1 -r us-west-2 -r us-east-1 -l warn
if [ $? -ne 0 ]; then
  echo "Unable to setup heirloom chef-repo."
  exit 1
fi

# Upload sample app and chef repo
echo "Uploading App Version v1.0.0"
heirloom upload -n $APP-app -i 'v1.0.0' -d $DIR/app -l warn
if [ $? -ne 0 ]; then
  echo "Unable to upload app"
  exit 1
fi
echo "Uploading Chef Repo Version v1.0.0"
heirloom upload -n $APP-chef-repo -i 'v1.0.0' -d $DIR/chef-repo -l warn
if [ $? -ne 0 ]; then
  echo "Unable to upload chef-repo"
  exit 1
fi

echo
echo "Setup complete. Chef Repo, Cookbooks and App have been deployed via Heirloom and are ready."
echo

# Launch the app

echo "#1. Launch auto scaling group:"
echo
echo "simple_deploy create -e preprod -n $APP-01 -t $DIR/cloud-formation-templates/examples/classic/asg_with_cpu_scaling_policies.json -a AppName=$APP -a EnvironmentSecret=$DATABAG_PASSWORD -a KeyName=$KEY_NAME -a app=v1.0.0 -a chef_repo=v1.0.0 -a app_domain=$APP-app -a chef_repo_domain=$APP-chef-repo -a app_bucket_prefix=$APP -a chef_repo_bucket_prefix=$APP"
echo
echo "#2. Upload a new version of $DIR/app:"
echo
echo "heirloom upload -n $APP-app -i 'v1.0.1' -d $DIR/app"
echo
echo "#3. Deploy updated app version:"
echo
echo "export SIMPLE_DEPLOY_SSH_USER=ec2-user"
echo "export SIMPLE_DEPLOY_SSH_KEY=path_to_ssh_key"
echo "simple_deploy deploy -e preprod -n $APP-01 -a app=v1.0.1"

exit 0
