# Terraform Provisioning Guide: GKE Inference Architecture (GPU & TPU)

This directory contains modularized Terraform scripts for provisioning single-node Google Kubernetes Engine (GKE) clusters targeting either **GPU** (NVIDIA A100 80GB) or **TPU** (Cloud TPU v5e ct5lp-hightpu-4t) inference accelerators, along with automated vLLM deployment manifests.

---

## Workspace Directory Structure

```text
scripts/terraform/
├── gpu/                     # NVIDIA A100 80GB GPU GKE Provisioning
│   ├── main.tf              # GCP VPC, GKE Cluster, GPU Node Pool, Storage Bucket
│   ├── vllm.tf              # vLLM Kubernetes Deployment, Service, GCS Fuse Mounts
│   ├── variables.tf         # Input Variable Declarations
│   ├── outputs.tf           # Terraform Output Declarations
│   ├── terraform.tfvars     # Variable Value Overrides
│   └── backend.tf           # Remote GCS State Configuration Template
└── tpu/                     # Cloud TPU v5e GKE Provisioning
    ├── main.tf              # GCP VPC, GKE Cluster, TPU Node Pool, TPU Storage Bucket
    ├── tpu_serving.tf       # vLLM TPU Kubernetes Deployment, Service, GCS Fuse Mounts
    ├── variables.tf         # Input Variable Declarations
    ├── outputs.tf           # Terraform Output Declarations
    ├── terraform.tfvars     # Variable Value Overrides
    └── backend.tf           # Remote GCS State Configuration Template
```

---

## 1. Prerequisites

Ensure the following tools are installed before running deployment commands:

1. **Terraform**: `>= 1.5.0`
2. **Google Cloud CLI (`gcloud`)**: Authenticated to target GCP project (`cs-poc-gvosjaln9q6gcudiayjqdzq`).
3. **kubectl**: Kubernetes CLI tool for cluster management.

---

## 2. Initial Setup & Authentication

### Step 1: Google Cloud Credentials
```bash
gcloud auth login
gcloud auth application-default login
```

### Step 2: Set Active Project
```bash
gcloud config set project cs-poc-gvosjaln9q6gcudiayjqdzq
```

### Step 3: Enable Google Cloud APIs
For **TPU** deployments, enable TPU API in addition to Compute Engine and GKE:
```bash
gcloud services enable container.googleapis.com compute.googleapis.com tpu.googleapis.com
```

---

## 3. TPU Deployment Workflow (`scripts/terraform/tpu`)

### Step 1: Navigate & Initialize
```bash
cd scripts/terraform/tpu
terraform init
```

### Step 2: Format & Validate
```bash
terraform fmt -check
terraform validate
```

### Step 3: Execution Plan & Apply
```bash
terraform plan
terraform apply
```

### Step 4: Access Cluster & Verify Pods
```bash
gcloud container clusters get-credentials origami-tpu-gke --zone us-central1-a --project cs-poc-gvosjaln9q6gcudiayjqdzq
kubectl get pods -n tpu-serving -o wide
```

---

## 4. GPU Deployment Workflow (`scripts/terraform/gpu`)

### Step 1: Navigate & Initialize
```bash
cd scripts/terraform/gpu
terraform init
```

### Step 2: Format & Validate
```bash
terraform fmt -check
terraform validate
```

### Step 3: Execution Plan & Apply
```bash
terraform plan
terraform apply
```

### Step 4: Access Cluster & Verify Pods
```bash
gcloud container clusters get-credentials origami-vllm-gpu-gke --zone us-central1-a --project cs-poc-gvosjaln9q6gcudiayjqdzq
kubectl get pods -n vllm -o wide
```

---

## 5. Teardown & Cleanup

To destroy resources in either directory:

```bash
# For TPU teardown
cd scripts/terraform/tpu
terraform destroy

# For GPU teardown
cd scripts/terraform/gpu
terraform destroy
```

