#!/usr/bin/env python3
"""Generates the game's placeholder assets into assets/.

Everything is produced from pure Python (zlib for PNG, the wave module for
WAV), so the tool has no third-party dependencies. Re-run it any time to
regenerate: the files are deterministic.

    python3 tools/gen_assets.py

Real art and audio can later replace these files in place; the game falls
back to its own procedural material/audio when a file is missing.
"""

import math
import os
import struct
import wave
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEX_DIR = os.path.join(ROOT, "assets", "textures")
AUD_DIR = os.path.join(ROOT, "assets", "audio")


# --------------------------------------------------------------------- PNG

def _chunk(tag: bytes, data: bytes) -> bytes:
    return (struct.pack(">I", len(data)) + tag + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))


def write_png(path: str, width: int, height: int, pixels) -> None:
    """`pixels` is a callable (x, y) -> (r, g, b) with 0..255 components."""
    raw = bytearray()
    for y in range(height):
        raw.append(0)  # filter type: none
        for x in range(width):
            raw.extend(pixels(x, y))
    png = b"\x89PNG\r\n\x1a\n"
    png += _chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += _chunk(b"IEND", b"")
    with open(path, "wb") as fh:
        fh.write(png)


def _hash(x: int, y: int, seed: int) -> float:
    """Deterministic pseudo-random value in 0..1 for a pixel coordinate."""
    h = (x * 374761393 + y * 668265263 + seed * 2246822519) & 0xFFFFFFFF
    h = (h ^ (h >> 13)) * 1274126177 & 0xFFFFFFFF
    return ((h ^ (h >> 16)) & 0xFFFF) / 65535.0


def _clamp(v: float) -> int:
    return max(0, min(255, int(v)))


def smooth_noise(x: int, y: int, scale: int, seed: int) -> float:
    """Bilinear value noise, so textures look organic instead of pure grain."""
    gx, gy = x / scale, y / scale
    x0, y0 = int(gx), int(gy)
    tx, ty = gx - x0, gy - y0
    tx = tx * tx * (3 - 2 * tx)
    ty = ty * ty * (3 - 2 * ty)
    v00 = _hash(x0, y0, seed)
    v10 = _hash(x0 + 1, y0, seed)
    v01 = _hash(x0, y0 + 1, seed)
    v11 = _hash(x0 + 1, y0 + 1, seed)
    top = v00 + (v10 - v00) * tx
    bot = v01 + (v11 - v01) * tx
    return top + (bot - top) * ty


