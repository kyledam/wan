#!/bin/bash

echo "=========================================="
echo "WAN 2.2 Models Download Script (FULL)"
echo "Auto-selecting QuantStack Official (A14B)"
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
mkdir -p diffusion_models text_encoders vae loras upscale_models
mkdir -p "diffusion_models/wan22_quantstack_a14b"

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
echo "Downloading QuantStack Official Models"
echo "=========================================="

echo "Downloading QuantStack High Noise (~13GB)..."
download_file \
  "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf" \
  "diffusion_models" \
  "Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"

echo "Downloading QuantStack Low Noise (~13GB)..."
download_file \
  "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf" \
  "diffusion_models" \
  "Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"
  
download_file \
  "https://huggingface.co/1038lab/Qwen-Image-Edit-2511-FP8/resolve/main/Qwen-Image-Edit-2511-FP8_e4m3fn.safetensors" \
  "diffusion_models" \
  "Qwen-Image-Edit-2511-FP8_e4m3fn.safetensors"

#echo "Downloading Text Encoder FP8 (~5GB)..."
#download_file \
#  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true" \
#  "text_encoders" \
#  "umt5_xxl_fp8_e4m3fn_scaled.safetensors"

echo "Downloading Text Encoder FP8 (~5GB)..."
download_file \
  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors" \
  "text_encoders" \
  "umt5_xxl_fp16.safetensors"
  
download_file \
  "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
  "text_encoders" \
  "qwen_2.5_vl_7b_fp8_scaled.safetensors"

#echo "Downloading Text Encoder FP8 (~5GB)..."
#download_file \
#  "https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_fp8_scaled.safetensors" \
#  "text_encoders" \
#  "nsfw_wan_umt5-xxl_fp8_scaled.safetensors"




echo "Downloading Wan2.1 Lightning LoRA (~1.2GB)..."
download_file \
  "https://huggingface.co/lightx2v/Wan2.1-I2V-14B-480P-StepDistill-CfgDistill-Lightx2v/resolve/main/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors?download=true" \
  "loras" \
  "Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors"

echo "Downloading Lightx2v I2V 480p LoRA rank128 (~2.4GB)..."
download_file \
  "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors?download=true" \
  "loras" \
  "lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors"

echo "Downloading Lightx2v I2V 480p LoRA rank128 (~2.4GB)..."
download_file \
  "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors" \
  "loras" \
  "Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors"

echo "Downloading Lightx2v I2V 480p LoRA rank128 (~2.4GB)..."
download_file \
  "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors" \
  "loras" \
  "Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors"

echo "Downloading Lightx2v I2V 480p LoRA rank128 (~2.4GB)..."
download_file \
  "https://huggingface.co/vita-video-gen/svi-model/resolve/main/version-2.0/SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors" \
  "loras" \
  "SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors"

echo "Downloading Lightx2v I2V 480p LoRA rank128 (~2.4GB)..."
download_file \
  "https://huggingface.co/vita-video-gen/svi-model/resolve/main/version-2.0/SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors" \
  "loras" \
  "SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors"

MODELS_FOLDER="diffusion_models/wan22_quantstack_a14b"

# Common downloads
echo ""
echo "=========================================="
echo "Downloading Common Files"
echo "=========================================="

echo "Downloading VAE (~350MB)..."
download_file \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors?download=true" \
  "vae" \
  "wan_2.1_vae.safetensors"
  
download_file \
  "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" \
  "vae" \
  "qwen_image_vae.safetensors"

echo "Downloading RealESRGAN x2 Upscaler (~60MB)..."
download_file \
  "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x2.pth?download=true" \
  "upscale_models" \
  "RealESRGAN_x2.pth"

# Additional LoRAs
echo ""
echo "=========================================="
echo "Downloading Additional LoRAs (kyledam)"
echo "=========================================="

download_file "https://huggingface.co/kyledam/wan_lora/resolve/main/qe2511_consis_alpha_patched.safetensors" "loras" "qe2511_consis_alpha_patched.safetensors"
download_file "https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors" "loras" "Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors"

echo ""
echo "All downloads started in parallel with aria2c..."
echo "Waiting for all downloads to complete..."
# Chờ tất cả tiến trình aria2c chạy nền hoàn tất
wait

echo ""
echo "=========================================="
echo "Verifying Downloads"
echo "=========================================="

echo "Diffusion Models:"
ls -lh "$MODELS_FOLDER/" 2>/dev/null || echo "Not found yet"
echo "Text Encoders:"
ls -lh text_encoders/ 2>/dev/null || echo "Not found yet"
echo "VAE:"
ls -lh vae/ 2>/dev/null || echo "Not found yet"
echo "LoRAs:"
ls -lh loras/ 2>/dev/null || echo "Not found yet"
echo "Upscale Models:"
ls -lh upscale_models/ 2>/dev/null || echo "Not found yet"

echo ""
echo "=========================================="
echo "Download Complete! (ALL FILES)"
echo "=========================================="






