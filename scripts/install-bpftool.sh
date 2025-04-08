#!/bin/bash

set -eux

LINUX_REPO=${1:-"./linux"}

if [ ! -d "${LINUX_REPO}" ]; then
	echo "Error: Linux repo path is not found, LINUX_REPO=$LINUX_REPO"
	exit 1
fi

sudo apt install -y llvm libcap-dev libbfd-dev zlib1g-dev

cd "$LINUX_REPO/tools/bpf/bpftool"
make -j$(nproc)
sudo make install
