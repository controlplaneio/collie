setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-version-lifecycle-policy-check.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-version-lifecycle-policy-check
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not having a versioning policy" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-version-lifecycle-policy
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-version-lifecycle-policy-check"
}

@test "bucket with a versioning policy is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/VersioningLifecycleBucket.yaml
  kubectl wait --for=condition=Synced --timeout=2m bucket.s3.aws.crossplane.io/versioning-lifecycle-bucket
  assert_success
  kubectl delete -f $MODULE_ROOT/Resources/VersioningLifecycleBucket.yaml
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-version-lifecycle-policy-check.yaml 
  kubectl delete buckets -l test=$TESTNAME
}
