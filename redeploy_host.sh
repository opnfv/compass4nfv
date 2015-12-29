#!/bin/bash
export REDEPLOY_HOST=${REDEPLOY_HOST-"true"}

./deploy.sh $*
