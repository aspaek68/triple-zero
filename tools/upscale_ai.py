#!/usr/bin/env python3
"""Upscales the game's PBR textures.

* Albedo maps  -> Real-ESRGAN (ncnn-vulkan), 2x, tiled for small GPUs.
* Normal / roughness / AO / metal maps -> Lanczos 2x (Pillow). AI upscalers
  invent detail that corrupts normal vectors, so data maps stay filtered.

Originals are kept in git, so `git checkout -- assets/textures` restores them.

Usage:
    python tools/upscale_ai.py                 # 2x, both sets
    python tools/upscale_ai.py --factor 4      # 4x
    python tools/upscale_ai.py --only textures # only generated textures
    python tools/upscale_ai.py --lanczos-only  # skip ESRGAN entirely
"""
import argparse
import os
import subprocess
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SETS = ["assets/textures", "assets/textures_cc0"]
BIN = os.path.join(ROOT, "tools", "realesrgan", "realesrgan-ncnn-vulkan.exe")
DATA_SUFFIXES = ("_normal", "_rough", "_ao", "_metal", "_orm")


def is_data_map(name: str) -> bool:
    stem = os.path.splitext(name)[0].lower()
    return stem.endswith(DATA_SUFFIXES)


def esrgan(src: str, dst: str, scale: int) -> bool:
    if not os.path.exists(BIN):
        return False
    cmd = [BIN, "-i", src, "-o", dst, "-s", str(scale),
           "-n", "realesrgan-x4plus", "-t", "128", "-f", "png"]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True, timeout=600)
        return os.path.exists(dst)
    except Exception as e:
        print("  ESRGAN failed:", e, file=sys.stderr)
        return False


def lanczos(src: str, dst: str, scale: int) -> bool:
    try:
        im = Image.open(src)
        im = im.convert("RGB")
        im.resize((im.width * scale, im.height * scale), Image.LANCZOS).save(dst)
        return True
    except Exception as e:
        print("  Lanczos failed:", e, file=sys.stderr)
        return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--factor", type=int, default=2, choices=[2, 3, 4])
    ap.add_argument("--only", default="")
    ap.add_argument("--lanczos-only", action="store_true")
    args = ap.parse_args()

    ai_ok = os.path.exists(BIN) and not args.lanczos_only
    if not ai_ok:
        print("Real-ESRGAN unavailable -> Lanczos everywhere.")

    total = 0
    for rel in SETS:
        if args.only and args.only not in rel:
            continue
        d = os.path.join(ROOT, rel)
        if not os.path.isdir(d):
            continue
        print("==", rel)
        for fn in sorted(os.listdir(d)):
            if not fn.lower().endswith((".png", ".jpg", ".jpeg")):
                continue
            src = os.path.join(d, fn)
            tmp = src + ".upscaled.png"
            data_map = is_data_map(fn)
            ok = False
            if ai_ok and not data_map:
                print("  ESRGAN  ", fn, flush=True)
                ok = esrgan(src, tmp, args.factor)
            if not ok:
                print("  lanczos ", fn, flush=True)
                ok = lanczos(src, tmp, args.factor)
            if ok and os.path.exists(tmp):
                os.replace(tmp, src)
                total += 1
            elif os.path.exists(tmp):
                os.remove(tmp)
    print("done:", total, "textures upscaled")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
