#!/bin/bash

arch_slug() {
        printf "$arch"                                  \
        | sed 's/x86_64/x86/'                           \
        | sed 's/i686/x86/'                             \
        | sed 's/aarch64/arm64/'                        \
        | sed 's/ppc64le/powerpc/'                      \
        | sed 's/riscv64/riscv/'                        \
        | sed 's/s390x/s390/'                           \
        | sed 's/loongarch64/loongarch/'
}

arch_compiler_id() {
        local arch="$1"
        case "$arch" in
                arm)
                        echo "arm-linux-gnueabi"
                        ;;
                ppc64le)
                        echo "powerpc64le-linux-gnu"
                        ;;
                *)
                        echo "${arch}-linux-gnu"
                        ;;
        esac
}

