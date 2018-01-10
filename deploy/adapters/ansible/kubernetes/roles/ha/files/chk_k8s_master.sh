#!/bin/bash

count=`ss -tnl | grep 6443 | wc -l`

if [ $count = 0 ]; then
    exit 1
else
    exit 0
fi
