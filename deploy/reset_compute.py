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

    hosts_list = hosts_info.get('hosts', {})
    #print hosts_list
    
    for i in range(0, len(hosts_list)):
        print hosts_list[i]
        if ('compute' in hosts_list[i]['roles']):
            ipmiUser = hosts_list[i].get('ipmiUser', ipmiUserDf)
            ipmiPass = hosts_list[i].get('ipmiPass', ipmiPassDf)
            ipmiIp = hosts_list[i]['ipmiIp']
            print ipmiUser
            print ipmiPass
            print ipmiIp
            exec_cmd("ipmitool -I lanplus -H %s -U %s -P %s chassis power reset >/dev/null" % (ipmiIp, ipmiUser, ipmiPass))


def reset_virtual(dha_info):
    print "reset_virtual"

    hosts_info = yaml.load(open(dha_info))
    print hosts_info

    hosts_list = hosts_info.get('hosts', {})

    for i in range(0, len(hosts_list)):
        print hosts_list[i]
        if ('compute' in hosts_list[i]['roles']):
            host = hosts_list[i]['name']
            exec_cmd("virsh destroy %s" % (host))
            exec_cmd("virsh start %s" % (host)) 

if __name__ == "__main__":
    deploy_type=sys.argv[1]
    dha_info=sys.argv[2]
    print deploy_type
    print dha_info
    if (deploy_type == 'baremetal') :
        reset_baremetal(dha_info)
    elif (deploy_type == 'virtual') :
        reset_virtual(dha_info)

