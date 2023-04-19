#! /usr/bin/env bash

patch_and_apply_yaml()  {
  yq ". * ( \"$1\" | from_yaml )" $2 | kubectl apply -f -
}

apply_policy_with_label_selector() {
  yq " .spec.rules[].match.resources.selector.matchLabels.test |= \"$1\"" "$2" | kubectl apply -f -
}