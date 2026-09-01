#!/usr/bin/env bash

# Upload local models directory to GCS bucket mounted by GKE vLLM server
cd "$(dirname "$0")" || exit 1

PROJECT_ID="cs-poc-gvosjaln9q6gcudiayjqdzq"
BUCKET_NAME="${PROJECT_ID}-vllm-models"

echo "======================================================="
echo "☁️ Uploading local model assets to GCS Bucket: gs://${BUCKET_NAME} ☁️"
echo "======================================================="

gcloud storage rsync . "gs://${BUCKET_NAME}" --recursive --project="${PROJECT_ID}" --exclude=".*"

if [ $? -eq 0 ]; then
    echo "======================================================="
    echo "✅ Model assets successfully synced to gs://${BUCKET_NAME}"
    echo "Files are now available inside GKE vLLM container path: /models/"
    echo "======================================================="
else
    echo "❌ Failed to sync models to GCS bucket gs://${BUCKET_NAME}"
    exit 1
fi
