#!/bin/bash
#set -x
COMPASS_DIR=`cd ${BASH_SOURCE[0]%/*}/;pwd`
export COMPASS_DIR

if [[ -z $DEPLOY_COMPASS && -z $DEPLOY_HOST && -z $REDEPLOY_HOST ]]; then
    export DEPLOY_COMPASS="true"
    export DEPLOY_HOST="true"
fi

$COMPASS_DIR/deploy/launch.sh $*
