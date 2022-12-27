#!/bin/bash

set -euo pipefail

function jsonnet_export() {
    local MODE=$1
    local SOURCE=$2
    local DEST=$3/main.yaml

    mkdir -p $(dirname $DEST)

    echo "[$MODE] Building $SOURCE"
    jsonnet -y ${SOURCE} -J vendor -J lib --tla-code mode="\"$MODE\"" > $DEST
}

rm -rf manifests/*

for mode in test prod; do
    jsonnet_export $mode kustomizations/main.jsonnet \
                   manifests/${mode}/kustomizations

    jsonnet_export $mode infrastructure/controllers/main.jsonnet \
                   manifests/${mode}/infrastructure/controllers
    jsonnet_export $mode infrastructure/vault/main.jsonnet \
                   manifests/${mode}/infrastructure/vault
    jsonnet_export $mode infrastructure/traefik/main.jsonnet \
                   manifests/${mode}/infrastructure/traefik

    jsonnet_export $mode infrastructure/configs/clusterissuers/main.jsonnet \
                   manifests/${mode}/infrastructure/configs/clusterissuers
    jsonnet_export $mode infrastructure/configs/certs/main.jsonnet \
                   manifests/${mode}/infrastructure/configs/certs
    jsonnet_export $mode infrastructure/configs/metallb/main.jsonnet \
                   manifests/${mode}/infrastructure/configs/metallb
    jsonnet_export $mode infrastructure/configs/traefik/main.jsonnet \
                   manifests/${mode}/infrastructure/configs/traefik
    jsonnet_export $mode infrastructure/configs/vault/main.jsonnet \
                   manifests/${mode}/infrastructure/configs/vault
done

