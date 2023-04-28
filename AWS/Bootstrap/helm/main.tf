resource "helm_release" "kyverno" {
  name = "kyverno"

  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "v2.7.2"

  namespace        = "kyverno-system"
  create_namespace = true

  set {
    name  = "replicaCount"
    value = 3
  }
}

resource "helm_release" "crossplane" {
  name = "crossplane"

  repository = "https://charts.crossplane.io/stable"
  chart      = "crossplane"
  version    = "1.10.1"

  namespace        = "crossplane-system"
  create_namespace = true
}
