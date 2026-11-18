#!/usr/bin/env python3
"""AI upscaling of textures using Real-ESRGAN (ncnn-vulkan binary).

Falls back to Lanczos if the binary is missing.

Usage:
    python tools/upscale_ai.py                  # 2x, all sets
    python tools/upscale_ai.py --factor 4       # 4x
    python tools/upscale_ai.py --only textures  # only generated textures
"""
import argparse
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SETS = ["assets/textures", "assets/textures_cc0"]
BIN = os.path.join(ROOT, "tools", "realesrgan", "realesrgan-ncnn-vulkan.exe")


def upscale_one(src: str, dst: str, scale: int) -> bool:
    if not os.path.exists(BIN):
        return False
    cmd = [BIN, "-i", src, "-o", dst, "-s", str(scale), "-n", "realesrgan-x4plus"]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True, timeout=120)
        return os.path.exists(dst)
    except Exception as e:
        print("AI upscale failed:", e, file=sys.stderr)
        return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--factor", type=int, default=2, choices=[2, 4])
    ap.add_argument("--only", default="")
    args = ap.parse_args()

    if not os.path.exists(BIN):
        print("Real-ESRGAN binary not found at", BIN, file=sys.stderr)
        print("Falling back to Lanczos (upscale_textures.py).", file=sys.stderr)
        return 1

    for rel in SETS:
        if args.only and args.only not in rel:
            continue
        d = os.path.join(ROOT, rel)
        if not os.path.isdir(d):
            continue
        for fn in os.listdir(d):
            if not fn.lower().endswith((".png", ".jpg", ".jpeg")):
                continue
            src = os.path.join(d, fn)
            tmp = src + ".tmp.png"
            if upscale_one(src, tmp, args.factor):
                os.replace(tmp, src)
                print("AI-upscaled", rel + "/" + fn)
            else:
                if os.path.exists(tmp):
                    os.remove(tmp)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
