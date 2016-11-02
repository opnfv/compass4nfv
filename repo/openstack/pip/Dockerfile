FROM ubuntu:14.04.3
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./code_url.conf /code_url.conf

RUN chmod +x code_url.conf

ADD ./make_pip.sh /make_pip.sh

RUN chmod +x make_pip.sh

ADD ./cp_pip.sh /cp_pip.sh

RUN chmod +x cp_pip.sh

RUN apt-get update

RUN apt-get install -y git python-setuptools

RUN easy_install -U pip

RUN mkdir -p /home/tmp

RUN mkdir -p openstack_pip

RUN /make_pip.sh

RUN tar -zcvf openstack_pip.tar.gz openstack_pip/

CMD ["/cp_pip.sh"]
