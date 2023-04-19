# bats file_tags=resource:rds

setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/rds-logging-enabled.yaml" 
  kubectl wait --for=condition=Ready clusterpolicy/rds-logging-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic rds instance is blocked for not having logging enabled" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-no-logging
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  assert_failure
  assert_output -p "rds-logging-enabled" 
}

@test "setting logging is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-rdsinstance-with-logging
  labels:
    test: $TESTNAME
spec:
  forProvider:
    cloudwatchLogsExportConfiguration:
      enableLogTypes:
        - postgresql
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml 
  kubectl wait --timeout=5m --for=condition=Synced rdsinstance.database.aws.crossplane.io/basic-rdsinstance-with-logging
  assert_success
  kubectl delete rdsinstance.database.aws.crossplane.io basic-rdsinstance-with-logging
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/rds-logging-enabled.yaml 
  kubectl delete rdsinstance -l test=$TESTNAME
}
