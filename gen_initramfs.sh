#!/bin/bash

# compiling flag
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm

# variables 
build=false
rootfs=false
clean=false
build_root="${HOME}/.btmp"

setup_rootfs () {
    mkdir -p ${build_root}/rootfs
    pushd ./
    cd ${build_root}/rootfs
    pwd
    mkdir {bin,dev,etc,home,lib32,proc,sbin,sys,tmp,usr,var,run}
    mkdir usr/{bin,lib,sbin}
    mkdir var/{log,lib,run}
    mkdir var/lib/seedrng
    mkdir home/{root,eric}
    ln -s lib32 lib
    # Two device nodes are needed by Busybox
    # sudo mknod -m 666 dev/null c 1 3
    # sudo mknod -m 600 dev/console c 5 1
    # sudo mknod -m 600 dev/tty1 c 5 1
    popd
    # add init bash
    cp -rf init_resources/* ${build_root}/rootfs/etc/
    tree ${build_root}/rootfs
}

# parse arguments
if [ $# -ne 1 ]; then  
    echo "Example: gen_initramfs.sh rootfs(build, clean) "
    exit
fi

# setting internal variables
if [ $1 == "build" ]; then
    build=true
elif [ $1 == "rootfs" ]; then
    rootfs=true
elif [ $1 == "clean" ]; then
    clean=true
fi

# del all
if [ $clean == true ]; then
    rm -rf ${build_root}/rootfs busybox uRamdisk boot.scr
    exit
fi

if [ $build == true ]; then
    # 1. clean
    rm -rf ${build_root}/rootfs uRamdisk boot.scr
    #busy box
    if [ ! -d "busybox" ]; then
        git clone https://github.com/mirror/busybox.git
        cd busybox
        git checkout 1_36_stable
        cd ../
    fi
    # 2. setup layers
    setup_rootfs
    # build
    cd busybox
    make clean
    make defconfig
    # Change the install directory to be the one just created
    sed -e 's%^CONFIG_PREFIX=.*$%CONFIG_PREFIX="'"${build_root}"'/rootfs"%' -i .config
    sed -e 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' -i .config
    # Build
    make -j8
    # # Install
    make install
    cd ../
fi

if [ $rootfs == true ]; then
    if [ ! -d "${build_root}/rootfs" ]; then
        echo "Please execute 'gen_initramfs.sh build' first."
        exit
    fi
    rm -rf ${build_root}/rootfs uRamdisk boot.scr
    # setup layers
    setup_rootfs
    #
    cd busybox
    make install
    cd ../
fi

#
pushd .
cp -f boot.cmd ${build_root}
cd ${build_root}/rootfs
find . | cpio -H newc -ov --owner root:root -F ../initramfs.cpio
cd ../
gzip initramfs.cpio
mkimage -A arm -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk
rm initramfs.cpio.gz
mkimage -C none -A arm -T script -d boot.cmd boot.scr
popd
cp ${build_root}/{uRamdisk,boot.scr} ./ 
rm ${build_root}/{uRamdisk,boot.*}

echo "Finished"
