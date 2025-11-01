#!/bin/bash

if [ ! -e .env ]; then
    echo "No .env, update env first !!!"
    exit
else
    source .env
fi


if [ ${FIRM_VERSION} = "firm_2.6.24" ]; then
    echo "No supported !!!"
elif [ ${FIRM_VERSION} = "firm_3.10.14" ]; then
    qemu-system-arm -M vexpress-a9 \
                    -kernel ${OUT_DIR}/zImage-arm-vexpress-a9 \
                    -dtb ${OUT_DIR}/vexpress-v2p-ca9.dtb \
                    -m 512M \
                    -serial mon:stdio \
                    -append "root=/dev/ram rdinit=sbin/init console=ttyAMA0,38400"  \
                    -initrd ${OUT_DIR}/rootfs.img \
                    -nographic 
else
    echo "Unsupported firm version: ${FIRM_VERSION}"
fi
