#!/bin/bash
set -ex

SCRIPT_DIR=`cd ${BASH_SOURCE[0]%/*};pwd`
COMPASS_DIR=${SCRIPT_DIR}
WORK_DIR=$SCRIPT_DIR/work/building

source $SCRIPT_DIR/build/build.conf

mkdir -p $WORK_DIR

cd $WORK_DIR

function prepare_env()
{
    set +e
    for i in createrepo genisoimage curl; do
        sudo $i --version >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            sudo apt-get install $i -y
        fi
    done
    set -e

    if [[ ! -d $CACHE_DIR ]]; then
        mkdir -p $CACHE_DIR
    fi
}

function download_git()
{
    if [[ -d $CACHE_DIR/${1%.*} ]]; then
       if [[  -d $CACHE_DIR/${1%.*}/.git ]]; then

            cd $CACHE_DIR/${1%.*}

            git fetch origin master
            git checkout origin/master

            cd -

            return
        fi

        sudo rm -rf $CACHE_DIR/${1%.*}
    fi

    git clone $2 $CACHE_DIR/`basename $i | sed 's/.git//g'`
}

function download_url()
{
    sudo rm -f $CACHE_DIR/$1.md5
    curl --connect-timeout 10 -o $CACHE_DIR/$1.md5 $2.md5
    if [[ -f $CACHE_DIR/$1 ]]; then
        local_md5=`md5sum $CACHE_DIR/$1 | cut -d ' ' -f 1`
        repo_md5=`cat $CACHE_DIR/$1.md5 | cut -d ' ' -f 1`
        if [[ $local_md5 == $repo_md5 ]]; then
            return
        fi
    fi

    curl --connect-timeout 10 -o $CACHE_DIR/$1 $2
}

function download_local()
{
    cp $2 $CACHE_DIR/ -rf
}

function download_packages()
{
     for i in $CENTOS_BASE $COMPASS_CORE $COMPASS_WEB $COMPASS_INSTALL $TRUSTY_JUNO_PPA $UBUNTU_ISO \
              $CENTOS_ISO $CENTOS7_JUNO_PPA $LOADERS $CIRROS $APP_PACKAGE $COMPASS_PKG $PIP_REPO $ANSIBLE_MODULE; do
         name=`basename $i`
         if [[ ${name##*.} == git ]]; then
             download_git  $name $i
         elif [[ "https?" =~ ${i%%:*} ]]; then
             download_url  $name $i
         else
             download_local $name $i
         fi
     done

     git fetch
     git checkout origin/master -- $COMPASS_DIR/deploy/adapters
}

function copy_file()
{
    new=$1

    # main process
    sudo mkdir -p $new/repos $new/compass $new/bootstrap $new/pip $new/guestimg $new/app_packages $new/ansible

    sudo cp -rf $SCRIPT_DIR/util/ks.cfg $new/isolinux/ks.cfg

    sudo rm -rf $new/.rr_moved

    for i in $TRUSTY_JUNO_PPA $UBUNTU_ISO $CENTOS_ISO $CENTOS7_JUNO_PPA; do
        sudo cp $CACHE_DIR/`basename $i` $new/repos/ -rf
    done

    sudo cp $CACHE_DIR/`basename $LOADERS` $new/ -rf || exit 1
    sudo cp $CACHE_DIR/`basename $CIRROS` $new/guestimg/ -rf || exit 1
    sudo cp $CACHE_DIR/`basename $APP_PACKAGE` $new/app_packages/ -rf || exit 1
    sudo cp $CACHE_DIR/`basename $ANSIBLE_MODULE | sed 's/.git//g'`  $new/ansible/ -rf || exit 1

    for i in $COMPASS_CORE $COMPASS_INSTALL $COMPASS_WEB; do
        sudo cp $CACHE_DIR/`basename $i | sed 's/.git//g'` $new/compass/ -rf
    done

    sudo cp $COMPASS_DIR/deploy/adapters $new/compass/compass-adapters -rf

    sudo tar -zxvf $CACHE_DIR/pip.tar.gz -C $new/

    find $new/compass -name ".git" |xargs sudo rm -rf
}

function rebuild_ppa()
{
    name=`basename $COMPASS_PKG`
    sudo rm -rf ${name%%.*} $name
    sudo cp $CACHE_DIR/$name $WORK_DIR
    sudo cp $SCRIPT_DIR/build/os/centos/comps.xml $WORK_DIR
    sudo tar -zxvf $name
    sudo cp ${name%%.*}/*.rpm $1/Packages -f
    sudo rm -rf $1/repodata/*
    sudo createrepo -g $WORK_DIR/comps.xml $1
}

function make_iso()
{
    download_packages
    name=`basename $CENTOS_BASE`
    sudo cp  $CACHE_DIR/$name ./ -f
    # mount base iso
    sudo mkdir -p base new
    sudo mount -o loop $name base
    cd base;find .|sudo cpio -pd ../new ;cd -
    sudo umount base
    sudo chmod 755 ./new -R

    copy_file new
    rebuild_ppa new

    sudo mkisofs -quiet -r -J -R -b isolinux/isolinux.bin \
                 -no-emul-boot -boot-load-size 4 \
                 -boot-info-table -hide-rr-moved \
                 -x "lost+found:" \
                 -o compass.iso new/

    md5sum compass.iso > compass.iso.md5

    # delete tmp file
    sudo rm -rf new base $name
}

function process_param()
{
    TEMP=`getopt -o c:d:f: --long iso-dir:,iso-name:,cache-dir: -n 'build.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    while :; do
        case "$1" in
            -d|--iso-dir) export ISO_DIR=$2; shift 2;;
            -f|--iso-name) export ISO_NAME=$2; shift 2;;
            -c|--cache-dir) export CACHE_DIR=$2; shift 2;;
            --) shift; break;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    export CACHE_DIR=${CACHE_DIR:-$WORK_DIR/cache}
    export ISO_DIR=${ISO_DIR:-$WORK_DIR}
    export ISO_NAME=${ISO_NAME:-"compass.iso"}
}

function copy_iso()
{
   if [[ $ISO_DIR/$ISO_NAME == $WORK_DIR/compass.iso ]]; then
      return
   fi

   cp $WORK_DIR/compass.iso $ISO_DIR/$ISO_NAME -f
}

process_param $*
prepare_env
make_iso
copy_iso
