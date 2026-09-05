#!/usr/bin/env bash

set -euo pipefail

echo "=========================================="
echo " RTX 5090 MiniMax H3 container starting"
echo "=========================================="

PERSIST_ROOT="${PERSIST_ROOT:-/workspace}"

echo
echo "[1/5] Checking persistent storage at ${PERSIST_ROOT}..."

if mountpoint -q "${PERSIST_ROOT}" 2>/dev/null || [ -d "${PERSIST_ROOT}" ]; then
    echo "Persistent storage found."

    export MODEL_ROOT="${PERSIST_ROOT}/models"
    export HF_HOME="${PERSIST_ROOT}/hf-cache"

    mkdir -p "${MODEL_ROOT}" \
             "${HF_HOME}" \
             "${PERSIST_ROOT}/output" \
             "${PERSIST_ROOT}/input" \
             "${PERSIST_ROOT}/user"

    # Point ComfyUI's dirs at the volume (idempotent: safe on every restart)
    for d in models output input user; do
        src="/opt/ComfyUI/${d}"
        dst="${PERSIST_ROOT}/${d}"
        if [ ! -L "${src}" ]; then
            rm -rf "${src}"
            ln -s "${dst}" "${src}"
        fi
    done

    echo "MODEL_ROOT = ${MODEL_ROOT}"
    echo "HF_HOME    = ${HF_HOME}"
    df -h "${PERSIST_ROOT}" | tail -n 1
else
    echo "WARNING: ${PERSIST_ROOT} not found - falling back to container disk."
    echo "Models will be re-downloaded on every start (~45 GB)."
    export MODEL_ROOT="/opt/ComfyUI/models"
fi

echo
echo "[2/5] Checking GPU..."

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
echo "[3/5] Downloading/checking MiniMax H3 models..."

python /opt/download_models.py

echo
echo "[4/5] Models ready."

echo
echo "[5/5] Starting ComfyUI on port 8188..."

cd /opt/ComfyUI

exec python main.py \
    --listen \
    --port 8188
