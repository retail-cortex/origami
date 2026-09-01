output "gke_cluster_name" {
  description = "GKE GPU Cluster Name"
  value       = google_container_cluster.primary.name
}

output "gke_cluster_endpoint" {
  description = "GKE Master Endpoint"
  value       = google_container_cluster.primary.endpoint
}

output "gcloud_get_credentials_command" {
  description = "Command to get cluster credentials for kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}

output "vllm_service_load_balancer_ip" {
  description = "External LoadBalancer IP for vLLM Router Service"
  value       = kubernetes_service.vllm_service.status[0].load_balancer[0].ingress[0].ip
}

output "gcs_model_bucket" {
  description = "Google Cloud Storage Bucket Name for Model Uploads"
  value       = google_storage_bucket.model_bucket.name
}
