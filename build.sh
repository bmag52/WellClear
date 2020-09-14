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
DAIDALUS_DIR=/home/vagrant/Wellclear/DAIDALUS/C++
FLEXBUILD_PATH=$DOCUMENTS_DIR/flexbuild
ROOT_DIR=$(git rev-parse --show-toplevel)
ARGS=$@

check_args () {
    for arg in $ARGS; do
        if [ $arg == $1 ]; then
            return 0
        fi
    done
    return 1
}

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
    if check_args "-install_cross"; then a=1; fi
    if [ ! -d $FLEXBUILD_PATH ] || [ $(ls $FLEXBUILD_PATH | wc -l) -eq "0" ]; then b=1; fi
    if [ $a -eq "1"  ] || [ $b -eq "1" ]; then
        make_dir $FLEXBUILD_PATH
        tar -xvf $(find $ROOT_DIR -name '*.tgz') -C $FLEXBUILD_PATH
    fi
}

build_bsp () {
    if check_args "-build_bsp"; then
        local flexbuild_dir="${FLEXBUILD_PATH}/$(ls ${FLEXBUILD_PATH})"
        export FBDIR=$flexbuild_dir
        export PATH="$FBDIR:$FBDIR/tools:$PATH"
        pushd $flexbuild_dir
        ./tools/flex-builder -i mkrfs -a arm64 -m $TARGET_MACHINE
        ln -s $DOCUMENTS_DIR/$APP_COMPONENTS_DIR build/apps
        ln -s $DOCUMENTS_DIR/$ARM_MODULES_DIR build/rfs/$(ls build/rfs)/lib/modules
        ./tools/flex-builder -i merge-component -a arm64
        popd
    fi
}

build_daidalus () {
    if check_args "-build_daidalus"; then
        pushd $DAIDALUS_DIR
        make lib -j 8
        make all -j 8
        popd
    fi
}

package_bsp () {
    if check_args "-package_bsp"; then
        local flexbuild_dir="${FLEXBUILD_PATH}/$(ls ${FLEXBUILD_PATH})"
        local usr_dir=$flexbuild_dir/build/rfs/$(ls $flexbuild_dir/build/rfs)/home/user
        export FBDIR=$flexbuild_dir
        export PATH="$FBDIR:$FBDIR/tools:$PATH"
        pushd $flexbuild_dir
        cp $DAIDALUS_DIR/Daidalus* $usr_dir
        cp -r $DAIDALUS_DIR/lib $usr_dir
        ./tools/flex-builder -i packrfs -a arm64
        popd
    fi
}

update_dependency $APP_COMPONENTS $APP_COMPONENTS_DIR
update_dependency $BOOT_PARTITION $BOOT_PARTITION_DIR
update_dependency $ARM_MODULES $ARM_MODULES_DIR
install_cross_compiler
build_bsp
build_daidalus
package_bsp

