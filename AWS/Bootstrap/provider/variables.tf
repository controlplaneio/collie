variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "oidc_provider" {
  type = string
}

variable "suffix" {
  type = string
}