#!/bin/bash

set -euo pipefail

function jsonnet_export() {
    local MODE=$1
    local SOURCE=$2
    local DEST=$3/main.yaml

    mkdir -p $(dirname $DEST)

    echo "[$MODE] Building $SOURCE"
    jsonnet ${SOURCE}/main.jsonnet -J vendor -J lib --tla-code mode="\"$MODE\"" > $DEST
}

rm -rf manifests/*

for mode in test prod; do
    jsonnet_export $mode infrastructure/controllers \
                   manifests/${mode}/infrastructure/controllers
    jsonnet_export $mode infrastructure/vault \
                   manifests/${mode}/infrastructure/vault
    jsonnet_export $mode infrastructure/traefik \
                   manifests/${mode}/infrastructure/traefik

    jsonnet_export $mode infrastructure/configs/clusterissuers \
                   manifests/${mode}/infrastructure/configs/clusterissuers
    jsonnet_export $mode infrastructure/configs/certs \
                   manifests/${mode}/infrastructure/configs/certs
    jsonnet_export $mode infrastructure/configs/metallb \
                   manifests/${mode}/infrastructure/configs/metallb
    jsonnet_export $mode infrastructure/configs/traefik \
                   manifests/${mode}/infrastructure/configs/traefik
    jsonnet_export $mode infrastructure/configs/vault \
                   manifests/${mode}/infrastructure/configs/vault
done

