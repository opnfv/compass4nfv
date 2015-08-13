#!/bin/bash
set -ex

WORK_PATH=$(cd "$(dirname "$0")"; pwd)
REPO_PATH=${WORK_PATH}/repo
UBUNTU_TAG="trusty"
CENTOS_TAG="centos7"
OPENSTACK_TAG="juno"
DOCKER_TAG="${UBUNTU_TAG}/openstack-${OPENSTACK_TAG}"
DOCKER_FILE=${WORK_PATH}/${UBUNTU_TAG}/${OPENSTACK_TAG}/Dockerfile
DEPLOY_SCRIPT_PATH="$1"
#DEPLOY_SCRIPT_PATH="/home/chigang/code/compass4nfv/deploy/adapters/ansible/"

if [[ $UID != 0 ]]; then
    echo "You are not root user!"
    exit 1
fi

if [[ ! -d ${REPO_PATH} ]]; then
    mkdir -p ${REPO_PATH}
fi

set +e
docker info
if [[ $? != 0 ]]; then
    wget -qO- https://get.docker.com/ | sh
else
    echo "docker is already installed!"
fi
set -e

if [[ -e ${WORK_PATH}/cp_repo.sh ]]; then
    rm -f ${WORK_PATH}/cp_repo.sh
fi

cat <<EOF >${WORK_PATH}/cp_repo.sh
#!/bin/bash
set -ex
cp /*ppa.tar.gz /result
EOF

if [[ -e ${WORK_PATH}/install_packeages.sh ]]; then
    rm -f ${WORK_PATH}/install_packages.sh
fi

# generate ubuntu 14.04 ppa
apt-get install python-yaml -y
apt-get install python-cheetah -y

python gen_ins_pkg_script.py ${DEPLOY_SCRIPT_PATH} Debian Debian_juno.tmpl

#docker build -t ${DOCKER_TAG} -f ${DOCKER_FILE} .

mkdir -p ${REPO_PATH}
#docker run -t -v ${REPO_PATH}:/result ${DOCKER_TAG}

#IMAGE_ID=$(docker images|grep ${DOCKER_TAG}|awk '{print $3}')
#docker rmi -f ${IMAGE_ID}

if [[ -e ${WORK_PATH}/install_packages.sh ]]; then
    rm -f ${WORK_PATH}/install_packages.sh
fi

# generate centos 7.1 ppa 
python gen_ins_pkg_script.py ${DEPLOY_SCRIPT_PATH} RedHat RedHat_juno.tmpl

DOCKER_TAG="${CENTOS_TAG}/openstack-${OPENSTACK_TAG}"
DOCKER_FILE=${WORK_PATH}/${CENTOS_TAG}/${OPENSTACK_TAG}/Dockerfile

docker build -t ${DOCKER_TAG} -f ${DOCKER_FILE} .

mkdir -p ${REPO_PATH}
docker run -t -v ${REPO_PATH}:/result ${DOCKER_TAG}

if [[ -e ${WORK_PATH}/install_packages.sh ]]; then
    rm -f ${WORK_PATH}/install_packages.sh
fi

if [[ -e ${WORK_PATH}/cp_repo.sh ]]; then
    rm -f ${WORK_PATH}/cp_repo.sh
fi

