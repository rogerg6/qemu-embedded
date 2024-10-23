#!/bin/bash

TOOLCHAIN=${PWD}/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux
TOOLCHAIN_BIN=${TOOLCHAIN}/bin
export PATH=${TOOLCHAIN_BIN}:${PATH}

ARCH=arm
BOARD=vexpress-a9
COMPILER=arm-linux-gnueabihf-
NPROC=16

KERNEL_DIR=./linux-3.10.14
KERNEL_CONFIG=.config.arm.vexpress


unset LD_PRELOAD
# export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/bear/:${LD_PRELOAD}

select_build_mode() {
    echo "Please select build mode :"
    echo "    1 : build"
    echo "    2 : build & generate compile_commands.json"
    echo "    3 : menuconfig"
    echo "    4 : clean"

    echo -e ">>> \c"
    while true
    do
        read mode
        if echo $mode | grep -q '[^0-9]'; then
            echo " Input error"
        elif [ $mode -lt 1 -o $mode -gt 4 ]; then
            echo " Input error"
        else
            return $mode
            break
        fi
    done
}

build_kernel() {
    if test $1 -le 2; then
        BEAR_CMD=""
        if test $1 -eq 2; then
            BEAR_CMD="bear"
            BEAR_CMD_APPEND="bear -a"
        fi
        # uImage
        ${BEAR_CMD} make -C ${KERNEL_DIR} ARCH=${ARCH} CROSS_COMPILE=${COMPILER} LOADADDR=0x60003000 \
            uImage vexpress-v2p-ca9.dtb -j${NPROC}
        cp ${KERNEL_DIR}/arch/${ARCH}/boot/zImage ./zImage-${ARCH}-${BOARD}
        cp ${KERNEL_DIR}/arch/${ARCH}/boot/dts/vexpress-v2p-ca9.dtb ./

        # modules
        rm -rf ./rootfs/home/*
        ${BEAR_CMD_APPEND} make -C ./mydriver-demo/platform ARCH=${ARCH} CROSS_COMPILE=${COMPILER}
        cp ./mydriver-demo/platform/*.ko ./rootfs/home

        # led
        ${BEAR_CMD_APPEND} make -C ./mydriver-demo/char/led ARCH=${ARCH} CROSS_COMPILE=${COMPILER}
        cp ./mydriver-demo/char/led/led_drv.ko ./rootfs/home
        cp ./mydriver-demo/char/led/chip_gpio_ops.ko ./rootfs/home
        cp ./mydriver-demo/char/led/led_drv_test ./rootfs/home
        # button
        ${BEAR_CMD_APPEND} make -C ./mydriver-demo/char/button ARCH=${ARCH} CROSS_COMPILE=${COMPILER}
        cp ./mydriver-demo/char/button/button_drv.ko ./rootfs/home
        cp ./mydriver-demo/char/button/board_xxx.ko  ./rootfs/home
        cp ./mydriver-demo/char/button/button_drv_test  ./rootfs/home

    elif test $1 -eq 3; then
        make -C ${KERNEL_DIR} ARCH=${ARCH} menuconfig

    elif test $1 -eq 4; then
        make -C ${KERNEL_DIR} distclean
        make -C ./mydriver-demo ARCH=${ARCH} CROSS_COMPILE=${COMPILER} clean
        cp ${KERNEL_DIR}/${KERNEL_CONFIG} ${KERNEL_DIR}/.config

    fi
}

build_rootfs_dir() {
    rm -rf rootfs
    cp -r busybox-1.29.0/_install ./rootfs
    pushd ./rootfs

    # /usr
    mkdir -p ./usr/lib

    # /lib
    mkdir ./lib
    cp -rL ${TOOLCHAIN}/arm-linux-gnueabihf/libc/lib/arm-linux-gnueabihf/* ./lib
    cp -rL ${TOOLCHAIN}/arm-linux-gnueabihf/libc/usr/lib/arm-linux-gnueabihf/* ./usr/lib

    # /dev
    mkdir ./dev
    # cd ./dev
    # sudo mknod -m 666 tty1 c 4 1
    # sudo mknod -m 666 tty2 c 4 2
    # sudo mknod -m 666 tty3 c 4 3
    # sudo mknod -m 666 tty4 c 4 4
    # sudo mknod -m 666 ttyAMA0 c 204 64 
    # sudo mknod -m 666 console c 5 1
    # sudo mknod -m 666 null c 1 3
    # cd ..

    # /etc
    mkdir etc
    cd etc

    echo "#/etc/inittab
::sysinit:/etc/init.d/rcS
ttyAMA0::askfirst:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::restart:/sbin/init" > inittab

    echo "#device		mount-point		type		option		dump	fsckorder
proc		/proc			proc		defaults	0		0
sysfs		/sys			sysfs		defaults	0		0
tmpfs		/tmp			tmpfs		defaults	0		0
none		/dev			devtmpfs    defaults	0		0
tmpfs		/var			tmpfs		defaults	0		0" > fstab

    touch profile
    touch passwd
    touch group
    touch shadow
    touch resolv.conf
    touch mdev.conf
    touch inetd.conf
    mkdir rc.d
    mkdir sysconfig
    touch sysconfig/HOSTNAME
    mkdir init.d
    echo " #!/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
runlevel=S
prevlevel=N
umask 022
export PATH runlevel prevlevel
mount -a
/bin/hostname -F /etc/sysconfig/HOSTNAME" > init.d/rcS
    chmod +x init.d/rcS
    cd ..

    # other directories
    mkdir proc mnt tmp sys root var opt home
    mkdir -p lib/3.10.14/
    popd
}

build_rootfs_img() {
    rm -f ./rootfs.img
    mkfs.cramfs ./rootfs ./rootfs.img
}

build_rootfs() {
    echo "Please select build rootfs.target :"
    echo "    1 : rootfs directory"
    echo "    2 : rootfs.img"

    echo -e ">>> \c"
    while true
    do
        read choice
        if echo $choice | grep -q '[^0-9]'; then
            echo " Input error"
        elif [ $choice -lt 1 -o $config -gt 2 ]; then
            echo " Input error"
        else
            break
        fi
    done    
    if test $choice -eq 1; then
        build_rootfs_dir
    elif test $choice -eq 2; then
        build_rootfs_img
    fi 
}


# main script

while true
do
    echo "Please select build target :"
    echo "    1 : kernel"
    echo "    2 : rootfs"

    echo -e ">>> \c"

    read config
    if echo $config | grep -q '[^0-9]'; then
        echo " Input error"
    elif [ $config -lt 1 -o $config -gt 2 ]; then
        echo " Input error"
    else
        if test $config -eq 1; then
            select_build_mode
            build_kernel $?
        elif test $config -eq 2; then
            build_rootfs
        else
            echo "Type Error, please check!"
            exit 1
        fi
        break
    fi
done