def fbm(x: int, y: int, seed: int, octaves: int = 4) -> float:
    total, amp, scale, norm = 0.0, 1.0, 16, 0.0
    for o in range(octaves):
        total += smooth_noise(x, y, scale, seed + o) * amp
        norm += amp
        amp *= 0.5
        scale = max(2, scale // 2)
    return total / norm


# --------------------------------------------------------- surface patterns

def _bricks(x, y, size):
    """Returns (brick_column, row, is_mortar) for a running-bond brick layout."""
    bw, bh, mortar = 62, 30, 5
    row = y // bh
    offset = (row % 2) * (bw // 2)
    bx = (x + offset) % bw
    by = y % bh
    return (x + offset) // bw, row, bx < mortar or by < mortar


def _surface(kind, x, y, size):
    """Returns (r, g, b, height) for one texel of a named surface."""
    if kind == "brick":
        col, row, mortar = _bricks(x, y, size)
        if mortar:
            n = fbm(x, y, 41)
            return 150 + n * 20, 146 + n * 20, 138 + n * 20, 0.15
        shade = 0.82 + _hash(col, row, 9) * 0.36
        n = fbm(x, y, 7)
        r = (152 * shade) + (n - 0.5) * 26
        g = (96 * shade) + (n - 0.5) * 20
        b = (78 * shade) + (n - 0.5) * 16
        edge = min(((x % 62) - 5), (y % 30) - 5)
        return r, g, b, 0.62 + n * 0.12

    if kind == "metal":
        streak = fbm(x * 0.12, y * 3, 13)          # brushed horizontally
        n = fbm(x, y, 17)
        v = 138 + (streak - 0.5) * 46 + (n - 0.5) * 14
        r, g, b = v * 1.0, v * 1.04, v * 1.10
        height = 0.5 + (streak - 0.5) * 0.3
        # Raised rivets on a grid.
        rx, ry = x % 64, y % 64
        d = ((rx - 32) ** 2 + (ry - 32) ** 2) ** 0.5
        if d < 6.0:
            height = 0.95
            r, g, b = r * 1.12, g * 1.12, b * 1.12
        return r, g, b, height

    if kind == "asphalt":
        grain = _hash(x, y, 23)
        n = fbm(x, y, 29)
        v = 70 + (n - 0.5) * 34 + (grain - 0.5) * 26
        r, g, b = v * 0.96, v, v * 1.06
        height = 0.45 + (grain - 0.5) * 0.5
        # Hairline cracks: dark, recessed.
        crack = abs(fbm(x * 2, y * 2, 61) - 0.5)
        if crack < 0.02:
            r, g, b = r * 0.5, g * 0.5, b * 0.5
            height = 0.05
        return r, g, b, height

    if kind == "concrete":
        n = fbm(x, y, 3)
        v = 176 + (n - 0.5) * 30
        r, g, b = v, v * 0.99, v * 0.95
        height = 0.55 + (n - 0.5) * 0.2
        # Casting seams every 128 px.
        if x % 128 < 3 or y % 128 < 3:
            r, g, b = r * 0.72, g * 0.72, b * 0.72
            height = 0.1
        # Small pits.
        if _hash(x, y, 31) > 0.985:
            height = 0.2
            r, g, b = r * 0.85, g * 0.85, b * 0.85
        return r, g, b, height

    if kind == "hazard":
        band = ((x + y) // 26) % 2
        if band == 0:
            base = (206, 168, 44)
        else:
            base = (32, 32, 34)
        n = fbm(x, y, 5)
        r, g, b = [c + (n - 0.5) * 18 for c in base]
        return r, g, b, 0.5 + (n - 0.5) * 0.1

    if kind == "fabric":
        # Woven micro-detail: two crossed sine waves plus fibre noise. Kept
        # near-white so it modulates the character's vertex colours instead of
        # recolouring them.
        weave = (0.5 + 0.25 * math.sin(x * math.pi * 0.5)
                 + 0.25 * math.sin(y * math.pi * 0.5))
        n = fbm(x, y, 2, 2)
        v = 208 + (n - 0.5) * 26 + (weave - 0.5) * 24
        return v, v, v, 0.55 + (weave - 0.5) * 0.3

    # ground: mottled grass and dirt.
    n = fbm(x, y, 2)
    patch = fbm(x + 300, y + 120, 71, 3)
    r = 96 + (n - 0.5) * 60 + (patch - 0.5) * 30
    g = 108 + (n - 0.5) * 56 + (patch - 0.5) * 20
    b = 74 + (n - 0.5) * 44
    return r, g, b, 0.5 + (n - 0.5) * 0.35


def make_texture(path, kind, size=256, bump=2.0, rough_base=0.7):
    """Writes an albedo PNG plus matching normal, roughness and ambient-occlusion
    maps, all derived from one shared height field so the surface reads as a real
    PBR material rather than flat noise."""
    height = [[0.0] * size for _ in range(size)]
    rgb = [[(0, 0, 0)] * size for _ in range(size)]
    for y in range(size):
        row = height[y]
        cols = rgb[y]
        for x in range(size):
            r, g, b, h = _surface(kind, x, y, size)
            # Micro-grain so surfaces don't read as perfectly smooth noise.
            grain = fbm(x * 8, y * 8, 1337, 2)
            tint = 0.88 + 0.24 * grain
            cols[x] = (_clamp(r * tint), _clamp(g * tint), _clamp(b * tint))
            row[x] = h

    write_png(path, size, size, lambda x, y: rgb[y][x])

    def normal(x, y):
        # Sobel on the height field: smoother, more stable normals than a
        # 4-neighbour central difference, especially on brick/metal edges.
        def h(xx, yy):
            return height[yy % size][xx % size]
        dx = (h(x + 1, y - 1) + 2 * h(x + 1, y) + h(x + 1, y + 1)
              - h(x - 1, y - 1) - 2 * h(x - 1, y) - h(x - 1, y + 1))
        dy = (h(x - 1, y + 1) + 2 * h(x, y + 1) + h(x + 1, y + 1)
              - h(x - 1, y - 1) - 2 * h(x, y - 1) - h(x + 1, y - 1))
        nx, ny = dx * bump, dy * bump
        nz = 1.0
        inv = 1.0 / math.sqrt(nx * nx + ny * ny + nz * nz)
        return (_clamp((nx * inv * 0.5 + 0.5) * 255),
                _clamp((ny * inv * 0.5 + 0.5) * 255),
                _clamp((nz * inv * 0.5 + 0.5) * 255))

    def rough(x, y):
        micro = fbm(x * 4, y * 4, 7331, 2)
        v = rough_base + (height[y][x] - 0.5) * 0.35 + (micro - 0.5) * 0.18
        v = _clamp(v * 255)
        return v, v, v

    def ao(x, y):
        # Two radii: small crevices darken, large cavities soften the result.
        small = 0.0
        for oy in (-1, 0, 1):
            for ox in (-1, 0, 1):
                small += height[(y + oy) % size][(x + ox) % size]
        large = 0.0
        for oy in (-2, 0, 2):
            for ox in (-2, 0, 2):
                large += height[(y + oy) % size][(x + ox) % size]
        h = small / 9.0 * 0.6 + (large / 9.0) * 0.4
        v = _clamp((0.42 + h * 0.78) * 255)
        return v, v, v

    def metallic(x, y):
        # Only the "metal" recipe is actually metallic; rust/oxide patches
        # lower the value so the surface reads as worn metal.
        if kind != "metal":
            return 0, 0, 0
        n = fbm(x, y, 31)
        rust = 1.0 if n < 0.28 else 0.0
        v = 0 if rust else 255
        return v, v, v

    stem = path[:-4]
    write_png(stem + "_normal.png", size, size, normal)
    write_png(stem + "_rough.png", size, size, rough)
    write_png(stem + "_ao.png", size, size, ao)
    write_png(stem + "_metal.png", size, size, metallic)


def gen_textures(size=256, only=""):
    os.makedirs(TEX_DIR, exist_ok=True)
    recipes = [
        ("concrete", {"bump": 2.0, "rough_base": 0.8}),
        ("asphalt", {"bump": 2.4, "rough_base": 0.72}),
        ("metal", {"bump": 1.6, "rough_base": 0.45}),
        ("brick", {"bump": 2.6, "rough_base": 0.85}),
        ("ground", {"bump": 2.0, "rough_base": 0.9}),
        ("hazard", {"bump": 0.8, "rough_base": 0.55}),
        ("fabric", {"bump": 1.1, "rough_base": 0.86}),
    ]
    for name, opts in recipes:
        if only and name != only:
            continue
        make_texture(os.path.join(TEX_DIR, name + ".png"), name, size=size, **opts)
    print("textures ->", TEX_DIR)


# --------------------------------------------------------------------- WAV

RATE = 44100


def write_wav(path, samples, rate=RATE):
    """`samples` is a list of mono floats -1..1, written as 16-bit PCM."""
    with wave.open(path, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(rate)
        frames = bytearray()
        for s in samples:
            frames.extend(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)))
        wav.writeframes(bytes(frames))


def _noise(n, seed, smooth=0.5):
    """Deterministic smoothed noise via a simple LCG."""
    state = seed & 0xFFFFFFFF
    out, prev = [], 0.0
    for _ in range(n):
        state = (1103515245 * state + 12345) & 0x7FFFFFFF
        white = state / 0x7FFFFFFF * 2 - 1
        prev += (white - prev) * smooth
        out.append(prev)
    return out


def env_ad(n, attack=0.02, power=2.0):
    """Fast attack, power-curve decay - the shape of a real percussive hit."""
    out = []
    a = max(1, int(n * attack))
    for i in range(n):
        if i < a:
            out.append(i / a)
        else:
            out.append(((n - i) / (n - a)) ** power)
    return out


def _sweep(f0, f1, n, curve=1.0):
    """Frequency sweep, returning per-sample phase increments."""
    inc = []
    phase = 0.0
    for i in range(n):
        t = (i / n) ** curve
        f = f0 + (f1 - f0) * t
        phase += 2 * math.pi * f / RATE
        inc.append(phase)
    return inc


def gen_audio():
    os.makedirs(AUD_DIR, exist_ok=True)

    # Gunshot: sharp crack, a body thump and a tail of filtered noise.
    n = int(RATE * 0.22)
    crack = _noise(n, 7, 0.9)
    tail = _noise(n, 11, 0.35)
    body = _sweep(240, 60, n, 0.6)
    ad = env_ad(n, 0.005, 2.6)
    samples = [crack[i] * ad[i] * 0.95
               + math.sin(body[i]) * ad[i] * 0.55
               + tail[i] * max(0.0, (i / n) - 0.25) * 0.35
               for i in range(n)]
    write_wav(os.path.join(AUD_DIR, "gunshot.wav"), samples)

    # Hit confirm: two-tone blip (perfect fifth) for a satisfying ping.
    n = int(RATE * 0.1)
    ad = env_ad(n, 0.01, 2.2)
    samples = [(math.sin(2 * math.pi * 900 * (i / RATE))
                + math.sin(2 * math.pi * 1350 * (i / RATE)) * 0.5) * ad[i] * 0.5
               for i in range(n)]
    write_wav(os.path.join(AUD_DIR, "hit.wav"), samples)

    # Explosion: sub rumble, a mid crunch and a long decaying tail.
    n = int(RATE * 0.9)
    rumble = _noise(n, 21, 0.12)
    crunch = _noise(n, 23, 0.5)
    ad = env_ad(n, 0.004, 1.6)
    samples = [rumble[i] * ad[i] * 0.9
               + crunch[i] * env_ad(n, 0.002, 3.0)[i] * 0.5
               + math.sin(2 * math.pi * 48 * (i / RATE)) * ad[i] * 0.5
               for i in range(n)]
    write_wav(os.path.join(AUD_DIR, "explosion.wav"), samples)

    # Crash: metallic clang from a few inharmonic partials plus debris.
    n = int(RATE * 0.5)
    debris = _noise(n, 33, 0.55)
    ad = env_ad(n, 0.002, 2.4)
    samples = [sum(math.sin(2 * math.pi * f * (i / RATE)) * a for f, a in
                   ((287, 0.5), (431, 0.34), (673, 0.22), (1049, 0.12))) * ad[i]
               + debris[i] * env_ad(n, 0.001, 3.2)[i] * 0.35
               for i in range(n)]
    write_wav(os.path.join(AUD_DIR, "crash.wav"), samples)

    # Boost whoosh: filtered noise rising in pitch and level.
    n = int(RATE * 0.55)
    noise = _noise(n, 44, 0.92)
    rise = [min(1.0, (i / n) ** 0.6) for i in range(n)]
    samples = [noise[i] * rise[i] * env_ad(n, 0.05, 1.1)[i] * 0.8
               for i in range(n)]
    write_wav(os.path.join(AUD_DIR, "boost.wav"), samples)

    # Civilian hit: descending two-tone alarm.
    n = int(RATE * 0.6)
    ad = env_ad(n, 0.02, 1.4)
    samples = [math.sin(_sweep(520, 240, n, 1.0)[i]) * ad[i] * 0.55
               + math.sin(_sweep(780, 360, n, 1.0)[i]) * ad[i] * 0.3
               for i in range(n)]
    write_wav(os.path.join(AUD_DIR, "alarm.wav"), samples)
    print("audio ->", AUD_DIR)


if __name__ == "__main__":
    import sys

    size = 256
    only = ""
    argv = sys.argv[1:]
    for i, arg in enumerate(argv):
        if arg == "--size" and i + 1 < len(argv):
            size = int(argv[i + 1])
        elif arg == "--only" and i + 1 < len(argv):
            only = argv[i + 1]
    gen_textures(size=size, only=only)
    if only == "":
        gen_audio()
    print("done")
