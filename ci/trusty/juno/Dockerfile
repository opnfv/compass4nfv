FROM ubuntu:14.04.3
MAINTAINER Chigang(Justin) <chigang@huawei.com>

# TODO: Is there some easy way to get the fastest/closest mirror?
RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list

#RUN apt-get update

RUN rm -f /etc/apt/apt.conf.d/docker-clean
ADD ./install_packages.sh /tmp/chigang/
RUN chmod +x /tmp/chigang/install_packages.sh
RUN /tmp/chigang/install_packages.sh

ADD ./cp_repo.sh /tmp/chigang/
RUN chmod +x /tmp/chigang/cp_repo.sh
RUN mkdir /result

CMD ["/tmp/chigang/cp_repo.sh"]
#VOLUME /tmp/chigang
