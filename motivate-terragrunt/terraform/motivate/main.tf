resource "kubernetes_namespace" "motivate" {
  metadata {
    name = "motivate"
  }
}

resource "helm_release" "motivate" {
  name  = "motivate"
  chart = "../../chart/motivate-chart"

  timeout = 1500

  depends_on = [
    kubernetes_namespace.motivate
  ]
}
