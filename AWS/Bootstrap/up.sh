#!/usr/bin/env bash

set -eo pipefail

while getopts ":d" o; do
  case "${o}" in
    d)
      CREATE_DEMO_RESOURCES="true"
      ;;
    *)
      ;;
  esac
done
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR/cluster"
terraform apply -auto-approve
aws eks update-kubeconfig --name "$(terraform output -raw cluster_id)" --alias collie --profile "$(terraform output -raw aws_profile)" --region "$(terraform output -raw aws_region)"
OIDC_PROVIDER="$(terraform output -raw oidc_provider)"
SUFFIX="$(terraform output -raw suffix)"

cd "$SCRIPT_DIR/helm"
terraform apply -auto-approve

cd "$SCRIPT_DIR/provider"
terraform apply -auto-approve -var="oidc_provider=$OIDC_PROVIDER" -var="suffix=$SUFFIX"

if [ "$CREATE_DEMO_RESOURCES" == "true" ] 
then
  cd "$SCRIPT_DIR/demoResources"
  terraform apply -auto-approve -var="suffix=$SUFFIX"

  if [ ! -f "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml" ] ; then
    cp "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.example.yaml" "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml"
  fi

  if [ ! -f "$SCRIPT_DIR/../RDS/resourceTemplates/values.secret.yaml" ] ; then
    cp "$SCRIPT_DIR/../RDS/resourceTemplates/values.secret.example.yaml" "$SCRIPT_DIR/../RDS/resourceTemplates/values.secret.yaml"
  fi

  yq -i ".loggingBucket |= \"$(terraform output -raw logging_bucket_name)\"" "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml"
  yq -i ".replication.bucketARN |= \"$(terraform output -raw replication_bucket_arn)\"" "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml"
  yq -i ".replication.keyARN |= \"$(terraform output -raw replication_encryption_key_arn)\"" "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml"
  yq -i ".accountID |= \"$(terraform output -raw account_id)\"" "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml"
  yq -i ".suffix |= \"$SUFFIX\"" "$SCRIPT_DIR/../S3/resourceTemplates/values.secret.yaml"
fi 