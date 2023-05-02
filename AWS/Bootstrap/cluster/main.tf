resource "random_string" "suffix" {
  length  = 6
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.project_name}-vpc-${lower(random_string.suffix.result)}"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "18.31.2"
  cluster_name                         = "${var.project_name}-eks-${lower(random_string.suffix.result)}"
  cluster_version                      = "1.25"
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  create_cloudwatch_log_group          = true
  cluster_endpoint_public_access_cidrs = ["${chomp(data.http.home_ip.response_body)}/32"]

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"

    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    primary = {
      attach_cluster_primary_security_group = true
      desired_size                          = 3

      instance_types = ["t3.medium"]
    }
  }
}
