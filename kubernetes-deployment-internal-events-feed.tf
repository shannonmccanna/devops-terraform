resource "kubernetes_deployment" "capstone-internal-events-feed-deployment" {
  metadata {
    name = "capstone-internal-events-feed-deployment"
    labels = {
      App = "capstone-internal-events-feed"
    }
    namespace = kubernetes_namespace.n.metadata[0].name
  }

  spec {
    replicas                  = 1
    progress_deadline_seconds = 60
    selector {
      match_labels = {
        App = "capstone-internal-events-feed"
      }
    }
    template {
      metadata {
        labels = {
          App = "capstone-internal-events-feed"
        }
      }
      spec {
        container {
          image = "gcr.io/devops-capstone-309221/internal-image:v0.1"
          name  = "capstone-internal-events-feed"

          port {
            container_port = 8082
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "2562Mi"
            }
            requests = {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}