import os
import sys
import yaml

def exec_cmd(cmd):
    print cmd
    os.system(cmd)

def reset_baremetal(dha_info):
    print "reset_baremetal"

    hosts_info = yaml.load(open(dha_info))
    #print hosts_info

    ipmiUserDf = hosts_info.get('ipmiUser', 'root')
    ipmiPassDf = hosts_info.get('ipmiPass', 'Huawei@123')
    print ipmiUserDf
    print ipmiPassDf

    hosts_list = hosts_info.get('hosts', [])
    #print hosts_list
    
    for host in hosts_list:
        print host
        if ('compute' in host['roles']):
            ipmiUser = host.get('ipmiUser', ipmiUserDf)
            ipmiPass = host.get('ipmiPass', ipmiPassDf)
            ipmiIp = host['ipmiIp']
            print ipmiUser
            print ipmiPass
            print ipmiIp
            exec_cmd("ipmitool -I lanplus -H %s -U %s -P %s chassis power reset >/dev/null" % (ipmiIp, ipmiUser, ipmiPass))


def reset_virtual(dha_info):
    print "reset_virtual"

    hosts_info = yaml.load(open(dha_info))
    print hosts_info

    hosts_list = hosts_info.get('hosts', [])

    for host in hosts_list:
        print host
        if ('compute' in host['roles']):
            name = host['name']
            exec_cmd("virsh destroy %s" % name)
            exec_cmd("virsh start %s" % name) 

if __name__ == "__main__":
    deploy_type=sys.argv[1]
    dha_info=sys.argv[2]
    print deploy_type
    print dha_info
    if (deploy_type == 'baremetal') :
        reset_baremetal(dha_info)
    elif (deploy_type == 'virtual') :
        reset_virtual(dha_info)

