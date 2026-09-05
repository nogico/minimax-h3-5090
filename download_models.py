import os
import shutil

from huggingface_hub import hf_hub_download

REPO_ID = "Comfy-Org/MiniMax-H3"
MODEL_ROOT = os.environ.get("MODEL_ROOT", "/opt/ComfyUI/models")

FILES = [
    "diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors",
    "text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors",
    "vae/minimax_h3_video_vae_fp16.safetensors",
    "vae/minimax_h3_audio_vae_fp32.safetensors",
    "loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors",
]

# Approximate download sizes, only used for the pre-flight disk space check.
APPROX_TOTAL_GB = 45

token = os.environ.get("HF_TOKEN")

print("=" * 60)
print("MiniMax H3 model download")
print("Target directory:", MODEL_ROOT)
print("=" * 60)

os.makedirs(MODEL_ROOT, exist_ok=True)

missing = [f for f in FILES if not os.path.exists(os.path.join(MODEL_ROOT, f))]

if missing:
    free_gb = shutil.disk_usage(MODEL_ROOT).free / 1024**3
    print(f"\n{len(missing)} file(s) missing. Free space: {free_gb:.1f} GiB")

    if free_gb < APPROX_TOTAL_GB:
        print(
            f"WARNING: less than ~{APPROX_TOTAL_GB} GiB free. "
            "The download may fail - increase the volume size."
        )

for filename in FILES:
    target = os.path.join(MODEL_ROOT, filename)

    if os.path.exists(target):
        size_gb = os.path.getsize(target) / 1024**3
        print(f"\nCached: {filename} ({size_gb:.2f} GiB) - skipping")
        continue

    print(f"\nDownloading: {filename}")

    path = hf_hub_download(
        repo_id=REPO_ID,
        filename=filename,
        local_dir=MODEL_ROOT,
        token=token if token else None,
    )

    print(f"Ready: {path}")

print("\n" + "=" * 60)
print("All MiniMax H3 models are ready")
print("=" * 60)
