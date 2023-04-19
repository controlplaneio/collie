#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR"/../.. && pwd)
LULA_PATH=${LULA_PATH:=$ROOT_DIR/Tools/lula/bin/lula}

function rename() {
  for FILE in "$1/.lulapolicies"/* ; do
    filename=$(basename -- "$FILE")
    uuid="${filename%.*}"
    description=$(yq -r " .\"component-definition\".components[].\"control-implementations\"[].\"implemented-requirements\"[] | select(.uuid == \"$uuid\") | .description" "$2" | head -n1)
    arrIN=(${description//" "/ })
    yq " ( .spec.validationFailureAction = \"enforce\" ) | ( .metadata.name = \"${arrIN[0]}\" )"  "$FILE" > "$1"/Policies/"${arrIN[0]}".yaml
  done
} 

for component_file in "$ROOT_DIR"/**/**/*-component-definition.yaml; do
  outpath=$(dirname "$component_file")
  $LULA_PATH generate "$component_file" -o "$outpath"/.lulapolicies
  mkdir -p "$outpath"/Policies
  rename "$outpath" "$component_file"
  rm -rf "$outpath"/.lulapolicies
done