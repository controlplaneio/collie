#!/bin/bash


for FILE in "${1%/}"/* ; do
  filename=$(basename -- "$FILE")
  uuid="${filename%.*}"
  description=$(yq -r " .\"component-definition\".components[].\"control-implementations\"[].\"implemented-requirements\"[] | select(.uuid == \"$uuid\") | .description" "$2" | head -n1)
  arrIN=(${description//" "/ })
  yq ".spec.validationFailureAction |= \"enforce\"" "$FILE" > Policies/"file2".yaml
  yq ".metadata.name |= \"${arrIN[0]}\""  "Policies/file2.yaml" > Policies/"${arrIN[0]}".yaml
  rm -f Policies/file2.yaml
done
 