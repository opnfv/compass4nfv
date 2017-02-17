##############################################################################
# Copyright (c) 2016 liyuenan@huawei.com and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
#!/usr/bin/env python3

import sys
import subprocess

pkts = []

for arg in sys.argv[1:]:
    proc = subprocess.Popen(["dpkg-deb",
                             "--info",
                             arg],
                            stdin=None,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    out = proc.stdout.read()
    err = proc.stderr.read()
    if err:
        print("An error occurred with {} ({})".format(arg, err))
        continue
    for line in out.splitlines():
        line = line.decode('utf-8')
        if " Depends:" in line:
            line = line.replace(" Depends:", "")
            for _dep in line.split(','):
                pkts.append(_dep.split()[0])

print(" ".join(pkts))
