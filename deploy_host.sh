#!/bin/bash
export DEPLOY_HOST=${DEPLOY_HOST-"true"}

./deploy.sh $*
