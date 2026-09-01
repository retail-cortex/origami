resource "kubernetes_namespace" "tpu_serving" {
  metadata {
    name = "tpu-serving"
  }

  depends_on = [google_container_node_pool.tpu_nodes]
}

resource "kubernetes_deployment" "tpu_serving_router" {
  metadata {
    name      = "tpu-serving-router"
    namespace = kubernetes_namespace.tpu_serving.metadata[0].name
    labels = {
      app = "tpu-serving-router"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tpu-serving-router"
      }
    }

    template {
      metadata {
        labels = {
          app = "tpu-serving-router"
        }
        annotations = {
          "gke-gcsfuse/volumes" = "true"
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-tpu-accelerator" = "tpu-v5-lite-podslice"
          "cloud.google.com/gke-tpu-topology"    = "2x2"
        }

        container {
          name  = "tpu-serving-container"
          image = "us-docker.pkg.dev/cloud-tpu-images/vllm/vllm-tpu:latest"

          env {
            name  = "HF_TOKEN"
            value = var.hf_token
          }

          env {
            name  = "HF_HOME"
            value = "/root/.cache/huggingface"
          }

          args = [
            "--model", var.tpu_model,
            "--host", "0.0.0.0",
            "--port", "8000",
            "--trust-remote-code"
          ]

          port {
            container_port = 8000
            name           = "http"
          }

          volume_mount {
            name       = "model-cache"
            mount_path = "/root/.cache/huggingface"
          }

          volume_mount {
            name       = "gcs-models"
            mount_path = "/models"
          }

          resources {
            limits = {
              "google.com/tpu" = "4"
              "memory"         = "64Gi"
              "cpu"            = "16"
            }
            requests = {
              "google.com/tpu" = "4"
              "memory"         = "32Gi"
              "cpu"            = "8"
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 60
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 120
            period_seconds        = 15
          }
        }

        volume {
          name = "model-cache"

          empty_dir {}
        }

        volume {
          name = "gcs-models"
          csi {
            driver = "gcsfuse.csi.storage.gke.io"
            volume_attributes = {
              bucketName = google_storage_bucket.model_bucket.name
            }
          }
        }
      }
    }
  }

  depends_on = [google_container_node_pool.tpu_nodes]
}

resource "kubernetes_service" "tpu_service" {
  metadata {
    name      = "tpu-router-service"
    namespace = kubernetes_namespace.tpu_serving.metadata[0].name
  }

  spec {
    selector = {
      app = "tpu-serving-router"
    }

    port {
      port        = 8000
      target_port = 8000
      name        = "http"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.tpu_serving_router]
}

