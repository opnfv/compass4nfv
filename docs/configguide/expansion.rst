.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Expansion Guide
===============

Edit network.yml
----------------

The below file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/vm_environment/huawei-virtual1/network.yml"

You can edit the network.yml which you had edited before the first deployment.

NOTE:
External subnet's ip_range should be changed as the first 6 IPs are already taken
by the first deployment.

Edit dha.yml
------------

The below file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/vm_environment/virtual_cluster_expansion.yml"

You can use this dha file though edit host names and mac.

E.g. Only increase one compute node

.. code-block:: yaml

    hosts:
      - name: host6
        mac: '00:00:aa:bb:cc:d6'
        roles:
          - computer

E.g. Increase two compute nodes

.. code-block:: yaml

    hosts:
      - name: host7
        mac: '00:00:aa:bb:cc:d7'
        roles:
          - computer

    hosts:
      - name: host8
        mac: '00:00:aa:bb:cc:d8'
        roles:
          - computer

Start Expansion
---------------

1. Edit add.sh
    Check the environment variable. 

    NOTE:
    The OS version and OpenStack version should be same as the first deployment.

2. Run ``add.sh``
