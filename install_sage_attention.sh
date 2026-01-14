#!/bin/bash

echo "=========================================="
echo "ComfyUI + SageAttention 2.2 Setup (ANTI-LAG)"
echo "For RTX 5070 Ti + CUDA 12.8 + PyTorch 2.8"
echo "Ubuntu 24.04 + Python 3.12"
echo "=========================================="

# Update system packages
apt update && apt upgrade -y
apt install -y build-essential git wget cmake pkg-config ninja-build unzip aria2 fuser supervisor

mkdir -p /workspace && cd /workspace

# --- FIX GIT MẠNG LAG (QUAN TRỌNG) ---
# Cấu hình Git để chịu được mạng yếu
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

if [ ! -d "ComfyUI/.git" ]; then
    echo "ComfyUI folder found but not a git repo. Initializing..."
    mkdir -p ComfyUI && cd ComfyUI
    git init
    git remote remove origin 2>/dev/null || true
    git remote add origin https://github.com/comfyanonymous/ComfyUI.git
else
    echo "ComfyUI repo exists. Updating..."
    cd ComfyUI
    git remote set-url origin https://github.com/comfyanonymous/ComfyUI.git 2>/dev/null
fi

# VÒNG LẶP RETRY (Thử 5 lần nếu mạng đứt)
echo "Fetching ComfyUI source code (Depth 1)..."
n=0
until [ "$n" -ge 5 ]
do
   # Dùng depth 1 để tải cho nhẹ, đỡ bị disconnect
   git fetch --depth 1 origin master && break
   n=$((n+1))
   echo "Fetch failed. Retrying ($n/5)..."
   sleep 5
done

if [ "$n" -ge 5 ]; then
   echo "ERROR: Failed to fetch ComfyUI after 5 attempts. Check internet connection."
   exit 1
fi

# Reset cứng về code mới nhất
echo "Force resetting to latest code..."
git checkout -f -B master origin/master
git reset --hard origin/master

# --- TIẾP TỤC CÀI ĐẶT ---
cd /workspace/ComfyUI

if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip

echo "Installing PyTorch 2.8.0 + CUDA 12.8..."
pip install torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu128

echo "Installing SageAttention..."
pip install triton --pre packaging
cd /workspace
if [ ! -f "sageattention-2.2.0-cp312-cp312-linux_x86_64.whl" ]; then
    wget https://huggingface.co/Ovidijusk80/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl/resolve/main/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
fi
pip install ./sageattention-2.2.0-cp312-cp312-linux_x86_64.whl

echo "Installing ComfyUI Requirements..."
cd /workspace/ComfyUI
pip install -r requirements.txt

echo "Downloading Custom Nodes..."
if [ -d "custom_nodes" ]; then
    mv custom_nodes custom_nodes.backup.$(date +%Y%m%d_%H%M%S)
fi
wget -O custom_nodes_backup.tar.gz "https://huggingface.co/kyledam/wan_lora/resolve/main/custom_nodes_backup_v4.tar.gz"
tar -xzf custom_nodes_backup.tar.gz
rm custom_nodes_backup.tar.gz

echo "Installing custom node dependencies..."
cd custom_nodes
for dir in */; do
    if [ -f "$dir/requirements.txt" ]; then
        pip install -r "$dir/requirements.txt" 2>/dev/null
    fi
done

pip install soundfile librosa pydub gitpython

echo "Setting up Supervisor..."
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
supervisorctl start comfyui

echo "INSTALLATION COMPLETE. Access at http://YOUR_IP:3001"





