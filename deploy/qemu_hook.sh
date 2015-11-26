#!/bin/bash
if [ "$2" == "started" ]; then
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  exists=$(ifconfig | grep macvtap|awk '{print $1}')

  for i in $exists; do
    ifconfig $i allmulti
    echo "$timestamp ALLMULTI set on $i" >> /var/log/libvirt_hook_qemu.log
  done
fi
