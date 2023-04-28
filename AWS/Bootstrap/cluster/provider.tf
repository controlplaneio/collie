terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  required_version = ">= 1.2.3"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
