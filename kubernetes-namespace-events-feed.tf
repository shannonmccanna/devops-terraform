resource "kubernetes_namespace" "n" {
  metadata {
    name = "capstone-events-feed"
  }
}