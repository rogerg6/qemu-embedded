#!/bin/bash

build_3.10.14_kernel() {
    # uImage
    echo ${KERNEL_CFG}
    echo ${KERNEL_DIR}
    echo $PATH
    make -C ${KERNEL_DIR} ARCH=${ARCH} CROSS_COMPILE=${COMPILER} LOADADDR=0x60003000 uImage vexpress-v2p-ca9.dtb -j${NPROC}

    cp ${KERNEL_DIR}/arch/${ARCH}/boot/zImage ${OUT_DIR}/
    cp ${KERNEL_DIR}/arch/${ARCH}/boot/dts/vexpress-v2p-ca9.dtb ${OUT_DIR}
    log_info "zImage and dtb is generated in: ${OUT_DIR}"
    exit

    # modules
    rm -rf ${ROOTFS_DIR}/home/*
    make -C ${TOP_DIR}/drivers-demo/platform ARCH=${ARCH} CROSS_COMPILE=${COMPILER}
    cp ./drivers-demo/platform/*.ko ${ROOTFS_DIR}/home

    # led
    make -C ${TOP_DIR}/drivers-demo/char/led ARCH=${ARCH} CROSS_COMPILE=${COMPILER}
    cp ./drivers-demo/char/led/led_drv.ko ${ROOTFS_DIR}/home
    cp ./drivers-demo/char/led/chip_gpio_ops.ko ${ROOTFS_DIR}/home
    cp ./drivers-demo/char/led/led_drv_test ${ROOTFS_DIR}/home
    # button
    make -C ${TOP_DIR}/drivers-demo/char/button ARCH=${ARCH} CROSS_COMPILE=${COMPILER}
    cp ./drivers-demo/char/button/button_drv.ko ${ROOTFS_DIR}/home
    cp ./drivers-demo/char/button/board_xxx.ko  ${ROOTFS_DIR}/home
    cp ./drivers-demo/char/button/button_drv_test  ${ROOTFS_DIR}/home
}

build_3.10.14_rootfs_dir() {
    rm -rf ${ROOTFS_DIR}
    mkdir -p ${ROOTFS_DIR}
    pushd ${ROOTFS_DIR}

    # busybox
    cp -r ${BUSYBOX_DIR}/_install/* .
    # /usr
    mkdir -p ./usr/lib
    cp -rL ${TOOLCHAIN}/arm-linux-gnueabihf/libc/usr/lib/* ./usr/lib

    # /lib
    mkdir ./lib
    cp -rL ${TOOLCHAIN}/arm-linux-gnueabihf/libc/lib/* ./lib
    rm libstdc++.*
    rm -rf debug

    arm-linux-gnueabihf-strip ./lib/*
    arm-linux-gnueabihf-strip ./usr/lib/*
    
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

build_3.10.14_rootfs_img() {
    rm -f ${OUT_DIR}/rootfs.img
    mkfs.cramfs ${ROOTFS_DIR} ${OUT_DIR}/rootfs.img
    log_info "rootfs.img is generated in ${OUT_DIR} !"
}

build_3.10.14_rootfs() {
    echo "Please select build rootfs.target :"
    echo "    1 : rootfs directory"
    echo "    2 : rootfs.img"

    echo -e ">>> \c"
    while true
    do
        read choice
        if echo $choice | grep -q '[^0-9]'; then
            log_err " Input error"
        elif [ $choice -lt 1 -o $choice -gt 2 ]; then
            log_err " Input error"
        else
            break
        fi
    done    
    if [ $choice -eq 1 ]; then
        build_3.10.14_rootfs_dir
    elif [ $choice -eq 2 ]; then
        build_3.10.14_rootfs_img
    fi 
}

