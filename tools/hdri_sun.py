#!/usr/bin/env python3
"""Locates the sun in an equirectangular Radiance (.hdr) sky.

Godot's panorama mapping is

    u = atan2(dir.x, -dir.z) / (2 * pi) + 0.5
    v = acos(dir.y) / pi

so the brightest pixel can be turned back into a world direction. The fetch
script stores the result next to the HDRI and EnvBuilder rotates the sky so the
HDRI sun lines up with the DirectionalLight3D (one sun, one shadow).

    python3 tools/hdri_sun.py assets/hdri/sky.hdr assets/hdri/sun.json

Pure Python (zlib not needed): the Radiance RGBE format is decoded by hand.
"""

import json
import math
import os
import sys


def _read_header(raw):
    """Returns (width, height, offset) after the Radiance header."""
    pos = 0
    lines = []
    while True:
        nl = raw.find(b"\n", pos)
        if nl < 0:
            raise ValueError("truncated header")
        line = raw[pos:nl].rstrip(b"\r")
        pos = nl + 1
        if not line:
            break
        lines.append(line)
    if not lines or not lines[0].startswith(b"#?"):
        raise ValueError("not a Radiance HDR file")
    nl = raw.find(b"\n", pos)
    if nl < 0:
        raise ValueError("missing resolution line")
    res = raw[pos:nl].split()
    if len(res) != 4 or res[0] != b"-Y" or res[2] != b"+X":
        raise ValueError("unsupported resolution line: %r" % (res,))
    return int(res[3]), int(res[1]), nl + 1


def find_sun(path):
    """Returns (azimuth_deg, elevation_deg, has_sun) for the brightest pixel."""
    raw = open(path, "rb").read()
    w, h, pos = _read_header(raw)

    best = -1.0
    best_xy = (0, 0)
    total = 0.0
    count = 0

    for y in range(h):
        if pos + 4 > len(raw):
            break
        rle = raw[pos] == 2 and raw[pos + 1] == 2 and (raw[pos + 2] & 0x80) == 0
        if rle:
            line_w = (raw[pos + 2] << 8) | raw[pos + 3]
            pos += 4
            if line_w != w:
                raise ValueError("bad scanline width %d != %d" % (line_w, w))
            chans = []
            for _c in range(4):
                row = bytearray(w)
                x = 0
                while x < w:
                    n = raw[pos]
                    pos += 1
                    if n > 128:
                        run = n - 128
                        val = raw[pos]
                        pos += 1
                        row[x:x + run] = bytes([val]) * run
                        x += run
                    else:
                        row[x:x + n] = raw[pos:pos + n]
                        pos += n
                        x += n
                chans.append(row)
            row_px = [(chans[0][x], chans[1][x], chans[2][x], chans[3][x])
                      for x in range(w)]
        else:
            row_px = []
            for _x in range(w):
                r, g, b, e = raw[pos:pos + 4]
                pos += 4
                row_px.append((r, g, b, e))

        for x, (r, g, b, e) in enumerate(row_px):
            if e == 0:
                continue
            lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) * (2.0 ** (e - 128))
            total += lum
            count += 1
            if lum > best:
                best = lum
                best_xy = (x, y)

    if best <= 0.0 or count == 0:
        return 0.0, 45.0, False

    mean = total / count
    has_sun = best > mean * 8.0

    x, y = best_xy
    u = (x + 0.5) / w
    v = (y + 0.5) / h
    theta = (u - 0.5) * 2.0 * math.pi
    # Direction on the unit sphere, Godot convention (+Z forward, +X right).
    dx = math.sin(theta)
    dz = -math.cos(theta)
    azimuth = math.degrees(math.atan2(dx, dz))
    elevation = 90.0 - v * 180.0
    return azimuth, elevation, has_sun


def main(argv):
    if len(argv) < 2:
        print("usage: hdri_sun.py <sky.hdr> [out.json] [source-id]")
        return 2
    src = argv[1]
    out = argv[2] if len(argv) > 2 else os.path.splitext(src)[0] + "_sun.json"
    source = argv[3] if len(argv) > 3 else os.path.splitext(os.path.basename(src))[0]
    azimuth, elevation, has_sun = find_sun(src)
    data = {
        "source": source,
        "azimuth_deg": round(azimuth, 2),
        "elevation_deg": round(elevation, 2),
        "has_sun": has_sun,
    }
    with open(out, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print("sun ->", out, data)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
