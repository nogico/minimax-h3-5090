#!/usr/bin/env bash

set -euo pipefail

echo "=========================================="
echo " RTX 5090 MiniMax H3 container starting"
echo "=========================================="

echo
echo "[1/4] Checking GPU..."

python - <<'PY'
import torch

print("PyTorch:", torch.__version__)
print("CUDA runtime:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if not torch.cuda.is_available():
    raise RuntimeError("CUDA GPU was not detected")

print("GPU:", torch.cuda.get_device_name(0))

props = torch.cuda.get_device_properties(0)
print("VRAM:", round(props.total_memory / 1024**3, 2), "GB")
PY

echo
echo "[2/4] Downloading/checking MiniMax H3 models..."

python /opt/download_models.py

echo
echo "[3/4] Models ready."

echo
echo "[4/4] Starting ComfyUI on port 8188..."

cd /opt/ComfyUI

exec python main.py \
    --listen \
    --port 8188
