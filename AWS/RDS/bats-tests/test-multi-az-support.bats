# bats file_tags=resource:rds

setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/rds-multi-az-support.yaml" 
  kubectl wait --for=condition=Ready clusterpolicy/rds-multi-az-support
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic rds instance is blocked for not having multi az support" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-no-multi-az
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  assert_failure
  assert_output -p "rds-multi-az-support" 
}

@test "setting mutli az is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-rdsinstance-with-multiaz
  labels:
    test: $TESTNAME
spec:
  forProvider:
    multiAZ: true
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml 
  kubectl wait --timeout=5m --for=condition=Synced rdsinstance.database.aws.crossplane.io/basic-rdsinstance-with-multiaz
  assert_success
  kubectl delete rdsinstance.database.aws.crossplane.io basic-rdsinstance-with-multiaz
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/rds-multi-az-support.yaml 
  kubectl delete rdsinstance -l test=$TESTNAME
}
