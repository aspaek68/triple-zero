#!/usr/bin/env python3
"""Rewrites the texture .import files for 3D use.

Godot's default import for a PNG is *lossless, no mipmaps, 2D*. These maps are
sampled by 3D materials, so:

* `compress/mode=2`      -> VRAM compressed (BPTC/BC7): ~4x less video memory
                            and no runtime reimport when the texture is used in 3D
* `mipmaps/generate=true` -> no shimmering on distant surfaces (anisotropic
                            filtering needs mipmaps)
* `compress/normal_map=1` -> normal maps are compressed with 2 channels, which
                            keeps the reconstructed Z sane
* `detect_3d/compress_to=0` -> stop Godot from silently reimporting mid-game

Run it, then `godot --headless --path . --import` to rebuild the cache.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SETS = ["assets/textures", "assets/textures_cc0"]

WANT = {
    "compress/mode": "2",
    "compress/high_quality": "true",
    "mipmaps/generate": "true",
    "mipmaps/limit": "-1",
    "detect_3d/compress_to": "0",
}


def patch(path: str, is_normal: bool) -> bool:
    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()
    original = text
    for key, val in WANT.items():
        text = re.sub(r"^%s=.*$" % re.escape(key), "%s=%s" % (key, val),
                      text, flags=re.MULTILINE)
    if is_normal:
        text = re.sub(r"^compress/normal_map=.*$", "compress/normal_map=1",
                      text, flags=re.MULTILINE)
    if text != original:
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(text)
        return True
    return False


def main() -> int:
    changed = 0
    for rel in SETS:
        d = os.path.join(ROOT, rel)
        if not os.path.isdir(d):
            continue
        for fn in sorted(os.listdir(d)):
            if not fn.endswith(".png.import"):
                continue
            normal = fn.replace(".png.import", "").lower().endswith("_normal")
            if patch(os.path.join(d, fn), normal):
                changed += 1
    print("patched", changed, "import files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
