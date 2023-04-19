#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR"/../.. && pwd)

function generate_resources() {
  module_root=$(cd "$1"/..  && pwd)
  if [ ! -f "$module_root/resourceTemplates/values.secret.yaml" ] ; then
    cp "$module_root/resourceTemplates/values.secret.example.yaml" "$module_root/resourceTemplates/values.secret.yaml"
  fi
  helm template resource "$module_root/resourceTemplates" -f "$module_root/resourceTemplates/values.secret.yaml" --output-dir "$module_root/.tmp"
  rm -rf "$module_root/Resources"
  mkdir -p "$module_root/Resources" 
  mv "$module_root"/.tmp/resourceTemplates/templates/* "$module_root/Resources/"
  rm -rf "$module_root/.tmp"
}

for dir in "$ROOT_DIR"/**/**/resourceTemplates; do
  generate_resources "$dir"
done
