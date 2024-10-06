#!/bin/bash

qemu-system-arm -M vexpress-a9 \
                -kernel ./zImage-arm-vexpress-a9 \
                -dtb ./vexpress-v2p-ca9.dtb \
                -m 512M \
                -serial mon:stdio \
                -append "root=/dev/ram rdinit=sbin/init console=ttyAMA0,38400"  \
                -initrd rootfs.img \
                -nographic 
