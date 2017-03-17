import yaml
import os
import sys

cache = os.environ.get('CACHE_DIR')
print "Read local Cache dir is %s" %cache

cache_server = os.environ.get('PACKAGE_URL')
print "Read local Cache server is %s" %cache_server

cfg = yaml.load(file(sys.argv[1], 'r'))

print "Starting building...."
for i in cfg.get("packages"):
    print "processing %s" %i.get("description")

    if i.get("get_method") == "cached":
        filename = i.get("file")
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
            print cmd
            localmd5sum = os.popen(cmd).readlines()
            cmd = "cat " + localmd5file + "|cut -d ' ' -f 1"
            remotemd5sum = os.popen(cmd).readlines()
            print "Compare between local md5 %s and remote md5 %s" %(localmd5sum, remotemd5sum)
            if (remotemd5sum == localmd5sum):
                 continue
        print "downloading remote file to local...."
        cmd="curl --connect-timeout 10 -o " + localfile + " " + remotefile
        print cmd
        os.system(cmd)
    if i.get("get_method") == "git":
        localfile = cache + "/" + i.get("name")
        cmd="rm -rf " + localfile
        print cmd
        os.system(cmd)
        cmd="git clone " + i.get("url") + " " + localfile
        print cmd
        os.system(cmd)

    print i.get("name")
    print i.get("name")
    print i.get("description")
    print i.get("get_method")
#    print i.get("url")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)
 
    print("parameter %d %s" % (len(sys.argv), sys.argv))
