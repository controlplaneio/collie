#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR"/../.. && pwd)

function helm_lint() {
  helm lint "$1" -f "$1/values.secret.example.yaml"
}

for dir in "$ROOT_DIR"/**/**/resourceTemplates; do
  helm_lint "$dir"
done
