setup_file() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
  testfilename=$(basename -- "$BATS_TEST_FILENAME")
  export TESTNAME="${testfilename%.*}"
  apply_policy_with_label_selector "$TESTNAME" "$MODULE_ROOT/Policies/s3-event-notifications-enabled.yaml" 
  kubectl wait --for=condition=Ready clusterpolicy/s3-event-notifications-enabled
}

setup() {
  load "${ROOT}/bats/test_helper/setup"
  _common_setup
  export MODULE_ROOT="$( cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd )"
}

@test "basic bucket is blocked for not having event notifications enabled" {
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  name: basic-bucket-no-notifications
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/BasicBucket.yaml
  assert_failure
  assert_output -p "s3-event-notifications-enabled"
}

@test "bucket with notifications enabled is allowed" {
  patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/NotificationTopic.yaml
  kubectl wait --for=condition=Ready topic.sns.aws.crossplane.io/notification-bucket-topic
  run patch_and_apply_yaml "$(cat <<EOF
metadata:
  labels:
    test: $TESTNAME
EOF
)" $MODULE_ROOT/Resources/NotificationBucket.yaml
  assert_success
  kubectl delete -f $MODULE_ROOT/Resources/NotificationBucket.yaml
  kubectl delete -f $MODULE_ROOT/Resources/NotificationTopic.yaml
}

teardown_file() {
  kubectl delete -f $MODULE_ROOT/Policies/s3-event-notifications-enabled.yaml
  kubectl delete buckets,topics -l test=$TESTNAME
}
