terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
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

provider "helm" {

  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--profile", var.aws_profile, "--region", var.aws_region]
      command     = "aws"
    }
  }
}