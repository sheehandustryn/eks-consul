resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "helm_release" "consul" {
  name       = "consul"
  namespace  = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"

  values = [
    "${file("values.yaml")}"
  ]

  timeout = 600

  depends_on = [
    kubernetes_namespace.consul
  ]
}
