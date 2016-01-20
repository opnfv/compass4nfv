#!/bin/bash
#set -x
COMPASS_DIR=`cd ${BASH_SOURCE[0]%/*}/;pwd`
export COMPASS_DIR

if [[ -z $DEPLOY_COMPASS && -z $DEPLOY_HOST && -z $REDEPLOY_HOST ]]; then
    export DEPLOY_COMPASS="true"
    export DEPLOY_HOST="true"
fi

sudo apt-get install -y --force-yes python-pip
sudo pip install --upgrade pip
sudo pip install --upgrade cheetah
sudo pip install --upgrade pyyaml

$COMPASS_DIR/deploy/launch.sh $*
