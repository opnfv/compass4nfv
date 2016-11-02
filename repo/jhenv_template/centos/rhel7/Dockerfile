FROM centos:7.1.1503
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./cp_env.sh /cp_env.sh

#RUN yum provides '*/applydeltarpm' -y

#RUN yum install deltarpm -y

RUN yum remove -y systemd

RUN yum update -y

RUN yum install yum-plugin-downloadonly

RUN mkdir -p /rpm

RUN yum install -y epel-release-7-8

RUN yum groupinstall -y --downloadonly --downloaddir=/rpm 'Development Tools'

RUN yum install -y --downloadonly --downloaddir=/rpm epel-release mkisofs bc curl ipmitool \
git python-pip python-devel figlet \
libxslt-devel libxml2-devel libvirt-devel \
qemu qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer \
guestfish libguestfs-tools virt-top mysql-devel \
openssl-devel libffi libffi-devel python-cffi

RUN yum install -y epel-release mkisofs bc curl ipmitool \
git python-pip python-devel figlet \
libxslt-devel libxml2-devel libvirt-devel \
qemu qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer \
guestfish libguestfs-tools virt-top mysql-devel \
openssl-devel libffi libffi-devel python-cffi

RUN yum install -y python-pip

RUN yum install -y tar

RUN tar -zcvf env_rel7_rpm.tar.gz /rpm

RUN mkdir -p /home/pip

RUN pip install --upgrade markupsafe virtualenv netaddr pbr oslo.config Cheetah ansible -d /home/pip/

RUN tar -zcvf env_rel7_pip.tar.gz /home/pip

RUN mkdir -p /home/tmp

RUN cp *.tar.gz /home/tmp

RUN chmod +x /cp_env.sh

CMD ["/cp_env.sh"]
