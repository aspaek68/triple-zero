#!/usr/bin/env python3
"""Generates the game's prop meshes as binary glTF (.glb) files into
assets/models/. Pure Python (json + struct), no third-party dependency.

    python3 tools/gen_meshes.py

Each file holds a single, single-material mesh, modelled with its base at
y = 0 and a height of about one metre, so the game can place it at a floor
position and override the material with its own PBR one. The game falls back
to a procedural primitive whenever a file is missing.
"""

import json
import math
import os
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "models")


# ------------------------------------------------------------------ maths

def mat_identity():
    return [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]


def mat_mul(a, b):
    """Row-major 3x3 product a*b."""
    out = [0.0] * 9
    for r in range(3):
        for c in range(3):
            out[r * 3 + c] = sum(a[r * 3 + k] * b[k * 3 + c] for k in range(3))
    return out


def mat_rot_x(a):
    s, c = math.sin(a), math.cos(a)
    return [1, 0, 0, 0, c, -s, 0, s, c]


def mat_rot_y(a):
    s, c = math.sin(a), math.cos(a)
    return [c, 0, s, 0, 1, 0, -s, 0, c]


def mat_rot_z(a):
    s, c = math.sin(a), math.cos(a)
    return [c, -s, 0, s, c, 0, 0, 0, 1]


def mat_scale(x, y, z):
    return [x, 0, 0, 0, y, 0, 0, 0, z]


def apply(m, v):
    return (m[0] * v[0] + m[1] * v[1] + m[2] * v[2],
            m[3] * v[0] + m[4] * v[1] + m[5] * v[2],
            m[6] * v[0] + m[7] * v[1] + m[8] * v[2])


def normalize(v):
    n = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
    if n < 1e-9:
        return (0.0, 1.0, 0.0)
    return (v[0] / n, v[1] / n, v[2] / n)


# ------------------------------------------------------------------ builder

