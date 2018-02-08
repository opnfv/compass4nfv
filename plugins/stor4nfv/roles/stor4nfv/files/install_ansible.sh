#!/bin/bash

add-apt-repository ppa:ansible/ansible # This step is needed to upgrade ansible to version 2.4.2 which is required for the ceph backend.

apt-get update
apt-get install -y ansible
sleep 5

ansible --version # Ansible version 2.4.2 or higher is required for ceph; 2.0.0.2 or higher is needed for other backends.

