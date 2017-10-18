.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Yifei Xue (HUAWEI) and Justin Chi (HUAWEI)

K8s introduction
================

Kubernetes Architecture
-----------------------

Currently Compass can deploy kubernetes as NFVI in 3+2 mode by default.

**The following figure shows a typical architecture of Kubernetes.**

.. figure:: images/architecture.png
    :alt: K8s architecture
    :figclass: align-center

    Fig 3. K8s architecture

Kube-apiserver
~~~~~~~~~~~~~~

Kube-apiserver exposes the Kubernetes API. It is the front-end for the Kubernetes control plane.
It is designed to scale horizontally, that is, it scales by deploying more instances.

Etcd
~~~~

Etcd is used as Kubernetes' backing store. All cluster data is stored here. Always have a backup
plan for etcd's data for your Kubernetes cluster.

Kube-controller-manager
~~~~~~~~~~~~~~~~~~~~~~~

Kube-controller-manager runs controllers, which are the background threads that handle routine
tasks in the cluster. Logically, each controller is a separate process, but to reduce complexity,
they are all compiled into a single binary and run in a single process.

These controllers include:

        - Node Controller: Responsible for noticing and responding when nodes go down.
        - Replication Controller: Responsible for maintaining the correct number of pods for every
          replication controller object in the system.
        - Endpoints Controller: Populates the Endpoints object (that is, joins Services & Pods).
        - Service Account & Token Controllers: Create default accounts and API access tokens for
          new namespaces.

kube-scheduler
~~~~~~~~~~~~~~

Kube-scheduler watches newly created pods that have no node assigned, and selects a node for them
to run on.

Kubelet
~~~~~~~

Kubelet is the primary node agent. It watches for pods that have been assigned to its node (either
by apiserver or via local configuration file) and:

        - Mounts the pod's required volumes.
        - Downloads the pod's secrets.
        - Runs the pod's containers via docker (or, experimentally, rkt).
        - Periodically executes any requested container liveness probes.
        - Reports the status of the pod back to the rest of the system, by creating a mirror pod if
          necessary.
        - Reports the status of the node back to the rest of the system.

Kube-proxy
~~~~~~~~~~

Kube-proxy enables the Kubernetes service abstraction by maintaining network rules on the host and
performing connection forwarding.

Docker
~~~~~~

Docker is used for running containers.

POD
~~~

A pod is a collection of containers and its storage inside a node of a Kubernetes cluster. It is
possible to create a pod with multiple containers inside it. For example, keeping a database container
and data container in the same pod.

Understand Kubernetes Networking in Compass configuration
---------------------------------------------------------

**The following figure shows the Kubernetes Networking in Compass configuration.**

.. figure:: images/k8s.png
    :alt: Kubernetes Networking in Compass
    :figclass: align-center

    Fig 4. Kubernetes Networking in Compass
