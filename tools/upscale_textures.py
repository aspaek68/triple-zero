#!/usr/bin/env python3
"""Upscales the game's textures with high-quality Lanczos resampling.

This is a pure-Pillow fallback (no AI upscaler). It doubles (or Nx) the
resolution of every PNG/JPG in assets/textures* so the engine imports
higher-resolution maps. Real-ESRGAN would be better but needs torch, which
is not available on this machine.

Usage:
    python tools/upscale_textures.py            # 2x, all sets
    python tools/upscale_textures.py --factor 4 # 4x
    python tools/upscale_textures.py --only textures_cc0
"""
import argparse
import os

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SETS = ["assets/textures", "assets/textures_cc0"]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--factor", type=int, default=2)
    ap.add_argument("--only", default="")
    args = ap.parse_args()

    for rel in SETS:
        if args.only and args.only not in rel:
            continue
        d = os.path.join(ROOT, rel)
        if not os.path.isdir(d):
            continue
        for fn in os.listdir(d):
            if not fn.lower().endswith((".png", ".jpg", ".jpeg")):
                continue
            path = os.path.join(d, fn)
            try:
                img = Image.open(path)
                w, h = img.size
                new = img.resize((w * args.factor, h * args.factor), Image.LANCZOS)
                new.save(path, quality=95) if path.lower().endswith((".jpg", ".jpeg")) else new.save(path)
                print("upscaled", rel + "/" + fn, "%dx%d -> %dx%d" % (w, h, w * args.factor, h * args.factor))
            except Exception as e:
                print("FAIL", path, e)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
