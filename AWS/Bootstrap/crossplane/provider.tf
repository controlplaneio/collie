terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }

  required_version = ">= 1.2.3"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
