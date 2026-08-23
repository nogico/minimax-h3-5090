FROM pytorch/pytorch:2.10.0-cuda13.0-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/opt/hf-cache \
    HF_XET_HIGH_PERFORMANCE=1 \
    COMFYUI_PATH=/opt/ComfyUI

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    ffmpeg \
    curl \
    wget \
    ca-certificates \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone \
    --branch v0.33.1 \
    --depth 1 \
    https://github.com/Comfy-Org/ComfyUI.git

WORKDIR /opt/ComfyUI

RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install -r requirements.txt && \
    python -m pip install "huggingface_hub[hf_xet]"

COPY download_models.py /opt/download_models.py
COPY start.sh /opt/start.sh

RUN chmod +x /opt/start.sh

EXPOSE 8188

WORKDIR /opt/ComfyUI

CMD ["/opt/start.sh"]
