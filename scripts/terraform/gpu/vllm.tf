resource "kubernetes_namespace" "vllm" {
  metadata {
    name = "vllm"
  }

  depends_on = [google_container_node_pool.gpu_nodes]
}

resource "kubernetes_deployment" "vllm_router" {
  metadata {
    name      = "vllm-router"
    namespace = kubernetes_namespace.vllm.metadata[0].name
    labels = {
      app = "vllm-router"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vllm-router"
      }
    }

    template {
      metadata {
        labels = {
          app = "vllm-router"
        }
        annotations = {
          "gke-gcsfuse/volumes" = "true"
        }
      }

      spec {
        toleration {
          key      = "nvidia.com/gpu"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          name  = "vllm-server"
          image = "vllm/vllm-openai:latest"

          env {
            name  = "HF_TOKEN"
            value = var.hf_token
          }

          env {
            name  = "HF_HOME"
            value = "/root/.cache/huggingface"
          }

          args = [
            "--model", var.vllm_model,
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
              "nvidia.com/gpu" = tostring(var.gpu_count)
              "memory"         = "32Gi"
              "cpu"            = "8"
            }
            requests = {
              "nvidia.com/gpu" = tostring(var.gpu_count)
              "memory"         = "16Gi"
              "cpu"            = "4"
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

  depends_on = [google_container_node_pool.gpu_nodes]
}

resource "kubernetes_service" "vllm_service" {
  metadata {
    name      = "vllm-router-service"
    namespace = kubernetes_namespace.vllm.metadata[0].name
  }

  spec {
    selector = {
      app = "vllm-router"
    }

    port {
      port        = 8000
      target_port = 8000
      name        = "http"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.vllm_router]
}
