import os
from huggingface_hub import hf_hub_download

REPO_ID = "Comfy-Org/MiniMax-H3"
MODEL_ROOT = "/opt/ComfyUI/models"

FILES = [
    
    "diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors",

    
    "text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors",

  
    "vae/minimax_h3_video_vae_fp16.safetensors",


    "vae/minimax_h3_audio_vae_fp32.safetensors",

    "loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors",
]

token = os.environ.get("HF_TOKEN")

print("=" * 60)
print("MiniMax H3 model download starting")
print("=" * 60)

for filename in FILES:
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
