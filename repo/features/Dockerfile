FROM ubuntu:14.04.3
MAINTAINER Yifei Xue <xueyifei@huawei.com>

ADD ./cp_pkg.sh /cp_pkg.sh

ADD ./feature_run.sh /feature_run.sh

RUN mkdir run_script

ADD ./make_pkg/* /run_script/

RUN apt-get update

RUN apt-get install -y curl vim git

RUN chmod +x /feature_run.sh

RUN /feature_run.sh

RUN chmod +x /cp_pkg.sh

CMD ["/cp_pkg.sh"]
