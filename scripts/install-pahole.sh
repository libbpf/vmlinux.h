#!/bin/bash

set -eux

PAHOLE_ORIGIN=${PAHOLE_ORIGIN:-https://git.kernel.org/pub/scm/devel/pahole/pahole.git}
PAHOLE_REVISION=${PAHOLE_REVISION:-next}

sudo apt -y install cmake git libdw-dev libelf-dev

WORKSPACE=$(mktemp -d -t pahole.XXXXXX)
pushd "$WORKSPACE"
git clone ${PAHOLE_ORIGIN}            \
        --branch "${PAHOLE_REVISION}" \
        --depth=1                     \
        --single-branch
cd pahole
mkdir -p build
cmake -B=build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
make -C build -j$(nproc)
sudo make -C build install
popd
rm -rf "$WORKSPACE"
