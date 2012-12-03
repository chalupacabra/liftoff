Lift Off is a collection of Cloud Formation Templates, Chef Repo and configuration scripts which leverages Intuit's Open Source Build and Deploy tools to quickly deploy Chef configured instances on Amazon Linux.

How To Use This Repo
====================

This repo is a starting point and meant to be forked and included in your local source and evolved with your project.

Technologies
============

* [Cloud Formation](http://aws.amazon.com/cloudformation)
* [Chef](http://www.opscode.com/chef/)
* [Heirloom](https://github.com/intuit/heirloom)
* [Simple Deploy](https://github.com/intuit/simple_deploy)
* [Ruby](http://www.ruby-lang.org/en/) (see Appendix for OSX installation instructions)
* [Git](http://git-scm.com/) (see Appendix for OSX installation instructions)
* [Data Bags](http://wiki.opscode.com/display/chef/Data+Bags)

Prerequisites
=============
  
* Git installed.
* Ruby version 1.9.2 or greater with the **bundler** gem installed.
* You have an AWS account and have created an API key and secret.
* You have created an AWS ssh key and have saved the secret PEM file.

Getting Started
===============

Clone Liftoff
-------------

```
git clone https://github.com/brettweavnet/liftoff
```

From within the cloned directory, run bundle.

```
bundle
```

Setup Credentials
-----------------

Create **~/.heirloom.yml** configuration file using the below template..

```
aws:
  access_key: ACCESS_KEY
  secret_key: SECRET_KEY
```

Create **~/.simple_deploy.yml** configuration file using the below template.

```
environments:
  preprod:
    access_key: ACCESS_KEY
    secret_key: SECRET_KEY
    region: us-west-1
```

Upload Chef Repo and App To S3
------------------------------

From within the cloned directory, run **setup.sh**. You will be asked for the application name as well as the SSH key name (this is the name within the AWS Console):

```
bash setup.sh
```

This will setup the appropriately named Heirlooms in S3 and output the command to deploy a new stack:

```
# bash ./setup.sh
Your application name (only letters, numbers and dashes): bweaver-test1
SSH key name in AWS region you wish to deploy: control
Creating App Heirloom for bweaver-test1
Creating Chef Repo Heirloom for bweaver-test1
Uploading App Version v1.0.0
Uploading Chef Repo Version v1.0.0

Setup complete. Chef Repo, Cookbooks and App have been deployed via Heirloom and are ready.

#1. Launch auto scaling group:

simple_deploy create -e preprod -n bweaver-test1-01 -t /Users/bweaver/code/liftoff/cloud-formation-templates/examples/classic/asg_with_cpu_scaling_policies.json -a AppName=bweaver-test1 -a EnvironmentSecret=password -a MinimumAppInstances=1 -a MaximumAppInstances=1 -a KeyName=control -a app=v1.0.0 -a chef_repo=v1.0.0 -a app_domain=bweaver-test1-app -a chef_repo_domain=bweaver-test1-chef-repo -a app_bucket_prefix=bweaver-test1 -a chef_repo_bucket_prefix=bweaver-test1
```

Launching The Stack
-------------------

Execute the simple_deploy command output by the setup.sh script:

```
# simple_deploy create -e preprod -n bweaver-test1-01 -t /Users/bweaver/code/liftoff/cloud-formation-templates/examples/classic/asg_with_cpu_scaling_policies.json -a AppName=bweaver-test1 -a EnvironmentSecret=password -a MinimumAppInstances=1 -a MaximumAppInstances=1 -a KeyName=control -a app=v1.0.0 -a chef_repo=v1.0.0 -a app_domain=bweaver-test1-app -a chef_repo_domain=bweaver-test1-chef-repo -a app_bucket_prefix=bweaver-test1 -a chef_repo_bucket_prefix=bweaver-test1
2012-12-02 11:31:10 -0800 INFO : Read AppName=bweaver-test1
2012-12-02 11:31:10 -0800 INFO : Read EnvironmentSecret=intuit01
2012-12-02 11:31:10 -0800 INFO : Read MinimumAppInstances=1
2012-12-02 11:31:10 -0800 INFO : Read MaximumAppInstances=1
2012-12-02 11:31:10 -0800 INFO : Read KeyName=control
2012-12-02 11:31:10 -0800 INFO : Read app=v1.0.0
2012-12-02 11:31:10 -0800 INFO : Read chef_repo=v1.0.0
2012-12-02 11:31:10 -0800 INFO : Read app_domain=bweaver-test1-app
2012-12-02 11:31:10 -0800 INFO : Read chef_repo_domain=bweaver-test1-chef-repo
2012-12-02 11:31:10 -0800 INFO : Read app_bucket_prefix=bweaver-test1
2012-12-02 11:31:10 -0800 INFO : Read chef_repo_bucket_prefix=bweaver-test1
2012-12-02 11:31:11 -0800 INFO : Adding artifact attribute: {"AppArtifactURL"=>"s3://bweaver-test1-us-west-1/bweaver-test1-app/v1.0.0.tar.gz"}
2012-12-02 11:31:11 -0800 INFO : Adding artifact attribute: {"ChefRepoURL"=>"s3://bweaver-test1-us-west-1/bweaver-test1-chef-repo/v1.0.0.tar.gz"}
2012-12-02 11:31:11 -0800 INFO : Creating Cloud Formation stack bweaver-test1-01.
2012-12-02 11:31:12 -0800 INFO : Cloud Formation stack creation completed.
```

You can view the status of the stack:

```
# simple_deploy status -e preprod -n bweaver-test1-01
CREATE_COMPLETE
```

Once completed, you can get a list of instances for the stack:

```
# simple_deploy instances -e preprod -n bweaver-test1-01
[
  "184.169.185.250"
]
```

We can verify the sample app is online:

```
# curl 184.169.185.250
Hello World!
```

Deploying Updates
-----------------

Make an update to the app:

```
echo 'Hello World #2' > /Users/bweaver/code/liftoff/app/index.html
```

Uploading the app as a new id of the app Heirloom:

```
heirloom upload -n bweaver-test1-app -i 'v1.0.1' -d /Users/bweaver/code/liftoff/app
```

Deploy the updated version (replace path_to_ssh_key with the private key):

```
export SIMPLE_DEPLOY_SSH_USER=ec2-user
export SIMPLE_DEPLOY_SSH_KEY=path_to_ssh_key
simple_deploy deploy -e preprod -n bweaver-test1-01 -a app=v1.0.1
```

The updated app is now deployed:

```
# curl 184.169.185.250
Hello World #2
```

Horizontal Scaling
------------------

We can scale the stack horizontally by updating the **MaximumInstances** and **MinimumInstances** attributes:

```
simple_deploy update -e preprod -n bweaver-test1-01 -a MaximumInstances=2 -a MinimumInstances=2
```

New instances will come online:

```
# simple_deploy instances -e preprod -n bweaver-test1-01
[
  "184.169.185.250",
  "184.169.186.180"
]
```

New instances will come online and have the latest app deployed:

```
# curl 184.169.186.180
Hello World #2
```

Destroy
-------

Stacks can be destroyed once no longer necessary:

```
# simple_deploy destroy -e preprod -n bweaver-test1-01
```

Appendix
========

Installing Ruby On OSX
----------------------

Using brew, you can install the latest version of Ruby.

Install Brew:

```
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
```

Install Ruby:

```
brew install ruby
```

Ensure /usr/local/bin is in your path:

```
export PATH=/usr/local/bin:$PATH
```

Installing Git On OSX
---------------------

Using brew, you can install the latest version of Ruby.

Install Brew:

```
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
```

Install Git:

```
brew install git
```
