# bats file_tags=resource:rds

setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/rds-enhanced-monitoring-enabled.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/rds-enhanced-monitoring-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic rds instance is blocked for not having enhanced monitoring" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-no-enhanced-monitoring
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  assert_failure
  assert_output -p "rds-enhanced-monitoring-enabled" 
}

@test "basic rds instance with enhanced monitoring is allowed" {
  patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: enhanced-monitoring-role
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/AuthorisedRDSRole.yaml

  patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: enhanced-monitoring-role-policy-attachment
  labels:
    test: $TESTNAME
spec:
  forProvider:
    roleNameRef:
      name: enhanced-monitoring-role
EOF
)" $MODULE_ROOT/Resources/AuthorisedRDSRolePolicyAttachment.yaml

  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-enhanced-monitoring
  labels:
    test: $TESTNAME
spec:
  forProvider:
    monitoringInterval: 1
    monitoringRoleArnRef:
      name: enhanced-monitoring-role
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  kubectl wait --timeout=5m --for=condition=Synced rdsinstance.database.aws.crossplane.io/basic-instance-enhanced-monitoring
  assert_success
  kubectl delete rdsinstance basic-instance-enhanced-monitoring
  kubectl delete rolepolicyattachment enhanced-monitoring-role-policy-attachment
  kubectl delete role.iam.aws.crossplane.io enhanced-monitoring-role
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/rds-enhanced-monitoring-enabled.yaml 
  kubectl delete rdsinstance -l test=$TESTNAME
}
