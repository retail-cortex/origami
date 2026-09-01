variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "cs-poc-gvosjaln9q6gcudiayjqdzq"
}

variable "region" {
  type        = string
  description = "GCP Region for GKE TPU cluster deployment"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP Zone supporting TPU v5e"
  default     = "us-central1-a"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE TPU cluster"
  default     = "origami-tpu-gke"
}

variable "machine_type" {
  type        = string
  description = "GCP TPU Machine Type (ct5lp-hightpu-4t provides 4x TPU v5e chips, 64GB HBM)"
  default     = "ct5lp-hightpu-4t"
}

variable "tpu_model" {
  type        = string
  description = "TPU-optimized model repository to serve"
  default     = "google/gemma-4-12B-it-qat-q4_0-unquantized"
}

variable "hf_token" {
  type        = string
  description = "Hugging Face Access Token for gated model downloads"
  default     = ""
  sensitive   = true
}
