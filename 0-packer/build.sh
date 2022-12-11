#!/bin/bash

set -euo pipefail

export PACKER_LOG_PATH="/tmp/packer.log"
export PACKER_LOG=10

butane --pretty --strict config/installer.bu > config/installer.ign
butane --pretty --strict config/template.bu > config/template.ign

packer build .

