#!/bin/bash

echo "=========================================="
echo "WAN 2.2 Models Download Script"
echo "Auto-selecting QuantStack Official (A14B)"
echo "=========================================="

# Check if aria2c is installed, if not use wget
if command -v aria2c &> /dev/null; then
    DOWNLOADER="aria2c"
    echo "Using aria2c (fast, parallel downloads)"
else
    DOWNLOADER="wget"
    echo "aria2c not found, using wget (slower, sequential)"
    echo "To install aria2c for faster downloads: apt install -y aria2"
fi

# Auto-select option 3
choice="3"

cd /workspace/ComfyUI/models || exit 1

# Create folders
mkdir -p diffusion_models text_encoders vae loras upscale_models

# Function to download with aria2c or wget
download_file() {
    local url="$1"
    local output_dir="$2"
    local output_file="$3"
    
    mkdir -p "$output_dir"
    
    if [ "$DOWNLOADER" == "aria2c" ]; then
        aria2c -x 16 -s 16 -k 1M -d "$output_dir" -o "$output_file" "$url" &
    else
        wget -c -O "$output_dir/$output_file" "$url" &
    fi
}

echo ""
echo "=========================================="
echo "Downloading QuantStack Official Models"
echo "=========================================="

# Create subfolder for organization
mkdir -p "diffusion_models/wan22_quantstack_a14b"

echo "Downloading QuantStack High Noise (~13GB)..."
download_file \
  "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf?download=true" \
  "diffusion_models/wan22_quantstack_a14b" \
  "Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"

echo "Downloading QuantStack Low Noise (~13GB)..."
download_file \
  "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf?download=true" \
  "diffusion_models/wan22_quantstack_a14b" \
  "Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"

echo "Downloading Text Encoder FP8 (~5GB)..."
download_file \
  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true" \
  "text_encoders" \
  "umt5_xxl_fp8_e4m3fn_scaled.safetensors"

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

MODELS_FOLDER="diffusion_models/wan22_quantstack_a14b"

# Common downloads for all options
echo ""
echo "=========================================="
echo "Downloading Common Files"
echo "=========================================="

echo "Downloading VAE (~350MB)..."
download_file \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors?download=true" \
  "vae" \
  "wan_2.1_vae.safetensors"

echo "Downloading RealESRGAN x2 Upscaler (~60MB)..."
download_file \
  "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x2.pth?download=true" \
  "upscale_models" \
  "RealESRGAN_x2.pth"

# Additional LoRAs from kyledam
echo ""
echo "=========================================="
echo "Downloading Additional LoRAs (kyledam)"
echo "=========================================="

echo "Downloading mql_casting_sex_spoon HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/mql_casting_sex_spoon_wan22_i2v_v1_high_noise.safetensors?download=true" \
  "loras" \
  "mql_casting_sex_spoon_wan22_i2v_v1_high_noise.safetensors"

echo "Downloading mql_casting_sex_spoon LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/mql_casting_sex_spoon_wan22_i2v_v1_low_noise.safetensors?download=true" \
  "loras" \
  "mql_casting_sex_spoon_wan22_i2v_v1_low_noise.safetensors"

echo "Downloading Blink_Squatting_Cowgirl HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/Blink_Squatting_Cowgirl_Position_I2V_HIGH.safetensors?download=true" \
  "loras" \
  "Blink_Squatting_Cowgirl_Position_I2V_HIGH.safetensors"

echo "Downloading Blink_Squatting_Cowgirl LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/Blink_Squatting_Cowgirl_Position_I2V_LOW.safetensors?download=true" \
  "loras" \
  "Blink_Squatting_Cowgirl_Position_I2V_LOW.safetensors"

echo "Downloading genitals_helper..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/genitals_helper_v1.0_e219.safetensors?download=true" \
  "loras" \
  "genitals_helper_v1.0_e219.safetensors"

echo "Downloading DR34ML4Y HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/DR34ML4Y_I2V_14B_HIGH.safetensors?download=true" \
  "loras" \
  "DR34ML4Y_I2V_14B_HIGH.safetensors"

echo "Downloading DR34ML4Y LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/DR34ML4Y_I2V_14B_LOW.safetensors?download=true" \
  "loras" \
  "DR34ML4Y_I2V_14B_LOW.safetensors"

