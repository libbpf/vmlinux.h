#!/bin/bash

set -eux

sudo apt install -y curl jq tar xz-utils

url=$(curl -s https://www.kernel.org/releases.json \
        | jq -r '.releases[] | select(.moniker == "mainline") | .source')

curl -LO "$url"
tar -xf $(basename "$url")

dir=$(basename "$url" | sed 's/\.tar\.[gx]z$//')
mv $dir linux

rm $(basename "$url")
