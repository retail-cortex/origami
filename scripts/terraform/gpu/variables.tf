variable "project_id" {
  type        = string
  description = "GCP Project ID sourced from .env.local.toml"
  default     = "cs-poc-gvosjaln9q6gcudiayjqdzq"
}

variable "region" {
  type        = string
  description = "GCP Region for GKE cluster deployment"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP Zone for single-node GKE GPU node pool"
  default     = "us-central1-a"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE GPU cluster"
  default     = "origami-vllm-gpu-gke"
}

variable "machine_type" {
  type        = string
  description = "GCP Machine type for GPU node (a2-ultragpu-1g provides 1x NVIDIA A100 80GB GPU)"
  default     = "a2-ultragpu-1g"
}

variable "gpu_type" {
  type        = string
  description = "GPU Accelerator type (nvidia-a100-80gb)"
  default     = "nvidia-a100-80gb"
}

variable "gpu_count" {
  type        = number
  description = "Number of GPUs per node"
  default     = 1
}

variable "vllm_model" {
  type        = string
  description = "Model repository/id to serve with vLLM on GPU node pool"
  default     = "google/gemma-3-12b-it"
}

variable "hf_token" {
  type        = string
  description = "Hugging Face User Access Token for gated model downloads (e.g. google/gemma-3-12b-it)"
  default     = ""
  sensitive   = true
}
