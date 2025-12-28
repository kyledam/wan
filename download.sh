#!/bin/bash

# Kiểm tra xem có aria2c chưa, nếu chưa thì đợi (vì lệnh start bên dưới sẽ cài)
echo "Dang cho aria2c duoc cai dat..."
while ! command -v aria2c &> /dev/null; do
    sleep 5
done
echo "Da tim thay aria2c! Bat dau download..."

# Set downloader cố định
DOWNLOADER="aria2c"

# Tạo thư mục gốc
mkdir -p /workspace/ComfyUI/models
cd /workspace/ComfyUI/models || { echo "Khong the cd vao folder models!"; exit 1; }

# Tạo các folder con
mkdir -p diffusion_models text_encoders vae loras upscale_models

# Hàm download
download_file() {
    local url="$1"
    local output_dir="$2"
    local output_file="$3"
    
    mkdir -p "$output_dir"
    
    # Check xem file đã tải xong chưa để tránh tải lại
    if [ -f "$output_dir/$output_file" ]; then
        echo "File $output_file da ton tai, bo qua."
        return
    fi
    
    # -x 16: Max connections
    # --allow-overwrite=true: Cho phép ghi đè nếu file lỗi
    aria2c -x 16 -s 16 -k 1M --allow-overwrite=true -d "$output_dir" -o "$output_file" "$url" &
}

# --- BẮT ĐẦU LIST DOWNLOAD CỦA MÀY ---
# (Phần bên dưới giữ nguyên danh sách link mày đã có, tao chỉ ví dụ vài cái đầu)

mkdir -p "diffusion_models/wan22_quantstack_a14b"

echo "Downloading QuantStack High Noise..."
download_file "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf?download=true" "diffusion_models/wan22_quantstack_a14b" "Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"

echo "Downloading QuantStack Low Noise..."
download_file "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf?download=true" "diffusion_models/wan22_quantstack_a14b" "Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"

# ... (Paste tiếp toàn bộ đoạn download lora/vae của mày vào đây) ...

# CHỐT HẠ: Đợi tất cả download xong
wait
echo "Download hoan tat!"
