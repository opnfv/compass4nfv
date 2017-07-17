#!/bin/bash

sed -i '/\[networking_sfc.sfc.drivers\]/a onos = networking_onos.services.sfc.driver:OnosSfcDriver' /usr/local/lib/python2.7/dist-packages/networking_sfc-3.0.0.dist-info/entry_points.txt

sed -i '/\[networking_sfc.flowclassifier.drivers\]/a onos = networking_onos.services.flowclassifier.driver:OnosFlowClassifierDriver' /usr/local/lib/python2.7/dist-packages/networking_sfc-3.0.0.dist-info/entry_points.txt
