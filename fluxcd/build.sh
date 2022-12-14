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

function jsonnet_export_multi() {
    local MODE=$1
    local SOURCE=$2
    local DEST=$3

    mkdir -p $(dirname $DEST)

    echo "[$MODE] Building $SOURCE"
    jsonnet -y ${SOURCE} -J vendor -J lib -c --tla-code mode="\"$MODE\"" -m $DEST
}

rm -rf manifests/*

for mode in test prod; do
    jsonnet_export $mode kustomizations/main.jsonnet \
                   manifests/${mode}/kustomizations

    jsonnet_export $mode infrastructure/controllers/main.jsonnet \
                   manifests/${mode}/infrastructure/controllers

    # Vault
    jsonnet_export $mode infrastructure/vault/main.jsonnet \
                   manifests/${mode}/infrastructure/vault
    jsonnet_export_multi $mode infrastructure/vault-config-operator/main.jsonnet \
                         manifests/${mode}/infrastructure/vault-config-operator

    # Traefik
    jsonnet_export $mode infrastructure/traefik/main.jsonnet \
                   manifests/${mode}/infrastructure/traefik

    # Databases
    jsonnet_export_multi $mode infrastructure/databases/main.jsonnet \
                         manifests/${mode}/infrastructure/databases

    for c in $(ls infrastructure/configs); do
        jsonnet_export $mode infrastructure/configs/$c/main.jsonnet \
                       manifests/${mode}/infrastructure/configs/$c
    done

    jsonnet_export_multi $mode infrastructure/vault-data/main.jsonnet \
                         manifests/${mode}/infrastructure/vault-data
done

