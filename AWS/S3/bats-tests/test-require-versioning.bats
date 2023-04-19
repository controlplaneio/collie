setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-bucket-versioning-enabled.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-bucket-versioning-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not having versioning" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-versioning
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-bucket-versioning-enabled"
}

@test "bucket with versioning enabled is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/VersioningBucket.yaml
  kubectl wait --for=condition=Synced bucket.s3.aws.crossplane.io/versioning-bucket
  assert_success
  kubectl delete -f $MODULE_ROOT/Resources/VersioningBucket.yaml
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-bucket-versioning-enabled.yaml 
  kubectl delete buckets -l test=$TESTNAME
}
