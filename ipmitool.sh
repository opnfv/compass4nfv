source ./util/log.sh
for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.154 -U root -P Huawei12#$ chassis power on >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "172.16.130.154 power on fail"
        exit 1
    fi
done
sleep 1

if [[ "$DEPLOY_RECOVERY"  != "true" ]]; then
    for i in {1..5}; do
        if ipmitool -I lanplus -H 172.16.130.154 -U root -P Huawei12#$ chassis bootdev pxe >/dev/null 2>&1
        then
            break
        elif [[ i -lt 5 ]]
        then
            sleep 1
        else
            log_error "set 172.16.130.154 pxe fail"
            exit 1
        fi
    done
    sleep 1
fi

for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.154 -U root -P Huawei12#$ chassis power reset >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "reset 172.16.130.154 fail"
        exit 1
    fi
done
log_info "set pxe and reset 172.16.130.154 successsully"
sleep 1
for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.156 -U root -P Huawei12#$ chassis power on >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "172.16.130.156 power on fail"
        exit 1
    fi
done
sleep 1

if [[ "$DEPLOY_RECOVERY"  != "true" ]]; then
    for i in {1..5}; do
        if ipmitool -I lanplus -H 172.16.130.156 -U root -P Huawei12#$ chassis bootdev pxe >/dev/null 2>&1
        then
            break
        elif [[ i -lt 5 ]]
        then
            sleep 1
        else
            log_error "set 172.16.130.156 pxe fail"
            exit 1
        fi
    done
    sleep 1
fi

for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.156 -U root -P Huawei12#$ chassis power reset >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "reset 172.16.130.156 fail"
        exit 1
    fi
done
log_info "set pxe and reset 172.16.130.156 successsully"
sleep 1
for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.157 -U root -P Huawei12#$ chassis power on >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "172.16.130.157 power on fail"
        exit 1
    fi
done
sleep 1

if [[ "$DEPLOY_RECOVERY"  != "true" ]]; then
    for i in {1..5}; do
        if ipmitool -I lanplus -H 172.16.130.157 -U root -P Huawei12#$ chassis bootdev pxe >/dev/null 2>&1
        then
            break
        elif [[ i -lt 5 ]]
        then
            sleep 1
        else
            log_error "set 172.16.130.157 pxe fail"
            exit 1
        fi
    done
    sleep 1
fi

for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.157 -U root -P Huawei12#$ chassis power reset >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "reset 172.16.130.157 fail"
        exit 1
    fi
done
log_info "set pxe and reset 172.16.130.157 successsully"
sleep 1
for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.158 -U root -P Huawei12#$ chassis power on >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "172.16.130.158 power on fail"
        exit 1
    fi
done
sleep 1

if [[ "$DEPLOY_RECOVERY"  != "true" ]]; then
    for i in {1..5}; do
        if ipmitool -I lanplus -H 172.16.130.158 -U root -P Huawei12#$ chassis bootdev pxe >/dev/null 2>&1
        then
            break
        elif [[ i -lt 5 ]]
        then
            sleep 1
        else
            log_error "set 172.16.130.158 pxe fail"
            exit 1
        fi
    done
    sleep 1
fi

for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.158 -U root -P Huawei12#$ chassis power reset >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "reset 172.16.130.158 fail"
        exit 1
    fi
done
log_info "set pxe and reset 172.16.130.158 successsully"
sleep 1
for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.159 -U root -P Huawei12#$ chassis power on >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "172.16.130.159 power on fail"
        exit 1
    fi
done
sleep 1

if [[ "$DEPLOY_RECOVERY"  != "true" ]]; then
    for i in {1..5}; do
        if ipmitool -I lanplus -H 172.16.130.159 -U root -P Huawei12#$ chassis bootdev pxe >/dev/null 2>&1
        then
            break
        elif [[ i -lt 5 ]]
        then
            sleep 1
        else
            log_error "set 172.16.130.159 pxe fail"
            exit 1
        fi
    done
    sleep 1
fi

for i in {1..5}; do
    if ipmitool -I lanplus -H 172.16.130.159 -U root -P Huawei12#$ chassis power reset >/dev/null 2>&1
    then
        break
    elif [[ i -lt 5 ]]
    then
        sleep 1
    else
        log_error "reset 172.16.130.159 fail"
        exit 1
    fi
done
log_info "set pxe and reset 172.16.130.159 successsully"
sleep 1
