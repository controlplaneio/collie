setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-bucket-logging-enabled.yaml" 
  kubectl wait --for=condition=Ready clusterpolicy/s3-bucket-logging-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not logging access" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-logging
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-bucket-logging-enabled" 
}

@test "bucket with logging enabled is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/LoggingBucket.yaml
  # TODO: Figure out why logging bucket never gets to ready state
  kubectl wait --for=condition=Synced bucket.s3.aws.crossplane.io/logging-bucket
  assert_success
  kubectl delete -f $MODULE_ROOT/Resources/LoggingBucket.yaml
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-bucket-logging-enabled.yaml 
  kubectl delete buckets -l test=$TESTNAME
}
