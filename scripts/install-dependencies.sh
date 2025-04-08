#!/bin/bash

set -eu

# Assume Ubuntu/Debian x86_64

sudo apt update -y
DEBIAN_FRONTEND=noninteractive sudo -E apt install -y tzdata
sudo apt install -y bc bison build-essential elfutils flex libdw-dev libelf-dev make ncurses-dev python3-docutils zstd

