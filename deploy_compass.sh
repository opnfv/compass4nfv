#!/bin/bash
export DEPLOY_COMPASS=${DEPLOY_COMPASS-"true"}

./deploy.sh $*
