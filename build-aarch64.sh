#!/bin/bash

TOOLCHAIN=/opt/toolchains/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu
TOOLCHAIN_BIN=${TOOLCHAIN}/bin
export PATH=${TOOLCHAIN_BIN}:${PATH}

ARCH=arm64
BOARD=virt
COMPILER=aarch64-linux-gnu-
NPROC=16

KERNEL_DIR=./linux-3.10.14

select_build_mode() {
    echo "Please select build mode :"
    echo "    1 : build"
    echo "    2 : menuconfig"
    echo "    3 : clean"

    echo -e ">>> \c"
    while true
    do
        read mode
        if echo $mode | grep -q '[^0-9]'; then
            echo " Input error"
        elif [ $mode -lt 1 -o $mode -gt 3 ]; then
            echo " Input error"
        else
            return $mode
            break
        fi
    done
}

build_kernel() {
    cd ${KERNEL_DIR} 
    if test $1 -eq 1; then
        make ARCH=${ARCH} CROSS_COMPILE=${COMPILER} Image -j${NPROC}
        cp ./arch/${ARCH}/boot/zImage ../zImage-${ARCH}-${BOARD}

    elif test $1 -eq 2; then
        make ARCH=${ARCH} menuconfig

    elif test $1 -eq 3; then
        make distclean

    fi
    cd ..
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
    cd ./dev
    sudo mknod -m 666 tty1 c 4 1
    sudo mknod -m 666 tty2 c 4 2
    sudo mknod -m 666 tty3 c 4 3
    sudo mknod -m 666 tty4 c 4 4
    sudo mknod -m 666 ttyAMA0 c 204 64 
    sudo mknod -m 666 mmcblock0 b 179 0 
    sudo mknod -m 666 console c 5 1
    sudo mknod -m 666 null c 1 3
    cd ..

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
    popd
}

build_rootfs_img() {
    # rm -f ./rootfs.img
    # mkfs.cramfs ./rootfs ./rootfs.img
    rm -f disk.img
    qemu-img create -f raw disk.img 512M
    mkfs -t ext4 ./disk.img
    sudo mount -o loop ./disk.img  /mnt
    sudo cp -r rootfs/* /mnt
    sudo umount /mnt
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


