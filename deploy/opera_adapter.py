import os
import yaml
import sys
import subprocess
import traceback


def load_file(file):
    with open(file) as fd:
        try:
            return yaml.load(fd)
        except:
            traceback.print_exc()
            return None


def generate_openo_vm_conf(dha, conf_dir):
    """generate opera/conf/openo-vm.conf from DHA file"""
    with open(conf_dir + "/openo-vm.conf", "w") as fd:
        fd.write("OPENO_VIRT_CPUS=" + bytes(dha["openo"]["cpu"]) + "\n")
        fd.write("OPENO_VIRT_MEM=" + bytes(dha["openo"]["memory"]) + "\n")
        fd.write("OPENO_VIRT_DISK=" + bytes(dha["openo"]["disk"]) + "\n")
        fd.write("OPENO_VM_NET=" + dha["openo"]["net"] + "\n")
        fd.write("OPENO_VM_IP=" + dha["openo"]["ip"] + "\n")
        fd.write("OPENO_VM_GW=" + dha["openo"]["gw"] + "\n")
        fd.write("OPENO_VM_MASK=" + dha["openo"]["mask"] + "\n")
        fd.write("OPENO_VM_ISO_URL=" + dha["openo"]["iso_url"])


def generate_openo_docker_conf(network, conf_dir):
    """generate opera/conf/network.conf from Network file"""
    with open(conf_dir + "/network.conf", "w") as fd:
        for i in network["openo_net_info"].keys():
            fd.write(i.upper() + "=" + network["openo_net_info"][i].upper())
            fd.write("\n")

        for i in network["juju_net_info"].keys():
            fd.write(i.upper() + "=" + network["juju_net_info"][i].upper())
            fd.write("\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, dha_file, network_file = sys.argv

    if not os.path.exists(dha_file):
        print("DHA file doesn't exit")
        sys.exit(1)
    if not os.path.exists(network_file):
        print("NETWORK file doesn't exit")
        sys.exit(1)

    dha = load_file(dha_file)
    network = load_file(network_file)
    if not dha:
        print('format error in DHA: %s' % dha_file)
        sys.exit(1)
    if not network:
        print('format error in NETWORK: %s' % network_file)
        sys.exit(1)

    compass_dir = os.getenv('COMPASS_DIR')
    work_dir = os.path.join(compass_dir, 'work')
    opera_dir = os.path.join(work_dir, 'opera')
    conf_dir = os.path.join(work_dir, 'conf')

    os.system("mkdir -p " + conf_dir)
    generate_openo_vm_conf(dha, conf_dir)
    generate_openo_docker_conf(network, conf_dir)

    p1 = subprocess.Popen(
        "git clone https://gerrit.opnfv.org/gerrit/opera",
        cwd=work_dir, shell=True)
    p1.communicate()

    """need to be removed after opera patch is meraged"""
    p2 = subprocess.Popen(
        "git fetch https://gerrit.opnfv.org/gerrit/opera \
        refs/changes/17/26817/10 && git checkout FETCH_HEAD",
        cwd=opera_dir, shell=True)
    p2.communicate()

    os.system("cp -rf " + conf_dir + " " + opera_dir)

    p3 = subprocess.Popen("./opera_launch.sh", cwd=opera_dir, shell=True)
    p3.communicate()
