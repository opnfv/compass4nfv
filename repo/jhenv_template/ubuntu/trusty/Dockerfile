FROM ubuntu:14.04.5
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./cp_env.sh /cp_env.sh

RUN apt-get update

RUN apt-get install -y wget

RUN apt-get install -y -d mkisofs bc curl ipmitool openvswitch-switch \
git python-pip python-dev figlet \
libxslt-dev libxml2-dev libvirt-dev \
build-essential qemu-utils qemu-kvm libvirt-bin \
virtinst libmysqld-dev apparmor \
libssl-dev libffi-dev python-cffi

RUN mkdir jh_deb

RUN cp /var/cache/apt/archives/*.deb jh_deb/

#RUN wget -O jh_deb/gcc-5-base_5.4.0-6ubuntu1~16.04.5_amd64.deb http://launchpadlibrarian.net/336920226/gcc-5-base_5.4.0-6ubuntu1~16.04.5_amd64.deb

#RUN wget -O jh_deb/libstdc++6_5.4.0-6ubuntu1~16.04.5_amd64.deb http://launchpadlibrarian.net/336920453/libstdc++6_5.4.0-6ubuntu1~16.04.5_amd64.deb

#RUN wget -O jh_deb/libssl1.0.0_1.0.2g-1ubuntu4.9_amd64.deb http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu4.9_amd64.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-extra-4.4.0-31-generic

RUN apt-get install -y reprepro curl \
linux-image-extra-virtual apt-transport-https ca-certificates \
software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN apt-key fingerprint 0EBFCD88

RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
trusty stable"

RUN apt-get update

RUN apt-get install -y docker-ce -d

RUN cp /var/cache/apt/archives/*.deb jh_deb/

RUN mkdir -p jh-ppa/conf

RUN echo 'Codename: trusty\n\
Components: main\n\
Architectures: amd64\n'\
>> jh-ppa/conf/distributions

RUN reprepro -b jh-ppa includedeb trusty jh_deb/*.deb

RUN tar -zcvf /jh-ppa.tar.gz ./jh-ppa

RUN apt-get install -y python-pip ansible libffi-dev python-dev

RUN mkdir jh_pip

RUN pip install virtualenv \
cffi==1.10.0 \
MarkupSafe==1.0 \
pip==9.0.1 \
cheetah==2.4.4 \
pyyaml==3.12 \
netaddr==0.7.19 \
oslo.config==4.6.0 \
cryptography==1.9 \
ansible==2.3.1.0 \
docker-compose==1.14.0 \
-d jh_pip/

RUN pip install pyOpenSSL \
cryptography==1.9 \
-d jh_pip/

RUN pip install requests==2.18.1 \
-d jh_pip/

RUN tar -zcvf jh_pip.tar.gz jh_pip/

RUN mkdir jh_env_package

RUN mv *.tar.gz jh_env_package/

RUN tar -zcvf jh_env_trusty.tar.gz jh_env_package/

RUN chmod +x /cp_env.sh

CMD ["/cp_env.sh"]
