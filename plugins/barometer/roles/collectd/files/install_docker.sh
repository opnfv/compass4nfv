#!/bin/bash

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sleep 3

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
sleep 3

apt-get install -y docker-ce
sleep 5
