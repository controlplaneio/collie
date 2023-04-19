setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-default-encryption-kms.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-default-encryption-kms
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not having kms server side encryption" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-kms-encryption
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-default-encryption-kms"
}

@test "bucket with server side encryption enabled is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: encrypted-bucket-kms
  annotations:
    crossplane.io/external-name: collie-encrypted-bucket-kms
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/EncryptedBucket.yaml
  kubectl wait --for=condition=Synced bucket.s3.aws.crossplane.io/encrypted-bucket-kms
  assert_success
  kubectl delete bucket.s3.aws.crossplane.io encrypted-bucket-kms
}

@test "bucket with aes256 encryption is not allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: encrypted-bucket-kms-aes256
  labels:
    test: $TESTNAME
  annotations:
    crossplane.io/external-name: collie-encrypted-bucket-kms-aes256
spec:
  forProvider:
    serverSideEncryptionConfiguration:
      rules:
        - applyServerSideEncryptionByDefault:
            sseAlgorithm: AES256
EOF
)" $MODULE_ROOT/Resources/EncryptedBucket.yaml 
  assert_failure
  assert_output -p "s3-default-encryption-kms"
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-default-encryption-kms.yaml
  kubectl delete buckets -l test=$TESTNAME
}
