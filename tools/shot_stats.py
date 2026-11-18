#!/usr/bin/env python3
"""Quick visual metrics for a screenshot, plus a coarse ASCII preview.

The point is to catch regressions objectively without opening the image:
a flat/hazy frame has a low standard deviation, a broken one is black or
blown out.

    python tools/shot_stats.py screenshots/acte1.png [--ascii]
"""
import sys

from PIL import Image

RAMP = " .:-=+*#%@"


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print(__doc__)
        return 1
    show_ascii = "--ascii" in sys.argv
    for path in args:
        im = Image.open(path).convert("RGB")
        g = im.convert("L")
        hist = g.histogram()
        total = sum(hist)
        mean = sum(i * n for i, n in enumerate(hist)) / total
        var = sum(n * (i - mean) ** 2 for i, n in enumerate(hist)) / total
        std = var ** 0.5
        black = sum(hist[:6]) / total * 100
        blown = sum(hist[251:]) / total * 100
        dark = sum(hist[:64]) / total * 100
        light = sum(hist[192:]) / total * 100
        print("%-28s %dx%d mean=%5.1f std=%5.1f noir=%4.1f%% sombre=%4.1f%% "
              "clair=%4.1f%% cramé=%4.1f%%" % (path, im.width, im.height, mean,
                                               std, black, dark, light, blown))
        if show_ascii:
            small = g.resize((64, 24), Image.LANCZOS)
            for y in range(24):
                print("  " + "".join(RAMP[min(9, small.getpixel((x, y)) * 10 // 256)]
                                     for x in range(64)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
