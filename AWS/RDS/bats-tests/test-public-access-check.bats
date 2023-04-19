# bats file_tags=resource:rds

setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/rds-instance-public-access-check.yaml" 
  kubectl wait --for=condition=Ready clusterpolicy/rds-instance-public-access-check
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic rds instance is blocked for not preventing public access" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-public-access
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  assert_failure
  assert_output -p "rds-instance-public-access-check" 
}

@test "disabling public access is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-rdsinstance-without-public-access
  labels:
    test: $TESTNAME
spec:
  forProvider:
    publiclyAccessible: false
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml 
  kubectl wait --timeout=5m --for=condition=Synced rdsinstance.database.aws.crossplane.io/basic-rdsinstance-without-public-access
  assert_success
  kubectl delete rdsinstance.database.aws.crossplane.io basic-rdsinstance-without-public-access
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/rds-instance-public-access-check.yaml 
  kubectl delete rdsinstance -l test=$TESTNAME
}
