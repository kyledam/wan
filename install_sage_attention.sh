#!/bin/bash

echo "=========================================="
echo "ComfyUI + SageAttention 2.2 Setup (FINAL FIX)"
echo "For RTX 5070 Ti + CUDA 12.8 + PyTorch 2.8"
echo "Ubuntu 24.04 + Python 3.12"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install base packages
echo "Installing base packages..."
apt install -y build-essential git wget cmake pkg-config ninja-build unzip aria2 fuser supervisor

echo "System Python version: $(python3 --version)"

# Set up workspace
mkdir -p /workspace && cd /workspace

# --- FIX LOGIC GIT (CHẾ ĐỘ FORCE OVERWRITE) ---
if [ ! -d "ComfyUI/.git" ]; then
    echo "ComfyUI folder found but not a git repo. Initializing..."
    
    # Tạo folder nếu chưa có
    mkdir -p ComfyUI
    cd ComfyUI
    
    # Init git
    git init
    git remote remove origin 2>/dev/null || true
    git remote add origin https://github.com/comfyanonymous/ComfyUI.git
    git fetch origin
    
    # QUAN TRỌNG: Thêm flag -f (force) để ghi đè file trùng
    echo "Force checking out master..."
    git checkout -f -B master origin/master
else
    echo "ComfyUI already exists and is a git repo, forcing update..."
    cd ComfyUI
    
    git remote set-url origin https://github.com/comfyanonymous/ComfyUI.git 2>/dev/null
    git fetch origin
    
    # QUAN TRỌNG: Dùng reset --hard thay vì pull để đè bẹp mọi xung đột
    # Nó sẽ khiến local giống hệt remote, bỏ qua lỗi "untracked files"
    echo "Resetting hard to origin/master..."
    git reset --hard origin/master
fi

# Đảm bảo đang ở trong folder ComfyUI
cd /workspace/ComfyUI

# Create and activate Python 3.12 virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

echo "Virtualenv Python version: $(python --version)"

# Upgrade pip
pip install --upgrade pip

echo "=========================================="
echo "Installing PyTorch 2.8.0 + CUDA 12.8"
echo "=========================================="

# Install PyTorch
pip install torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu128

echo "=========================================="
echo "Installing Triton + SageAttention 2.2"
echo "=========================================="

pip install triton --pre
pip install packaging

# Download and install SageAttention 2.2
cd /workspace
if [ ! -f "sageattention-2.2.0-cp312-cp312-linux_x86_64.whl" ]; then
    echo "Downloading SageAttention 2.2 wheel..."
    wget https://huggingface.co/Ovidijusk80/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl/resolve/main/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
fi

echo "Installing SageAttention 2.2..."
pip install ./sageattention-2.2.0-cp312-cp312-linux_x86_64.whl

echo "=========================================="
echo "Verifying Installation"
echo "=========================================="

python -c "import torch; print('✓ PyTorch:', torch.__version__)"
python -c "import torch; print('✓ CUDA:', torch.version.cuda)"
python -c "import sageattention; print('✓ SageAttention: 2.2.0 installed')"

echo "=========================================="
echo "Installing ComfyUI Requirements"
echo "=========================================="

cd /workspace/ComfyUI
pip install -r requirements.txt

echo "=========================================="
echo "Downloading Custom Nodes Backup"
echo "=========================================="

cd /workspace/ComfyUI

if [ -d "custom_nodes" ]; then
    echo "Backing up existing custom_nodes..."
    mv custom_nodes custom_nodes.backup.$(date +%Y%m%d_%H%M%S)
fi

echo "Downloading custom nodes from HuggingFace..."
wget -O custom_nodes_backup.tar.gz "https://huggingface.co/kyledam/wan_lora/resolve/main/custom_nodes_backup.tar.gz"

if [ ! -f "custom_nodes_backup.tar.gz" ]; then
    echo "Error: Failed to download custom nodes backup"
    exit 1
fi

echo "Extracting custom nodes..."
tar -xzf custom_nodes_backup.tar.gz

if [ ! -d "custom_nodes" ]; then
    echo "Error: Extraction failed"
    exit 1
fi

echo "Installing dependencies for all custom nodes..."
cd custom_nodes

for dir in */; do
    if [ -f "$dir/requirements.txt" ]; then
        echo "Installing dependencies for $dir..."
        pip install -r "$dir/requirements.txt" 2>/dev/null || echo "Warning: Some dependencies for $dir may have failed"
    fi
done

echo "Installing common dependencies..."
pip install soundfile librosa pydub gitpython

cd /workspace/ComfyUI
rm -f custom_nodes_backup.tar.gz

echo ""
echo "Custom nodes installed:"
ls -1 custom_nodes/ | head -20
echo ""

echo "=========================================="
echo "Setting up Supervisor"
echo "=========================================="

cat > /etc/supervisor/conf.d/comfyui.conf << 'SUPEOF'
[program:comfyui]
command=/workspace/ComfyUI/venv/bin/python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 3001 --enable-cors-header
directory=/workspace/ComfyUI
user=root
autostart=true
autorestart=true
startretries=999
redirect_stderr=true
stdout_logfile=/var/log/supervisor/comfyui.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile=/var/log/supervisor/comfyui_error.log
environment=PATH="/workspace/ComfyUI/venv/bin:%(ENV_PATH)s",VIRTUAL_ENV="/workspace/ComfyUI/venv"
stopwaitsecs=60
SUPEOF

mkdir -p /var/log/supervisor
supervisorctl reread
supervisorctl update

echo "Starting ComfyUI..."
supervisorctl start comfyui

sleep 3
echo "ComfyUI Status:"
supervisorctl status comfyui
echo ""
echo "ACCESS URL: http://YOUR_IP:3001"
