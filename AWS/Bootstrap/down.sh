#!/usr/bin/env bash

set -eo pipefail

while getopts ":dp" o; do
  case "${o}" in
    d)
      CREATE_DEMO_RESOURCES="true"
      ;;
    p)
      KEEP_CLUSTER="true"
      ;;
    *)
      ;;
  esac
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR/cluster"
OIDC_PROVIDER="$(terraform output -raw oidc_provider)"
SUFFIX="$(terraform output -raw suffix)"

if [ "$CREATE_DEMO_RESOURCES" == "true" ] 
then
  kubectl delete --ignore-not-found=true -R --wait -f "$SCRIPT_DIR/../S3/Resources"
  kubectl delete --ignore-not-found=true -R --wait -f "$SCRIPT_DIR/../RDS/Resources"
  cd "$SCRIPT_DIR/demoResources"
  terraform destroy -auto-approve -var="suffix=$SUFFIX"
fi

cd "$SCRIPT_DIR/provider"
terraform destroy -auto-approve -var="oidc_provider=$OIDC_PROVIDER" -var="suffix=$SUFFIX"

cd "$SCRIPT_DIR/crossplane"
terraform destroy -auto-approve

if [ "$KEEP_CLUSTER" != "true" ]
then
  cd "$SCRIPT_DIR/cluster"
  terraform destroy -auto-approve
fi
