#!/usr/bin/env bash

# EdgeRouter: Local Quantized Model Downloader
# Fetches the optimal Q4_K_M GGUF weights used by the llama-cpp-python engines

# Change to the directory of this script so downloads go directly into /models
cd "$(dirname "$0")" || exit 1

echo "======================================================="
echo "⚡ EdgeRouter Local Edge Fallback Provisioning ⚡"
echo "======================================================="
echo "Targeting optimal Q4_K_M quantized weights for latency."
echo "Note: These files total roughly 20GB. Grab some coffee."
echo ""

# Helper to download specific models
download_model() {
    local url=$1
    local filename=$2

    # Verify existing file is greater than 1MB
    if [ -f "$filename" ] && [ "$(wc -c < "$filename" | tr -d ' ')" -gt 1048576 ]; then
        echo "[SKIP] Model '$filename' already exists and is valid. Skipping download."
    else
        echo "⬇️ Downloading: $filename"
        
        # Inject Bearer token if HF_TOKEN environment variable is present
        if [ -n "$HF_TOKEN" ]; then
            curl -L -C - -H "Authorization: Bearer $HF_TOKEN" -o "$filename" "$url"
        else
            curl -L -C - -o "$filename" "$url"
        fi
        
        local file_size
        file_size=$(wc -c < "$filename" 2>/dev/null | tr -d ' ' || echo 0)
        
        if [ "$file_size" -gt 1048576 ]; then
            echo "[SUCCESS] Saved $filename ($file_size bytes)"
        else
            echo "[ERROR] Download for $filename failed or returned invalid response (Size: $file_size bytes)."
            if [ "$file_size" -lt 1000 ]; then
                echo "Response error content: $(cat "$filename")"
                echo "If downloading a gated model, set your token first: export HF_TOKEN=your_huggingface_token"
                rm -f "$filename"
            fi
        fi
    fi
}

echo "--- 1. Fetching Llama 3.1 8B Instruct ---"
download_model \
    "https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" \
    "Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
echo ""

echo "--- 2. Fetching Mistral NeMo 12B Instruct ---"
download_model \
    "https://huggingface.co/bartowski/Mistral-Nemo-Instruct-2407-GGUF/resolve/main/Mistral-Nemo-Instruct-2407-Q4_K_M.gguf" \
    "Mistral-Nemo-Instruct-2407-Q4_K_M.gguf"
echo ""

echo "--- 3. Fetching Local Edge Gemma 4 GGUF Weights ---"
if [ -f "gemma-4-12b-it-qat-q4_0.gguf" ] && [ "$(wc -c < "gemma-4-12b-it-qat-q4_0.gguf" | tr -d ' ')" -gt 1048576 ]; then
    echo "[SKIP] Model 'gemma-4-12b-it-qat-q4_0.gguf' already exists and is valid. Skipping download."
else
    echo "⬇️ Downloading google/gemma-4-12B-it-qat-q4_0-gguf via huggingface-cli..."
    uv run huggingface-cli download google/gemma-4-12B-it-qat-q4_0-gguf --local-dir .
fi
echo ""

echo "--- 4. Fetching BAAI/bge-m3 (Sentence Transformers) ---"
if [ -d "bge-m3" ]; then
    echo "[SKIP] Model directory 'bge-m3' already exists. Skipping download."
else
    echo "⬇️ Downloading BAAI/bge-m3 via huggingface-cli..."
    # uv will find the project root and run the CLI from our virtual environment
    uv run huggingface-cli download BAAI/bge-m3 --local-dir bge-m3
    
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Saved BAAI/bge-m3 to models/bge-m3/"
    else
        echo "[ERROR] Failed to download BAAI/bge-m3"
    fi
fi
echo ""

echo "======================================================="
echo "✅ EdgeRouter Model Provisioning Complete!"
echo "Make sure your '.env.toml' paths point to these newly downloaded .gguf files."
echo "======================================================="
