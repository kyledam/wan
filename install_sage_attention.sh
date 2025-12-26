#!/bin/bash

echo "=========================================="
echo "ComfyUI + SageAttention 2.2 Setup"
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

# Clone ComfyUI if not exists
if [ ! -d "ComfyUI" ]; then
    echo "Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git
else
    echo "ComfyUI already exists, updating..."
    cd ComfyUI && git pull && cd ..
fi

cd ComfyUI

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

# Install PyTorch 2.8.0 with CUDA 12.8 (matching your system)
pip install torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu128

echo "=========================================="
echo "Installing Triton + SageAttention 2.2"
echo "=========================================="

# Install Triton (nightly for RTX 50xx Blackwell support)
pip install triton --pre

# Install packaging
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
python -c "import torch; print('✓ CUDA available:', torch.cuda.is_available())"
python -c "import torch; print('✓ GPU:', torch.cuda.get_device_name(0))"
python -c "import torch; print('✓ Compute Capability:', torch.cuda.get_device_capability())"
python -c "import triton; print('✓ Triton:', triton.__version__)"
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

# Backup existing custom_nodes if exists
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

# Install common dependencies
echo "Installing common dependencies..."
pip install soundfile librosa pydub gitpython

cd /workspace/ComfyUI

# Clean up
rm -f custom_nodes_backup.tar.gz

echo ""
echo "Custom nodes installed:"
ls -1 custom_nodes/ | head -20
echo ""

echo "=========================================="
echo "Setting up Supervisor for Auto-Restart"
echo "=========================================="

# Create supervisor config for ComfyUI
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

# Create log directory
mkdir -p /var/log/supervisor

# Reload supervisor
supervisorctl reread
supervisorctl update

echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "System Configuration:"
echo "- OS: Ubuntu 24.04 LTS"
echo "- Python: 3.12.11"
echo "- PyTorch: 2.8.0"
echo "- CUDA: 12.8"
echo "- GPU: RTX 5070 Ti (16GB)"
echo "- SageAttention: 2.2.0"
echo "- Supervisor: Installed & Configured"
echo ""
echo "Custom Nodes: Restored from kyledam/wan_lora backup"
echo ""
echo "=========================================="
echo "Starting ComfyUI with Supervisor..."
echo "=========================================="

supervisorctl start comfyui

sleep 3

echo ""
echo "ComfyUI Status:"
supervisorctl status comfyui
echo ""
echo "=========================================="
echo "Access ComfyUI:"
echo "=========================================="
echo ""
echo "URL: http://YOUR_IP:3001"
echo ""
echo "Supervisor Commands:"
echo "- Check status:  supervisorctl status comfyui"
echo "- Restart:       supervisorctl restart comfyui"
echo "- Stop:          supervisorctl stop comfyui"
echo "- View logs:     tail -f /var/log/supervisor/comfyui.log"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Download models:"
echo "   cd /workspace/ComfyUI/models"
echo "   ./download_wan22_models.sh"
echo ""
echo "2. ComfyUI will auto-start and auto-restart"
echo "   No manual start needed!"
echo ""
echo "3. Load workflow and configure:"
echo "   - SageAttention mode: sageattn_qk_int8_pv_fp8_cuda"
echo "   - Resolution: 720x480 or 640x384"
echo "   - Frames: 49-81"
echo ""
echo "=========================================="