class Mesh:
    def __init__(self):
        self.pos = []
        self.nrm = []
        self.uv = []
        self.idx = []

    def _push(self, verts, normals, uvs, transform, origin):
        base = len(self.pos)
        for i, v in enumerate(verts):
            w = apply(transform, v)
            self.pos.append((w[0] + origin[0], w[1] + origin[1], w[2] + origin[2]))
            self.nrm.append(normalize(apply(transform, normals[i])))
        self.uv.extend(uvs)
        n = len(verts)
        if n == 4:
            self.idx.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        else:
            for i in range(1, n - 1):
                self.idx.extend([base, base + i, base + i + 1])

    def box(self, size, origin=(0, 0, 0), transform=None):
        sx, sy, sz = size[0] / 2.0, size[1] / 2.0, size[2] / 2.0
        t = transform or mat_identity()
        faces = [
            ((0, 0, 1), [(-sx, -sy, sz), (sx, -sy, sz), (sx, sy, sz), (-sx, sy, sz)]),
            ((0, 0, -1), [(sx, -sy, -sz), (-sx, -sy, -sz), (-sx, sy, -sz), (sx, sy, -sz)]),
            ((1, 0, 0), [(sx, -sy, sz), (sx, -sy, -sz), (sx, sy, -sz), (sx, sy, sz)]),
            ((-1, 0, 0), [(-sx, -sy, -sz), (-sx, -sy, sz), (-sx, sy, sz), (-sx, sy, -sz)]),
            ((0, 1, 0), [(-sx, sy, sz), (sx, sy, sz), (sx, sy, -sz), (-sx, sy, -sz)]),
            ((0, -1, 0), [(-sx, -sy, -sz), (sx, -sy, -sz), (sx, -sy, sz), (-sx, -sy, sz)]),
        ]
        quad_uv = [(0, 0), (1, 0), (1, 1), (0, 1)]
        for normal, verts in faces:
            self._push(verts, [normal] * 4, quad_uv, t, origin)

    def cylinder(self, r_bottom, r_top, height, segments=24, origin=(0, 0, 0),
                 transform=None, cap_bottom=True, cap_top=True):
        """Truncated cone from y=0 to y=height; r_top=0 makes a cone."""
        t = transform or mat_identity()
        ring_b, ring_t = [], []
        for i in range(segments + 1):
            a = 2.0 * math.pi * i / segments
            ring_b.append((math.cos(a) * r_bottom, 0.0, math.sin(a) * r_bottom))
            ring_t.append((math.cos(a) * r_top, height, math.sin(a) * r_top))
        # Side: outward normal tilts with the slope.
        for i in range(segments):
            a = 2.0 * math.pi * (i + 0.5) / segments
            n = normalize((math.cos(a) * height, r_bottom - r_top, math.sin(a) * height))
            u0, u1 = i / segments, (i + 1) / segments
            verts = [ring_b[i], ring_t[i], ring_t[i + 1], ring_b[i + 1]]
            uvs = [(u0, 0), (u0, 1), (u1, 1), (u1, 0)]
            self._push(verts, [n] * 4, uvs, t, origin)
        if cap_bottom and r_bottom > 0:
            verts, uvs = [], []
            for i in range(segments + 1):
                a = 2.0 * math.pi * i / segments
                verts.append((math.cos(a) * r_bottom, 0.0, math.sin(a) * r_bottom))
                uvs.append((0.5 + math.cos(a) * 0.5, 0.5 + math.sin(a) * 0.5))
            self._cap(verts, (0, -1, 0), uvs, t, origin, reverse=False)
        if cap_top and r_top > 0:
            verts, uvs = [], []
            for i in range(segments + 1):
                a = 2.0 * math.pi * i / segments
                verts.append((math.cos(a) * r_top, height, math.sin(a) * r_top))
                uvs.append((0.5 + math.cos(a) * 0.5, 0.5 + math.sin(a) * 0.5))
            self._cap(verts, (0, 1, 0), uvs, t, origin, reverse=True)

    def _cap(self, ring, normal, uvs, transform, origin, reverse):
        centre = [sum(v[k] for v in ring[:-1]) / (len(ring) - 1) for k in range(3)]
        base = len(self.pos)
        w = apply(transform, centre)
        self.pos.append((w[0] + origin[0], w[1] + origin[1], w[2] + origin[2]))
        self.nrm.append(normalize(apply(transform, normal)))
        self.uv.append((0.5, 0.5))
        for i in range(len(ring) - 1):
            v = ring[i]
            w = apply(transform, v)
            self.pos.append((w[0] + origin[0], w[1] + origin[1], w[2] + origin[2]))
            self.nrm.append(normalize(apply(transform, normal)))
            self.uv.append(uvs[i])
        n = len(ring) - 1
        for i in range(n):
            a, b = base + 1 + i, base + 1 + (i + 1) % n
            if reverse:
                self.idx.extend([base, b, a])
            else:
                self.idx.extend([base, a, b])


# ------------------------------------------------------------------ props

def barrel() -> Mesh:
    m = Mesh()
    m.cylinder(0.42, 0.42, 1.40, 28)
    # Rolled ribs, slightly proud of the body.
    for y in (0.32, 0.98):
        m.cylinder(0.455, 0.455, 0.10, 28, origin=(0, y, 0))
    # Top and bottom rims.
    m.cylinder(0.46, 0.46, 0.06, 28)
    m.cylinder(0.46, 0.46, 0.06, 28, origin=(0, 1.34, 0))
    # Lid inset plus a filler cap.
    m.cylinder(0.34, 0.34, 0.05, 20, origin=(0, 1.40, 0))
    m.cylinder(0.09, 0.09, 0.07, 12, origin=(0.16, 1.42, 0.0))
    return m


def crate() -> Mesh:
    m = Mesh()
    # Core shell and a slightly inset front panel, framed by corner posts.
    m.box((1.10, 1.10, 1.10), origin=(0, 0.55, 0))
    for sx in (-0.5, 0.5):
        for sz in (-0.5, 0.5):
            m.box((0.14, 1.18, 0.14), origin=(sx, 0.59, sz))
    # Horizontal battens on two sides.
    for sz in (-0.56, 0.56):
        m.box((1.18, 0.14, 0.06), origin=(0, 0.55, sz))
        m.box((1.18, 0.14, 0.06), origin=(0, 1.03, sz))
    m.box((0.60, 0.30, 0.06), origin=(0, 0.78, 0.56))
    return m


def cone() -> Mesh:
    m = Mesh()
    m.box((0.52, 0.06, 0.52), origin=(0, 0.03, 0))
    m.cylinder(0.21, 0.045, 0.62, 20, origin=(0, 0.05, 0))
    # Reflective bands.
    m.cylinder(0.135, 0.115, 0.09, 20, origin=(0, 0.30, 0))
    m.cylinder(0.095, 0.075, 0.08, 20, origin=(0, 0.46, 0))
    return m


