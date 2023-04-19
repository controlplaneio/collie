setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-bucket-level-public-access-prohibited.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-bucket-level-public-access-prohibited
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-public-access
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-bucket-level-public-access-block-public-acls"
}

@test "block public access bucket is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BlockPublicBucket.yaml
  kubectl wait --timeout=5m --for=condition=Synced bucket.s3.aws.crossplane.io/block-public-access
  assert_success
  kubectl delete -f $MODULE_ROOT/Resources/BlockPublicBucket.yaml
}

@test "not blocking public ACLs is blocked" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: dont-block-public-acls
  labels:
    test: $TESTNAME
spec:
  forProvider:
    publicAccessBlockConfiguration:
      blockPublicAcls: false
EOF
)" $MODULE_ROOT/Resources/BlockPublicBucket.yaml 
  assert_failure
  assert_output -p "s3-bucket-level-public-access-block-public-acls"
}

@test "not blocking public policy is blocked" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: dont-block-public-policy
  labels:
    test: $TESTNAME
spec:
  forProvider:
    publicAccessBlockConfiguration:
      blockPublicPolicy: false
EOF
)" $MODULE_ROOT/Resources/BlockPublicBucket.yaml 
  assert_failure
  assert_output -p "s3-bucket-level-public-access-block-public-policy"
}

@test "not ignoring public ACLs is blocked" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: dont-ignore-public-acl
  labels:
    test: $TESTNAME
spec:
  forProvider:
    publicAccessBlockConfiguration:
      ignorePublicAcls: false
EOF
)" $MODULE_ROOT/Resources/BlockPublicBucket.yaml 
  assert_failure
  assert_output -p "s3-bucket-level-public-access-ignore-public-acls"
}

@test "not restricting public buckets is blocked" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: dont-restrict-public-buckets
  labels:
    test: $TESTNAME
spec:
  forProvider:
    publicAccessBlockConfiguration:
      restrictPublicBuckets: false
EOF
)" $MODULE_ROOT/Resources/BlockPublicBucket.yaml 
  assert_failure
  assert_output -p "s3-bucket-level-public-access-restrict-public-buckets"
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-bucket-level-public-access-prohibited.yaml 
  kubectl delete buckets -l test=$TESTNAME
}
