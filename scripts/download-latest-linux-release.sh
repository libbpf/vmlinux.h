#!/bin/bash

set -eux

sudo apt install -y curl jq tar xz-utils

# pick the first stable release, it's usually the newest
url=$(curl -s https://www.kernel.org/releases.json \
        | jq -r '[.releases[] | select(.moniker == "stable")][0].source')

curl -LO "$url"
tar -xf $(basename "$url")

dir=$(basename "$url" | sed 's/\.tar\.[gx]z$//')
mv $dir linux

rm $(basename "$url")
