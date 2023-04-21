plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  deep_check = true
  enabled = true
  version = "0.21.2"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}