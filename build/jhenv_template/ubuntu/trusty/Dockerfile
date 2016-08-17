FROM ubuntu:14.04.3
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./cp_env.sh /cp_env.sh

RUN apt-get update

RUN apt-get install -y -d mkisofs bc curl ipmitool openvswitch-switch \
git python-pip python-dev figlet \
libxslt-dev libxml2-dev libvirt-dev \
build-essential qemu-utils qemu-kvm libvirt-bin \
virtinst libmysqld-dev \
libssl-dev libffi-dev python-cffi

RUN mkdir jh_deb

RUN cp /var/cache/apt/archives/*.deb jh_deb/

RUN tar -zcvf env_trusty_deb.tar.gz jh_deb/

RUN apt-get install -y python-pip

RUN mkdir jh_pip

RUN pip install --upgrade markupsafe virtualenv cheetah pyyaml requests netaddr pbr oslo.config ansible -d jh_pip/

RUN tar -zcvf env_trusty_pip.tar.gz jh_pip/

RUN mkdir -p /home/tmp

RUN cp *.tar.gz /home/tmp

RUN chmod +x /cp_env.sh

CMD ["/cp_env.sh"]
