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

cd /workspace/ComfyUI/models

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
ls -lh "$MODELS_FOLDER/"

echo ""
echo "Text Encoders:"
ls -lh text_encoders/

echo ""
echo "VAE:"
ls -lh vae/

echo ""
echo "LoRAs:"
ls -lh loras/

echo ""
echo "Upscale Models:"
ls -lh upscale_models/

echo ""
echo "=========================================="
echo "Download Complete!"
echo "=========================================="
echo ""
echo "Downloaded: QuantStack Official (A14B)"
echo ""
echo "Model Structure:"
echo "ComfyUI/models/"
echo "├── diffusion_models/wan22_quantstack_a14b/"
echo "│   ├── Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf (~13GB)"
echo "│   └── Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf (~13GB)"
echo "├── text_encoders/"
echo "│   └── umt5_xxl_fp8_e4m3fn_scaled.safetensors (~5GB)"
echo "├── loras/"
echo "│   ├── Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors (~1.2GB)"
echo "│   ├── mql_casting_sex_spoon_wan22_i2v_v1_high_noise.safetensors"
echo "│   ├── mql_casting_sex_spoon_wan22_i2v_v1_low_noise.safetensors"
echo "│   ├── Blink_Squatting_Cowgirl_Position_I2V_HIGH.safetensors"
echo "│   └── Blink_Squatting_Cowgirl_Position_I2V_LOW.safetensors"
echo "├── vae/"
echo "│   └── wan_2.1_vae.safetensors (~350MB)"
echo "└── upscale_models/"
echo "    └── RealESRGAN_x2.pth (~60MB)"
echo ""
echo "Workflow Settings:"
echo "- Select models in 'wan22_quantstack_a14b' folder"
echo "- Use Wan2.1 Lightning LoRA with strength: High=3.0, Low=1.5"
echo ""
echo "=========================================="
echo "Total Size: ~32GB + Additional LoRAs: ~4GB"
echo "Grand Total: ~36GB"
echo "=========================================="