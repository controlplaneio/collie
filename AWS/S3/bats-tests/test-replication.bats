setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-bucket-replication-enabled.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/s3-bucket-replication-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not having replication" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-replication
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-bucket-replication-enabled"
}

@test "bucket with replication enabled is allowed" {
  kubectl apply -f $MODULE_ROOT/Resources/AuthorisedBucket/replicationRole.yaml
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/ReplicationBucket.yaml
  kubectl wait --timeout=5m --for=condition=Synced bucket.s3.aws.crossplane.io/replication-bucket
  assert_success
  kubectl delete -f $MODULE_ROOT/Resources/ReplicationBucket.yaml
  kubectl delete -f $MODULE_ROOT/Resources/AuthorisedBucket/replicationRole.yaml
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-bucket-replication-enabled.yaml 
  kubectl delete buckets -l test=$TESTNAME
}
