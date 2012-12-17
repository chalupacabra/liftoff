#!/bin/bash

set -e

METADATA_PATH=/etc/intu_metadata.d
DEFAULT_ROLE_FILE="$METADATA_PATH/instance_role"
CHEF_DIR=/var/chef
CHEF_CACHE_DIR=$CHEF_DIR/cache
CHEF_CONFIG_DIR=$CHEF_DIR/config
CHEF_LOG_DIR=/var/log/chef
S3_CMD="s3cmd"
S3_GET_CMD="$S3_CMD get"
CONFIGURE_TMP=/var/tmp/configure

######################
# FUNCTIONS
######################
function show_help {
  echo "Usage: `basename $0`"
  echo ''
  echo 'This scripts expects the following environment variables to be set:'
  echo 'CHEF_REPO_URL (mandatory)'
  echo 'CONFIGURE_ROLE (optional)'
  echo 'CHEF_REPO_SECRET (optional)'
  echo "CHEF_PACKAGE_URL (optional) - This is only optional if chef is already installed.  Otherwise, it's mandatory."
  echo ''
}

function determine_default_role {
  if [ ! -f $DEFAULT_ROLE_FILE ]; then
    log_error_and_exit "Error determining the default role from '$DEFAULT_ROLE_FILE'"
  fi

  if [ `grep -c ROLE $DEFAULT_ROLE_FILE` -ne 1 ]; then
    log_error_and_exit "Unable to determine the role in $DEFAULT_ROLE_FILE"
  fi

  export `grep ROLE $DEFAULT_ROLE_FILE`
  log_info "Determined the default role"
}

function decrypt_archive {
  encrypted_archive_path=$1
  decrypted_archive_path=$2

  if [ ! ${CHEF_REPO_SECRET:+x} ]; then
    echo "* CHEF_REPO_SECRET is a required variable when archive is encrypted."
    echo ""
    show_help
    exit 1
  fi

  log_info "Decrypting $encrypted_archive_path archive to $decrypted_archive_path"
  `gpg --batch --yes --cipher-algo AES256 --passphrase $CHEF_REPO_SECRET --output $decrypted_archive_path $encrypted_archive_path`
  log_info "Decrypted $encrypted_archive_path archive to $decrypted_archive_path"

  log_info "Removing encrypted archive ($encrypted_archive_path)"
  rm -fr $encrypted_archive_path
  log_info "Encrypted archive ($encrypted_archive_path) removed"
}

function download_file {
  if [[ $1 = s3* ]]; then
    log_info "Downloading $1 to $2 using s3"
    if ! output=`$S3_GET_CMD $1 $2 --force 2>&1`; then
      log_error "$output"
      log_error_and_exit "Error downloading $1 to $2"
    fi
  elif [[ $1 = http* ]]; then
    log_info "Downloading $1 to $2 using http"
    if ! output=`wget -0 $2 $1 2>&1`; then
      log_error "$output"
      log_error_and_exit "Error downloading $1 to $2"
    fi
  else
    log_error_and_exit "Sorry, I don't know how to download that type of file ('$1')"
  fi
}

function download_and_extract_archive {
  log_info "Downloading $1 archive"
  download_file $2 $CONFIGURE_TMP
  log_info "Downloaded $1 archive"

  file_name=`basename "$2"`
  decrypted_file_name=`echo $file_name | sed -e 's/\.gpg$//g'`

  # Only decrypt archive if it end in '.gpg'
  if [ "$decrypted_file_name" != "$file_name" ]; then
    decrypt_archive $file_name $decrypted_file_name
  fi

  archive_path="$CONFIGURE_TMP/$decrypted_file_name"

  log_info "Extracting $1 archive ($decrypted_file_name)"
  if ! output=`tar zxf $decrypted_file_name -C $CHEF_DIR 2>&1`; then
    log_error "$output"
    log_error_and_exit "Error extracting $1"
  fi
  log_info "Extracted $1 archive"

  log_info "Removing $1 archive ($archive_path)"
  rm -fr $archive_file
  log_info "Removed $1 archive"
}

function download_and_extract_chef_repo {
  mkdir -p $CHEF_CACHE_DIR
  mkdir -p $CHEF_LOG_DIR

  download_and_extract_archive 'chef repo' $CHEF_REPO_URL
}

function ensure_chef_is_installed {
  if [ $(rpm -qa | grep -v grep | grep -i chef | wc -l ) -eq 0 ]; then
    log_error_and_exit "Chef must be installed."
  fi
}

function ensure_tmp_location_exists {
  mkdir -p $CONFIGURE_TMP
}

function ensure_mandatory_env_vars {
  if [ ! ${CHEF_REPO_URL:+x} ]; then
    echo "* CHEF_REPO_URL is a mandatory environment variable"
    echo ""
    show_help
    exit 1
  fi
}

function run_chef {
  cd $CHEF_DIR

  determined_role=$ROLE

  if [ ! -z "$CONFIGURE_ROLE" ]; then
    determined_role=$CONFIGURE_ROLE
  fi

  log_info "Determined chef role is '$determined_role'"

  # chef-solo command not assigned to variable due to 
  # issue with override variables not being interpreted correctly on CLI
  log_info "Chef command: chef-solo -c $CHEF_CONFIG_DIR/solo.rb -o \"role[$determined_role]\""

  if ! output=`chef-solo -c $CHEF_CONFIG_DIR/solo.rb -o "role[$determined_role]"`; then
    log_error "$output"
    log_error_and_exit "Error running chef"
  fi

}

function log_error {
  logger -p user.err -t "configure_script" "$1"
  echo "$1"
}

function log_error_and_exit {
  log_error "$1"
  exit 1
}

function log_info {
  logger -p user.info -t "configure_script" "$1"
  echo "$1"
}
######################
# END FUNCTIONS
######################

umask 022

if [ "$#" -ne 0 ]; then
  case $1 in
    -h | --help)
      show_help
      exit 0
      ;;
  esac
fi

ensure_mandatory_env_vars

log_info "Starting"

determine_default_role

ensure_tmp_location_exists

download_and_extract_chef_repo

if [ -z "$CONFIGURE_RECURSED" ]; then
  log_info 'Re-running script from chef repo'
  CONFIGURE_RECURSED=1 $0 $*
  log_info 'Complete'
  exit 0
fi

ensure_chef_is_installed

run_chef

log_info 'Done running chef'

exit 0
