#!/usr/bin/env bash

set -evo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR/cluster"
terraform init

cd "$SCRIPT_DIR/helm"
terraform init

cd "$SCRIPT_DIR/provider"
terraform init

cd "$SCRIPT_DIR/demoResources"
terraform init
