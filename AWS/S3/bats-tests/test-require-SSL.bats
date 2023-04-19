setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-bucket-ssl-requests-only.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-bucket-ssl-requests-only
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not using SSL only" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-ssl
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-bucket-ssl-requests-only"
}

@test "basic bucket with policy blocking SSL is allowed" {
  patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
spec:
  forProvider:
    bucketNameRef:
      name: basic-bucket-with-policy
EOF
)" $MODULE_ROOT/Resources/BasicBucketPolicy.yaml 

  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-with-policy
  annotations:
    crossplane.io/external-name: collie-bucket-with-policy
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml 

  kubectl wait --for=condition=Synced bucket.s3.aws.crossplane.io/basic-bucket-with-policy
  assert_success
  kubectl delete bucket.s3.aws.crossplane.io basic-bucket-with-policy
  kubectl delete -f $MODULE_ROOT/Resources/BasicBucketPolicy.yaml
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-bucket-ssl-requests-only.yaml 
  kubectl delete buckets -l test=$TESTNAME
}
