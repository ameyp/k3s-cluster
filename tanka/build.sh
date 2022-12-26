#!/bin/bash

set -euo pipefail

rm -rf manifests/*

tk export manifests/infrastructure/controllers infrastructure/controllers
tk export manifests/infrastructure/configs/clusterissuers infrastructure/configs/clusterissuers
tk export manifests/infrastructure/configs/certs infrastructure/configs/certs
tk export manifests/infrastructure/configs/metallb infrastructure/configs/metallb
tk export manifests/infrastructure/configs/traefik infrastructure/configs/traefik
