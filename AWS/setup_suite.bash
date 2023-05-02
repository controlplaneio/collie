setup_suite() {
  ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
  export ROOT

  if [ "$SKIP_TERRAFORM" != "true" ]
  then
    cd "$ROOT/AWS/Bootstrap" || exit 1
    ./up.sh -d >&3
    # There is sometimes an issue where kyverno cannot see the CRDs 
    # created by crossplane. The sleep here is to try and give everything 
    # time to initialise. In future we will make this better.
    sleep 900
  fi

  cd "$ROOT/AWS/Bootstrap/cluster" || exit 1
  export SUFFIX="$(terraform output -raw suffix)"

  cd "$ROOT" || exit 1
  make generate-resources >&3
  make generate-policies >&3
}

teardown_suite() {
  if [ "$PRESERVE_CLUSTER" == "true" ]
  then
    return 0
  fi

  echo "Tearding down cluster, set \$PRESERVE_CLUSTER to 'true' to skip this" >&3
  cd "$ROOT/AWS/Bootstrap" || exit 1
  ./down.sh -d >&3
}