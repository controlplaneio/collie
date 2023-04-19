data "aws_caller_identity" "current" {}

resource "aws_iam_role" "crossplane" {
  name = "crossplane-${var.suffix}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${var.oidc_provider}:sub" : "system:serviceaccount:*"
          }
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "kubectl_manifest" "controller_config" {
  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1alpha1
kind: ControllerConfig
metadata:
  name: irsa-controllerconfig
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.crossplane.arn}
spec:
  args:
  - '--debug'
  - '--leader-election'
  replicas: 3
YAML
}

resource "kubernetes_manifest" "aws_provider" {
  depends_on = [
    kubectl_manifest.controller_config
  ]
  manifest = {
    apiVersion = "pkg.crossplane.io/v1"
    kind       = "Provider"

    metadata = {
      name = "provider-aws"
    }

    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/provider-aws:v0.37.1"
      controllerConfigRef = {
        name = "irsa-controllerconfig"
      }
    }
  }

  wait {
    condition {
      type   = "Healthy"
      status = "True"
    }
  }
}

resource "kubectl_manifest" "aws_provider_config" {
  depends_on = [
    kubernetes_manifest.aws_provider
  ]
  yaml_body = <<YAML
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: InjectedIdentity
  YAML
}