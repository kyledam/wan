#!/bin/bash

echo "=========================================="
echo "Krea 2 Models Download Script"
echo "=========================================="

# QUAN TRỌNG: Chờ aria2c được cài đặt bởi pre-script
# Không chạy apt install ở đây để tránh lỗi lock file
echo "Dang kiem tra aria2c..."
while ! command -v aria2c &> /dev/null; do
    echo "Doi aria2c duoc cai dat..."
    sleep 5
done
echo "Da tim thay aria2c! Bat dau download..."

DOWNLOADER="aria2c"

# Tạo thư mục gốc và cd vào
mkdir -p /workspace/ComfyUI/models
cd /workspace/ComfyUI/models || { echo "Loi: Khong tim thay thu muc models"; exit 1; }

# Tạo cấu trúc thư mục con
mkdir -p diffusion_models/krea2 text_encoders vae loras upscale_models

# Hàm download tối ưu cho chạy song song
download_file() {
    local url="$1"
    local output_dir="$2"
    local output_file="$3"
    
    mkdir -p "$output_dir"
    
    # Kiểm tra file tồn tại chưa
    if [ -f "$output_dir/$output_file" ]; then
        echo "Skip: $output_file (Da ton tai)"
        return
    fi
    
    # -x 16: Max connection, -s 16: Split file
    # & ở cuối để chạy ẩn (background) giúp tải nhiều file cùng lúc
    aria2c -x 16 -s 16 -k 1M -d "$output_dir" -o "$output_file" "$url" &
}

echo ""
echo "=========================================="
echo "Downloading Krea 2 Models"
echo "=========================================="

echo "Downloading Diffusion Model: krea2_turbo_fp8_scaled.safetensors (~12.2GB)..."
download_file \
  "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/diffusion_models/krea2_turbo_fp8_scaled.safetensors" \
  "diffusion_models/krea2" \
  "krea2_turbo_fp8_scaled.safetensors"

echo "Downloading CLIP: Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors (~4.9GB)..."
download_file \
  "https://huggingface.co/artsyww/fp8mix-clips/resolve/main/Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors" \
  "text_encoders" \
  "Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors"

echo "Downloading VAE: qwen_image_vae.safetensors (~242MB)..."
download_file \
  "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors" \
  "vae" \
  "qwen_image_vae.safetensors"

echo "Downloading VAE: krea2RealVae_v10.safetensors (~242MB)..."
download_file \
  "https://huggingface.co/artsyww/KREA2REALVAE/resolve/main/krea2RealVae_v10.safetensors" \
  "vae" \
  "krea2RealVae_v10.safetensors"

echo ""
echo "All downloads started in parallel with aria2c..."
echo "Waiting for all downloads to complete..."
# Chờ tất cả tiến trình aria2c chạy nền hoàn tất
wait

echo ""
echo "=========================================="
echo "Verifying Downloads"
echo "=========================================="

echo "Diffusion Models (krea2):"
ls -lh diffusion_models/krea2/ 2>/dev/null || echo "Not found yet"
echo "Text Encoders:"
ls -lh text_encoders/ 2>/dev/null || echo "Not found yet"
echo "VAE:"
ls -lh vae/ 2>/dev/null || echo "Not found yet"

echo ""
echo "=========================================="
echo "Download Complete! (ALL FILES)"
echo "=========================================="
