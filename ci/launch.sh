#set -x
WORK_DIR=$COMPASS_DIR/ci/work/deploy

mkdir -p $WORK_DIR/script

source ${COMPASS_DIR}/ci/log.sh
source ${COMPASS_DIR}/ci/deploy_parameter.sh
source $(process_default_para $*) || exit 1
source $(process_input_para $*) || exit 1
source ${COMPASS_DIR}/deploy/conf/${FLAVOR}.conf
source ${COMPASS_DIR}/deploy/conf/${TYPE}.conf
source ${COMPASS_DIR}/deploy/conf/base.conf
source ${COMPASS_DIR}/deploy/prepare.sh
source ${COMPASS_DIR}/deploy/network.sh
source ${COMPASS_DIR}/deploy/host_${TYPE}.sh
source ${COMPASS_DIR}/deploy/compass_vm.sh
source ${COMPASS_DIR}/deploy/deploy_host.sh

######################### main process
if true
then
if ! prepare_env;then
    echo "prepare_env failed"
    exit 1
fi

log_info "########## get host mac begin #############"
machines=`get_host_macs`
if [[ -z $machines ]];then
    log_error "get_host_macs failed"
    exit 1
fi

log_info "deploy host macs: $machines"
export machines

log_info "########## set up network begin #############"
if ! create_nets;then
    log_error "create_nets failed"
    exit 1
fi

if ! launch_compass;then
    log_error "launch_compass failed"
    exit 1
fi
else
# test code
export machines="'00:00:01:c9:03:34','00:00:7c:8e:1e:c6','00:00:00:ec:6f:ca','00:00:7c:7a:91:cb','00:00:0e:82:79:08'"
fi
if [[ ! -z $VIRT_NUMBER ]];then
    if ! launch_host_vms;then
        log_error "launch_host_vms failed"
        exit 1
    fi
fi
if ! deploy_host;then
    #tear_down_machines
    #tear_down_compass
    exit 1
else
    #tear_down_machines
    #tear_down_compass
    exit 0
fi
