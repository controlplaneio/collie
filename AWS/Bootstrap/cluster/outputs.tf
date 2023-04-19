output "cluster_id" {
  value = module.eks.cluster_id
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "aws_profile" {
  value = var.aws_profile
}

output "aws_region" {
  value = var.aws_region
}

output "suffix" {
  value = lower(random_string.suffix.result)
}