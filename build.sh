#!/bin/bash

none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"

log_info() {
    echo -e "${green}${1}${none}"
}
log_warn() {
    echo -e "${yello}${1}${none}"
}
log_err() {
    echo -e "${red}${1}${none}"
}

# env
TOP_DIR=`pwd`
FIRM_VERSION=""
UBOOT_DIR=${TOP_DIR}/uboot
UBOOT_CFG=""
KERNEL_DIR=""
KERNEL_CFG=""
ROOTFS_DIR=""
BUSYBOX_DIR=${TOP_DIR}/busybox/busybox-1.29.0
OUT_DIR=""

# arch
ARCH=arm
BOARD=vexpress-a9
COMPILER=arm-linux-gnueabihf-
NPROC=16
TOOLCHAIN=${PWD}/toolchain/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf
TOOLCHAIN_BIN=${TOOLCHAIN}/bin
export PATH=${TOOLCHAIN_BIN}:${PATH}

source ${TOP_DIR}/build/firm-3.10.14-build.sh

saveenv() { 
    echo "TOP_DIR=${TOP_DIR}"           > .env
    echo "FIRM_VERSION=${FIRM_VERSION}"  >> .env
    echo "UBOOT_DIR=${UBOOT_DIR}"       >> .env
    echo "UBOOT_CFG=${UBOOT_CFG}"       >> .env
    echo "KERNEL_DIR=${KERNEL_DIR}"     >> .env
    echo "KERNEL_CFG=${KERNEL_CFG}"     >> .env
    echo "ROOTFS_DIR=${ROOTFS_DIR}"     >> .env
    echo "OUT_DIR=${OUT_DIR}"           >> .env
    echo "PATH=${PATH}"           >> .env
} 

update_env() {
    while true
    do
        echo "Please select board:"
        echo "    1 : linux2.6.24"
        echo "    2 : linux3.10.14"

        echo -e ">>> \c"

        read config
        if echo ${config} | grep -q '[^0-9]'; then
            log_err " Input error"
        elif [ ${config} -lt 1 -o ${config} -gt 2 ]; then
            log_err " Input error"
        else
            case ${config} in
            1)
                FIRM_VERSION="firm-2.6.24"
                KERNEL_DIR=${TOP_DIR}/kernel/linux-2.6.24
                KERNEL_CFG=${KERNEL_DIR}/smb_t32vn_config
                ROOTFS_DIR=${TOP_DIR}/rootfs/
                OUT_DIR=${TOP_DIR}/out/firm-2.6.24
                ;;
            2)
                FIRM_VERSION="firm-3.10.14"
                KERNEL_DIR=${TOP_DIR}/kernel/linux-3.10.14
                KERNEL_CFG=${KERNEL_DIR}/config.arm.vexpress-a9
                ROOTFS_DIR=${TOP_DIR}/rootfs/rootfs-3.10.14
                OUT_DIR=${TOP_DIR}/out/firm-3.10.14
                ;;
            ?)
                log_err "unkonw argument"
                exit 1
                ;;
            esac
            if [ ! -d ${OUT_DIR} ]; then
                mkdir -p ${OUT_DIR}
            fi

            break
        fi
    done
} 


build_menu() {
    while true
    do

        echo "Please select build type :"
        echo "    1 : uboot"
        echo "    2 : kernel"
        echo "    3 : rootfs"
        echo "    4 : build compiledb"

        echo -e ">>> \c"

        read config
        if echo ${config} | grep -q '[^0-9]'; then
            log_err " Input error"
        elif [ ${config} -lt 1 -o ${config} -gt 4 ]; then
            log_err " Input error"
        else
            if [ ${config} -eq 1 ]; then
                build_uboot
            elif [ ${config} -eq 2 ]; then
                build_kernel
            elif [ ${config} -eq 3 ]; then
                build_roofs
            elif [ ${config} -eq 4 ]; then
                log_warn "Note: should config fisrt !!!"
                compiledb -nf -o ${TASSADAR_ENV_TOP}/../compile_commands.json -d ${UBOOT_DIR} \
                    make -C ${UBOOT_DIR} PRJ007_vn_sfcnor > /dev/null
                log_info "uboot build done."
                compiledb -n -o ${TASSADAR_ENV_TOP}/../compile_commands.json -d ${TASSADAR_ENV_KERNEL_DIR} \
                    make -C ${TASSADAR_ENV_KERNEL_DIR} > /dev/null
                log_info "kernel build done."
            else
                log_err "Type Error, please check!"
                exit 1
            fi
            break
        fi
    done
}

build_uboot() {
    rm -f ${OUT_DIR}/u-boot.bin
    echo "############################################################"
    echo "build uboot"
    echo "UBOOT_CFG:" ${UBOOT_CFG}
    echo "############################################################"

    make -C ${UBOOT_DIR} distclean
    make -C ${UBOOT_DIR} ${UBOOT_CFG} -j8
    if [ -f ${UBOOT_DIR}/u-boot-with-spl.bin ]; then
        cp ${UBOOT_DIR}/u-boot-with-spl.bin ${OUT_DIR}/u-boot.bin
        log_info "${OUT_DIR}/u-boot.bin is built"
    else
        log_err "${UBOOT_DIR}/u-boot-with-spl.bin is not found"
    fi
}

build_kernel() {
    mod_dir=${ROOTFS_DIR}/lib/modules

    # if [ ! -e ${TASSADAR_ENV_KERNEL_DIR}/.config ] || ! diff ${kernel_cfg} ${TASSADAR_ENV_KERNEL_DIR}/.config > /dev/null; then
    #     echo "Kernel config is not correct, clean it !"
    #     make -C ${TASSADAR_ENV_KERNEL_DIR} distclean
    #     cp ${kernel_cfg} ${TASSADAR_ENV_KERNEL_DIR}/.config
    # fi

    if [ ${FIRM_VERSION} = "firm-2.6.24" ]; then
        echo "no supported"
    elif [ ${FIRM_VERSION} = "firm-3.10.14" ]; then 
        build_3.10.14_kernel
    fi

}

build_roofs() {
    if [ ${FIRM_VERSION} = "firm-2.6.24" ]; then
        echo "no supported"
    elif [ ${FIRM_VERSION} = "firm-3.10.14" ]; then 
        build_3.10.14_rootfs
    fi
}


print_env() {
    if [ ! -e .env ]; then
        log_err "No .env, update env first !!!"
    fi
    color=${red}
    if [ "$1" = "new env" ]; then
        color=${green}
    fi

    echo -e "${color}################# $1 start #################\n"
    cat .env
    echo -e "\n################# $1 end   #################${none}"
}


############# main ###############

print_env "current env"
echo -en "\nchange env(Y/N): "
read choice

if [ "${choice}" = "Y" -o "${choice}" = "y" ]; then
    update_env
    saveenv
    print_env "new env"
fi

source .env
build_menu
