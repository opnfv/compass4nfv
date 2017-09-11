#!/bin/bash

mkdir -p /home/networking
mkdir -p /home/tmp

cd /home/networking

git clone https://github.com/openstack/networking-odl.git -b stable/ocata
git clone https://github.com/openstack/networking-sfc.git -b stable/ocata

sed -i 's/^Babel.*/Babel!=2.4.0,>=2.3.4/' /home/networking/networking-odl/requirements.txt

pip wheel /home/networking/networking-odl/ -w /home/tmp/
pip wheel /home/networking/networking-sfc/ -w /home/tmp/

cp /home/tmp/networking* /var/www/repo/os-releases/15.1.4/ubuntu-16.04-x86_64/
