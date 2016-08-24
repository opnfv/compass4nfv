FROM ubuntu:14.04.3
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./cp_env.sh /cp_env.sh

RUN apt-get update

RUN apt-get install -y wget

RUN apt-get install -y -d mkisofs bc curl ipmitool openvswitch-switch \
git python-pip python-dev figlet \
libxslt-dev libxml2-dev libvirt-dev \
build-essential qemu-utils qemu-kvm libvirt-bin \
virtinst libmysqld-dev \
libssl-dev libffi-dev python-cffi

RUN wget -P /var/cache/apt/archives/ http://launchpadlibrarian.net/225838998/libffi6_3.1~rc1+r3.0.13-12ubuntu0.1_amd64.deb

RUN mkdir jh_deb

RUN cp /var/cache/apt/archives/*.deb jh_deb/

RUN apt-get install -y reprepro

RUN mkdir -p trusty-jh-ppa/conf

RUN echo 'Codename: trusty\n\
Components: main\n\
Architectures: amd64\n'\
>> trusty-jh-ppa/conf/distributions

RUN reprepro -b trusty-jh-ppa includedeb trusty jh_deb/*.deb

RUN tar -zcvf /trusty-jh-ppa.tar.gz ./trusty-jh-ppa

RUN apt-get install -y python-pip

RUN mkdir jh_pip

RUN pip install --upgrade paramiko jinja2 PyYAML setuptools pycrypto pyasn1 \
cryptography MarkupSafe idna six enum34 ipaddress cffi pycparser \
virtualenv cheetah requests netaddr pbr oslo.config ansible -d jh_pip/

RUN tar -zcvf env_trusty_pip.tar.gz jh_pip/

RUN mkdir -p /home/tmp

RUN cp *.tar.gz /home/tmp

RUN chmod +x /cp_env.sh

CMD ["/cp_env.sh"]
