##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import yaml
import os
import sys


def load_env():
    cache_dir = os.environ.get('CACHE_DIR')
    print "Read local Cache dir is %s" % cache_dir
    return cache_dir


def exec_command(cmd, ignore_error=False):
    rc = os.system(cmd)
    if not ignore_error and rc != 0:
        sys.exit(1)
    else:
        return rc


def get_from_cache(cache, package):
    filename = package.get("name")
    remotefile = list(package.get("url"))
    localfile = cache + "/" + filename
    localmd5file = localfile + ".md5"
    print "removing local md5 file...."
    cmd = "rm -f " + localmd5file
    exec_command(cmd)
    print "downloading remote md5 file to local...."
    for file in remotefile:
        remotemd5file = file + ".md5"
        cmd = "curl --connect-timeout 10 -o {0} {1}".format(
            localmd5file, remotemd5file)
        rc = exec_command(cmd, True)
        if os.path.exists(localfile):
            print "calculate md5sum of local file"
            cmd = "md5sum " + localfile + "|cut -d ' ' -f 1"
            localmd5sum = os.popen(cmd).readlines()
            cmd = "cat " + localmd5file + "|cut -d ' ' -f 1"
            remotemd5sum = os.popen(cmd).readlines()
            print "md5 local %s remote %s" % (localmd5sum, remotemd5sum)
            if (remotemd5sum == localmd5sum):
                print "Same with remote, no need to download...."
                return
        if rc == 0:
            break
    print "downloading remote file to local...."
    cmd = "aria2c --max-tries 1 --max-connection-per-server=4 \
          --allow-overwrite=true --dir={0} --out={1} {2}".format(
          cache, filename, " ".join(remotefile))
    print cmd
    exec_command(cmd)


def get_from_git(cache, package):
    localfile = cache + "/" + package.get("name")
    cmd = "rm -rf " + localfile
    print cmd
    exec_command(cmd)
    cmd = "git clone " + package.get("url") + " " + localfile
    print cmd
    exec_command(cmd)


def get_from_docker(cache, package):
    package_ouput = cache+"/"+package.get("name")+".tar"
    cmd = "sudo docker pull "+package.get("url")
    exec_command(cmd)
    cmd = "sudo docker save "+package.get("url")+" -o "+package_ouput
    exec_command(cmd)
    cmd = "user=$(whoami); sudo chown -R $user:$user "+package_ouput
    exec_command(cmd)


def get_from_curl(cache, package):
    cmd = "curl --connect-timeout 10 -o " + cache + "/"
    cmd += package.get("name") + " " + package.get("url")
    print cmd
    exec_command(cmd)


def usage():
    print "cached : Download from a cached server"
    print "git    : Download from git url"
    print "curl   : Download from a url link by curl"
    print "docker : Download from docker hub"


def build_parser(build_file_name):
    cache = load_env()
    cfg = yaml.safe_load(file(build_file_name, 'r'))

    print "Starting building...."
    for pkg in cfg.get("packages"):
        print "processing %s" % pkg.get("description")

        if pkg.get("get_method") == "cached":
            get_from_cache(cache, pkg)
        elif pkg.get("get_method") == "git":
            get_from_git(cache, pkg)
        elif pkg.get("get_method") == "docker":
            get_from_docker(cache, pkg)
        elif pkg.get("get_method") == "curl":
            get_from_curl(cache, pkg)
        else:
            usage

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)
    build_parser(sys.argv[1])