def streetlamp() -> Mesh:
    m = Mesh()
    m.cylinder(0.20, 0.16, 0.30, 16)
    m.cylinder(0.085, 0.07, 4.20, 16, origin=(0, 0.30, 0))
    # Arm reaching over the road, plus the luminaire.
    m.box((0.09, 0.09, 1.05), origin=(0, 4.42, -0.48))
    m.box((0.30, 0.12, 0.62), origin=(0, 4.34, -1.00))
    m.box((0.26, 0.04, 0.56), origin=(0, 4.27, -1.00))
    return m


# ------------------------------------------------------------------ glTF

def pack_floats(values):
    return struct.pack("<%df" % len(values), *values)


def write_glb(path, mesh: Mesh, name: str):
    data = bytearray()
    views = []

    def add_view(blob, target):
        while len(data) % 4:
            data.append(0)
        offset = len(data)
        data.extend(blob)
        views.append({"buffer": 0, "byteOffset": offset,
                      "byteLength": len(blob), "target": target})
        return len(views) - 1

    flat_pos = [c for v in mesh.pos for c in v]
    flat_nrm = [c for v in mesh.nrm for c in v]
    flat_uv = [c for uv in mesh.uv for c in uv]
    v_pos = add_view(pack_floats(flat_pos), 34962)
    v_nrm = add_view(pack_floats(flat_nrm), 34962)
    v_uv = add_view(pack_floats(flat_uv), 34962)
    v_idx = add_view(struct.pack("<%dI" % len(mesh.idx), *mesh.idx), 34963)
    while len(data) % 4:
        data.append(0)

    count = len(mesh.pos)
    mins = [min(v[i] for v in mesh.pos) for i in range(3)]
    maxs = [max(v[i] for v in mesh.pos) for i in range(3)]
    accessors = [
        {"bufferView": v_pos, "componentType": 5126, "count": count, "type": "VEC3",
         "min": mins, "max": maxs},
        {"bufferView": v_nrm, "componentType": 5126, "count": count, "type": "VEC3"},
        {"bufferView": v_uv, "componentType": 5126, "count": count, "type": "VEC2"},
        {"bufferView": v_idx, "componentType": 5125, "count": len(mesh.idx), "type": "SCALAR"},
    ]
    gltf = {
        "asset": {"version": "2.0", "generator": "triplezero-gen"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": [{"mesh": 0, "name": name}],
        "meshes": [{"name": name, "primitives": [{
            "attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2},
            "indices": 3, "material": 0}]}],
        "materials": [{"name": name + "_mat", "pbrMetallicRoughness": {
            "baseColorFactor": [0.7, 0.7, 0.7, 1.0],
            "metallicFactor": 0.0, "roughnessFactor": 0.75}}],
        "accessors": accessors,
        "bufferViews": views,
        "buffers": [{"byteLength": len(data)}],
    }
    js = json.dumps(gltf, separators=(",", ":")).encode()
    while len(js) % 4:
        js += b" "
    total = 12 + 8 + len(js) + 8 + len(data)
    glb = b"glTF" + struct.pack("<II", 2, total)
    glb += struct.pack("<I", len(js)) + b"JSON" + js
    glb += struct.pack("<I", len(data)) + b"BIN\x00" + bytes(data)
    with open(path, "wb") as fh:
        fh.write(glb)


def gen_models():
    """Writes the dependency-free placeholders. Refuses to overwrite existing
    files unless `--force` is passed, so it can never clobber the authored
    models produced by tools/gen_models.py (which shares these filenames)."""
    os.makedirs(OUT_DIR, exist_ok=True)
    force = "--force" in sys.argv
    for name, builder in (("barrel", barrel), ("crate", crate),
                          ("cone", cone), ("streetlamp", streetlamp)):
        path = os.path.join(OUT_DIR, name + ".glb")
        if os.path.exists(path) and not force:
            print("  %-12s skip (already present; use --force to replace)" % name)
            continue
        mesh = builder()
        write_glb(path, mesh, name)
        print("  %-12s %5d verts %6d tris" % (name, len(mesh.pos), len(mesh.idx) // 3))
    print("models ->", OUT_DIR)


if __name__ == "__main__":
    gen_models()
    print("done")
