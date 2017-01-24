FROM ubuntu:16.04
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./code_url.conf /code_url.conf

RUN chmod +x code_url.conf

ADD ./make_pip.sh /make_pip.sh

RUN chmod +x make_pip.sh

ADD ./make_pip_wheel.sh /make_pip_wheel.sh

RUN chmod +x make_pip_wheel.sh

ADD ./cp_pip.sh /cp_pip.sh

RUN chmod +x cp_pip.sh

RUN apt-get update

RUN apt-get install -y git python-pip

RUN apt-get install -y libssl-dev libffi-dev

RUN mkdir -p /home/tmp

RUN mkdir -p /pip-openstack

RUN /make_pip.sh

RUN /make_pip_wheel.sh

RUN tar -zcvf pip-openstack.tar.gz /pip-openstack

CMD ["/cp_pip.sh"]
