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
    print "Read local Cache dir is %s" %cache_dir

    package_url = os.environ.get('PACKAGE_URL')
    print "Read local Cache server is %s" %package_url

    return cache_dir, package_url

def get_from_cache(cache, cache_server, package):
    filename = package.get("file")
    remotefile = cache_server + "/" + filename
    localfile = cache + "/" + filename
    localmd5file = localfile + ".md5"
    remotemd5file = remotefile + ".md5"
    print "removing local md5 file...."
    cmd="rm -f " + localmd5file
    os.system(cmd)
    print "downloading remote md5 file to local...."
    cmd="curl --connect-timeout 10 -o " + localmd5file + " " + remotemd5file + " 2>/dev/null"
    os.system(cmd)
    if os.path.exists(localmd5file):
        print "calculate md5sum of local file"
        cmd = "md5sum " + localfile + "|cut -d ' ' -f 1"
        localmd5sum = os.popen(cmd).readlines()
        cmd = "cat " + localmd5file + "|cut -d ' ' -f 1"
        remotemd5sum = os.popen(cmd).readlines()
        print "Compare between local md5 %s and remote md5 %s" %(localmd5sum, remotemd5sum)
        if (remotemd5sum == localmd5sum):
             print "Same with remote, no need to download...."
             return
    print "downloading remote file to local...."
    cmd="curl --connect-timeout 10 -o " + localfile + " " + remotefile
    print cmd
    os.system(cmd)

def get_from_git(cache, package):
    localfile = cache + "/" + package.get("name")
    cmd="rm -rf " + localfile
    print cmd
    os.system(cmd)
    cmd="git clone " + package.get("url") + " " + localfile
    print cmd
    os.system(cmd)

def get_from_local(cache, package):
    print "wip"

def get_from_wget(cache, package):
    print "wip"

def get_from_curl(cache, package):
    print "wip"

def usage():
    print "cached: Download from a cached server"
    print "git   : Download from git url"
    print "wget  : Download from a url link by wget"
    print "curl  : Download from a url link by curl"
    print "local : Download from a local directory"

def build_parser(build_file_name):
    cache, cache_server = load_env()
    cfg = yaml.load(file(build_file_name, 'r'))

    print "Starting building...."
    for pkg in cfg.get("packages"):
        print "processing %s" %pkg.get("description")

        if pkg.get("get_method") == "cached":
            get_from_cache(cache,cache_server, pkg)
        elif pkg.get("get_method") == "git":
            get_from_git(cache, pkg)
        else:
            usage

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)
    build_parser(sys.argv[1])
