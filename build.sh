#!/bin/bash -xe

##############################################################################
#############################      CONFIG       ##############################
##############################################################################

DOWNLOADS_DIR=~/Downloads
DOCUMENTS_DIR=~/Documents
SDK_URL='https://www.nxp.com/lgfiles/sdk'
BSP_VERSION='ls1028a_bsp_03'
APP_COMPONENTS='app_components_LS_arm64.tgz'
BOOT_PARTITION='bootpartition_LS_arm64_lts_4.14.tgz'
ARM_MODULES='lib_modules_LS_arm64_4.14.47.tgz'
TARGET_MACHINE='ls1028aqds'

##############################################################################
#############################       RUN        ###############################
##############################################################################

APP_COMPONENTS_DIR='app_components'
BOOT_PARTITION_DIR='boot_partition'
ARM_MODULES_DIR='arm_modules'
FLEXBUILD_PATH=$DOCUMENTS_DIR/flexbuild
ROOT_DIR=$(git rev-parse --show-toplevel)

make_dir () {
  if [ -d $1 ]; then
    rm -r $1
  fi
  mkdir $1
}

update_dependency () {
    local install_dir=$DOCUMENTS_DIR/$2
    if [ ! -e $DOWNLOADS_DIR/$1 ] || [ $(ls $install_dir | wc -l) -eq 0 ]; then
        wget $SDK_URL/$BSP_VERSION/$1 -P $DOWNLOADS_DIR
        make_dir $install_dir
        tar -xvf $DOWNLOADS_DIR/$1 -C $install_dir
    fi
}

install_cross_compiler () {
    local a=0
    local b=0
    if [ $# -gt 0 ] && [[ $1  == "-install_cross" ]]; then a=1; fi
    if [ ! -d $FLEXBUILD_PATH ] || [ $(ls $FLEXBUILD_PATH | wc -l) -eq "0" ]; then b=1; fi
    if [[ $a || $b ]]; then
        make_dir $FLEXBUILD_PATH
        tar -xvf $(find $ROOT_DIR -name '*.tgz') -C $FLEXBUILD_PATH
    fi
}

build () {
    pushd "${FLEXBUILD_PATH}/$(ls ${FLEXBUILD_PATH})"
    export FBDIR=$(pwd)
    export PATH="$FBDIR:$FBDIR/tools:$PATH"
    ./tools/flex-builder -i mkrfs -a arm64 -m $TARGET_MACHINE
    ln -s $DOCUMENTS_DIR/$APP_COMPONENTS_DIR build/apps
    ln -s $DOCUMENTS_DIR/$ARM_MODULES_DIR build/rfs/rootfs_ubuntu_bionic_LS_arm64/lib/modules
    ./tools/flex-builder -i merge-component -a arm64
    ./tools/flex-builder -i compressrfs -a arm64
    popd
}

update_dependency $APP_COMPONENTS $APP_COMPONENTS_DIR
update_dependency $BOOT_PARTITION $BOOT_PARTITION_DIR
update_dependency $ARM_MODULES $ARM_MODULES_DIR
install_cross_compiler
# build

