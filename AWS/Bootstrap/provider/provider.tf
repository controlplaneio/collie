terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
  }

  required_version = ">= 1.2.3"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}