echo "Downloading Orgasm HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/WAN-2.2-I2V-Orgasm-HIGH-v1.safetensors?download=true" \
  "loras" \
  "WAN-2.2-I2V-Orgasm-HIGH-v1.safetensors"

echo "Downloading Orgasm LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/WAN-2.2-I2V-Orgasm-LOW-v1.safetensors?download=true" \
  "loras" \
  "WAN-2.2-I2V-Orgasm-LOW-v1.safetensors"

echo "Downloading Blink_Back_Doggystyle HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Back_Doggystyle_HIGH.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Back_Doggystyle_HIGH.safetensors"

echo "Downloading Blink_Back_Doggystyle LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Back_Doggystyle_LOW.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Back_Doggystyle_LOW.safetensors"

echo "Downloading Blink_Blowjob HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGOON_Blink_Blowjob_I2V_HIGH.safetensors?download=true" \
  "loras" \
  "iGOON_Blink_Blowjob_I2V_HIGH.safetensors"

echo "Downloading Blink_Blowjob LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGOON_Blink_Blowjob_I2V_LOW.safetensors?download=true" \
  "loras" \
  "iGOON_Blink_Blowjob_I2V_LOW.safetensors"

echo "Downloading Blink_Facial HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Facial_I2V_HIGH.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Facial_I2V_HIGH.safetensors"

echo "Downloading Blink_Facial LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Facial_I2V_LOW.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Facial_I2V_LOW.safetensors"

echo "Downloading Blink_Front_Doggystyle HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Front_Doggystyle_I2V_HIGH.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Front_Doggystyle_I2V_HIGH.safetensors"

echo "Downloading Blink_Front_Doggystyle LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Front_Doggystyle_I2V_LOW.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Front_Doggystyle_I2V_LOW.safetensors"

echo "Downloading Blink_Handjob HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Handjob_I2V_HIGH.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Handjob_I2V_HIGH.safetensors"

echo "Downloading Blink_Handjob LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Handjob_I2V_LOW.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Handjob_I2V_LOW.safetensors"

echo "Downloading Blink_Missionary HIGH v2..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon_Blink_Missionary_I2V_HIGH%20v2.safetensors?download=true" \
  "loras" \
  "iGoon_Blink_Missionary_I2V_HIGH_v2.safetensors"

echo "Downloading Blink_Missionary LOW v2..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon%20-%20Blink_Missionary_I2V_LOW%20v2.safetensors?download=true" \
  "loras" \
  "iGoon_-_Blink_Missionary_I2V_LOW_v2.safetensors"

echo "Downloading Blink_Titjob HIGH..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon_Blink_Titjob_I2V_HIGH.safetensors?download=true" \
  "loras" \
  "iGoon_Blink_Titjob_I2V_HIGH.safetensors"

echo "Downloading Blink_Titjob LOW..."
download_file \
  "https://huggingface.co/kyledam/wan_lora/resolve/main/iGoon_Blink_Titjob_I2V_LOW.safetensors?download=true" \
  "loras" \
  "iGoon_Blink_Titjob_I2V_LOW.safetensors"

echo ""
if [ "$DOWNLOADER" == "aria2c" ]; then
    echo "All downloads started in parallel..."
else
    echo "Downloads started (sequential with wget)..."
    echo "This will take longer. Install aria2c for faster parallel downloads:"
    echo "  apt install -y aria2"
fi

echo "Waiting for all downloads to complete..."
wait

echo ""
echo "=========================================="
echo "Verifying Downloads"
echo "=========================================="

echo ""
echo "Diffusion Models:"
ls -lh "$MODELS_FOLDER/" 2>/dev/null || echo "Not found yet"

echo ""
echo "Text Encoders:"
ls -lh text_encoders/ 2>/dev/null || echo "Not found yet"

echo ""
echo "VAE:"
ls -lh vae/ 2>/dev/null || echo "Not found yet"

echo ""
echo "LoRAs:"
ls -lh loras/ 2>/dev/null || echo "Not found yet"

echo ""
echo "Upscale Models:"
ls -lh upscale_models/ 2>/dev/null || echo "Not found yet"

echo ""
echo "=========================================="
echo "Download Complete!"
echo "=========================================="
echo ""
echo "Downloaded: QuantStack Official (A14B)"
echo ""
echo "Total Size: ~32GB + Additional LoRAs: ~10GB"
echo "Grand Total: ~42GB"
echo "=========================================="
