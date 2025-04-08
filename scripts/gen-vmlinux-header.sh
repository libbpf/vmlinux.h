#!/bin/bash

usage () {
        echo "USAGE: ./gen-vmlinux-headers.sh <arch> [<linux-repo-path> <kconfig-path>]"
        exit 1
}

set -eu

source $(dirname "$0")/helpers.sh

WORKSPACE=$(pwd)
BUILD_DIR="${BUILD_DIR:-$WORKSPACE/build}"
GCC_VERSION=${GCC_VERSION:-"13"}
OUTPUT_DIR="${OUTPUT_DIR:-$WORKSPACE/vmlinux.h}"

TARGET_ARCH=$1
LINUX_REPO=${2:-$WORKSPACE/linux}
KCONFIG=${3:-}

if [ -z "${TARGET_ARCH}" ]; then
        echo "Error: Target architecture is not set"
        usage
fi

if [ ! -d "${LINUX_REPO}" ]; then
        echo "Error: Linux repo path is not found, LINUX_REPO=$LINUX_REPO"
        usage
fi

if [ ! -f "${KCONFIG}" ]; then
        KCONFIG=$(mktemp /tmp/kconfig.XXXX)
        cp $WORKSPACE/kconfigs/config.common $KCONFIG
        arch_conf="$WORKSPACE/kconfigs/config.${TARGET_ARCH}"
        if [ -f "$arch_conf" ]; then
                cat "$arch_conf" >> $KCONFIG
        fi
        echo "==== Using KCONFIG=$KCONFIG for kernel build"
        cat $KCONFIG
        echo "==== end of KCONFIG=$KCONFIG"
fi

mkdir -p "$BUILD_DIR"
LINUX_REPO=$(realpath "$LINUX_REPO")
KCONFIG=$(realpath "$KCONFIG")

# Install the cross-compiler
if [ "${TARGET_ARCH}" != "x86_64" ]; then
        compiler_id=$(arch_compiler_id "$TARGET_ARCH")
        sudo apt install -y                                    \
                "gcc-${GCC_VERSION}-${compiler_id}"            \
                "binutils-${compiler_id}"
        sudo update-alternatives --install                     \
                /usr/bin/${compiler_id}-gcc                    \
                ${compiler_id}-gcc                             \
                /usr/bin/${compiler_id}-gcc-${GCC_VERSION} 100
        sudo update-alternatives --set                         \
                ${compiler_id}-gcc                             \
                /usr/bin/${compiler_id}-gcc-${GCC_VERSION}
fi

build_arch(){
        local arch="$1"
        local kbuild_output="$(realpath $BUILD_DIR/$arch)"
        mkdir -p "$kbuild_output"
        local arch_slug=$(arch_slug "$arch")
        local compiler_id=$(arch_compiler_id "$arch")

        echo "Building $arch ($arch_slug) into $kbuild_output..."
        (
                cd "$LINUX_REPO"
                make O="$kbuild_output"                                 \
                        ARCH=$arch_slug CROSS_COMPILE="${compiler_id}-" \
                        tinyconfig
                "$LINUX_REPO/scripts/kconfig/merge_config.sh" -m        \
                        -O "$kbuild_output"                             \
                        "$kbuild_output/.config" "${KCONFIG}"
                make O="$kbuild_output"                                 \
                        ARCH=$arch_slug CROSS_COMPILE="${compiler_id}-" \
                        olddefconfig

                make O="$kbuild_output"                                 \
                        ARCH=$arch_slug CROSS_COMPILE="${compiler_id}-" \
                        -j$(nproc) all

                mkdir -p "$OUTPUT_DIR/$arch"
                bpftool btf dump file "$kbuild_output/vmlinux" format c \
                        > "$OUTPUT_DIR/$arch/vmlinux.h"
        )
}

build_arch $TARGET_ARCH
