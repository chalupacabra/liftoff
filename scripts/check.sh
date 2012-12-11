#!/bin/bash

USER=`whoami`

if [ $USER == "root" ]; then
  echo "Error: Cannot be run as root."
  exit 1
fi

if [ ! `which git` ]; then
  echo "Error: Git must be installed."
  exit 1
fi

if [ ! `which ruby` ]; then
  echo "Ruby must be installed."
  exit 1
fi

RUBY_VERSION=`ruby -v | grep ^ruby | awk {'print $2'} |cut -b1-3`
if [ "$RUBY_VERSION" != "1.9" ]; then
  echo "Error: Ruby version must be 1.9.X"
  exit 1
fi

if [ ! `which heirloom` ]; then
  echo "Error: Heirloom must be installed."
  exit 1
fi

if [ ! `which simple_deploy` ]; then
  echo "Error: Simple Deploy must be installed."
  exit 1
fi

echo "All Good!"
