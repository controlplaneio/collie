setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-bucket-server-side-encryption-enabled.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-bucket-server-side-encryption-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not having server side encryption" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-sse
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-bucket-server-side-encryption-enabled"
}

@test "bucket with server side encryption enabled is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: encrypted-bucket-sse
  annotations:
    crossplane.io/external-name: collie-encrypted-bucket-sse
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/EncryptedBucket.yaml
  kubectl wait --for=condition=Ready bucket.s3.aws.crossplane.io/encrypted-bucket-sse
  assert_success
  kubectl delete bucket.s3.aws.crossplane.io encrypted-bucket-sse
}

@test "bucket with aes256 encryption is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: encrypted-bucket-aes256
  annotations:
    crossplane.io/external-name: collie-encrypted-bucket-aes256
  labels:
    test: $TESTNAME
spec:
  forProvider:
    serverSideEncryptionConfiguration:
      rules:
        - applyServerSideEncryptionByDefault:
            sseAlgorithm: AES256
EOF
)" $MODULE_ROOT/Resources/EncryptedBucket.yaml 
  kubectl wait --for=condition=Synced bucket.s3.aws.crossplane.io/encrypted-bucket-aes256
  assert_success
  kubectl delete bucket.s3.aws.crossplane.io encrypted-bucket-aes256
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-bucket-server-side-encryption-enabled.yaml 
  kubectl delete bucket -l test=$TESTNAME
}
