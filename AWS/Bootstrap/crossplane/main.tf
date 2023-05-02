
resource "helm_release" "crossplane" {
  name = "crossplane"

  repository = "https://charts.crossplane.io/stable"
  chart      = "crossplane"
  version    = "1.12.0"

  namespace        = "crossplane-system"
  create_namespace = true
}
