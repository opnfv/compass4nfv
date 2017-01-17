import os
import yaml
import sys
import subprocess
import traceback
import ipaddress


def load_file(file):
    with open(file) as fd:
        try:
            return yaml.load(fd)
        except:
            traceback.print_exc()
            return None


def dump_file(data, file):
    with open(file, 'w') as fd:
        try:
            return yaml.dump(data, fd, default_flow_style=False)
        except:
            traceback.print_exc()
            return None


def sync_openo_network_yml(network, net_config):
    """sync opera/conf/network.yml according to Network file"""
    for i in net_config["openo_net"].keys():
        net_config["openo_net"][i] = network["openo_net"][i]

    sorted_ips = sorted(net_config["openo_docker_net"].items(),
                        key=lambda item: item[1])
    docker_ips = [i[0] for i in sorted_ips]
    docker_start_ip = unicode(network["openo_docker_net"]["docker_ip_start"],
                              "utf-8")
    docker_start_ip = ipaddress.IPv4Address(docker_start_ip)
    for i in docker_ips:
        net_config["openo_docker_net"][i] = str(docker_start_ip)
        docker_start_ip += 1

    for i in net_config["juju_net"].keys():
        net_config["juju_net"][i] = network["juju_net"][i]


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

    if dha["deploy_options"][0]["orchestrator"] != "open-o":
        sys.exit(0)

    compass_dir = os.getenv('COMPASS_DIR')
    work_dir = os.path.join(compass_dir, 'work')
    opera_dir = os.path.join(work_dir, 'opera')
    conf_dir = os.path.join(opera_dir, 'conf')
    net_config_file = os.path.join(conf_dir, 'network.yml')

    p1 = subprocess.Popen(
        "git clone https://gerrit.opnfv.org/gerrit/opera",
        cwd=work_dir, shell=True)
    p1.communicate()

    # remove this after opera deploy patch is meraged
    """need to be removed after opera patch is meraged"""
    p2 = subprocess.Popen(
        "git fetch https://gerrit.opnfv.org/gerrit/opera \
         refs/changes/17/26817/12 && git checkout FETCH_HEAD",
        cwd=opera_dir, shell=True)
    p2.communicate()

    if not os.path.exists(net_config_file):
        print('file opera/conf/network.yml not found')
        sys.exit(1)

    net_config = load_file(net_config_file)
    sync_openo_network_yml(network, net_config)
    dump_file(net_config, net_config_file)

    p3 = subprocess.Popen("./opera_launch.sh", cwd=opera_dir, shell=True)
    p3.communicate()
