# bats file_tags=resource:rds

setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/rds-instance-deletion-protection-enabled.yaml"
  kubectl wait --for=condition=Ready clusterpolicy/rds-instance-deletion-protection-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic rds instance is blocked for not having deletion protection enabled" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-no-delete-protection
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  assert_failure
  assert_output -p "rds-instance-deletion-protection-enabled" 
}

# bats test_tags=speed:slow
@test "basic rds instance with delete protection is allowed" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-with-delete-protection
  labels:
    test: $TESTNAME
spec:
  forProvider:
    deletionProtection: true
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml

  kubectl wait --timeout=5m --for=condition=Synced rdsinstance.database.aws.crossplane.io/basic-instance-with-delete-protection
  assert_success

  # --- Delete process

  # Remove the label so the policy doens't apply
patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-with-delete-protection
spec:
  forProvider:
    deletionProtection: true
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  # Remove deletion proection so we can actually delete the DB
patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-instance-with-delete-protection
spec:
  forProvider:
    deletionProtection: false
EOF
)" $MODULE_ROOT/Resources/BasicRDSInstance.yaml
  kubectl wait --timeout=5m --for=condition=Synced rdsinstance.database.aws.crossplane.io/basic-instance-with-delete-protection
  # Finally delete the instance
  kubectl delete rdsinstance basic-instance-with-delete-protection
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/rds-instance-deletion-protection-enabled.yaml 
  kubectl delete rdsinstance -l test=$TESTNAME
}
