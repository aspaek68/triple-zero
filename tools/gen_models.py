#!/usr/bin/env python3
"""Builds the game's hero props as real, modelled meshes with Blender's Python
module (bpy) and exports them to assets/models/*.glb.

    /tmp/bpyenv/bin/python tools/gen_models.py

Unlike tools/gen_meshes.py (a dependency-free glTF writer for the simple
placeholders), this uses Blender's mesh tools: bevels, smooth shading and
several materials per object, so the exported props read as authored art. Each
prop keeps its own materials; the game can still override them when it wants a
shared PBR texture instead.
"""

import math
import os

import bpy

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "models")


# ------------------------------------------------------------------- helpers

def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name, color, metallic=0.0, roughness=0.7, alpha=1.0,
             emission=None, emission_strength=1.0):
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Alpha"].default_value = alpha
    if emission is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    if alpha < 1.0:
        mat.blend_method = "BLEND"
    return mat


def _finish(obj, mat):
    if mat is not None:
        obj.data.materials.append(mat)
    for poly in obj.data.polygons:
        poly.use_smooth = False
    return obj


def cube(name, size, loc=(0, 0, 0), rot=(0, 0, 0), mat=None):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (size[0], size[1], size[2])
    obj.rotation_euler = rot
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    return _finish(obj, mat)


def cylinder(name, radius, depth, loc=(0, 0, 0), rot=(0, 0, 0), verts=32,
             radius_top=None, mat=None):
    if radius_top is None:
        bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=depth,
                                            vertices=verts, location=loc)
    else:
        bpy.ops.mesh.primitive_cone_add(radius1=radius, radius2=radius_top,
                                        depth=depth, vertices=verts, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.rotation_euler = rot
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    return _finish(obj, mat)


def sphere(name, radius, loc=(0, 0, 0), scale=(1, 1, 1), mat=None):
    bpy.ops.mesh.primitive_ico_sphere_add(radius=radius, subdivisions=2, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _finish(obj, mat)


def bevel(obj, width=0.02, segments=2):
    bpy.context.view_layer.objects.active = obj
    mod = obj.modifiers.new("Bevel", "BEVEL")
    mod.width = width
    mod.segments = segments
    mod.limit_method = "ANGLE"
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj


def smooth(obj, angle_deg=38.0):
    bpy.context.view_layer.objects.active = obj
    for poly in obj.data.polygons:
        poly.use_smooth = True
    mod = obj.modifiers.new("Smooth by Angle", "NODES")
    # Fall back to a plain edge split when the auto-smooth node group is absent.
    try:
        bpy.ops.object.shade_auto_smooth(angle=math.radians(angle_deg))
    except Exception:
        obj.modifiers.remove(mod)
    return obj


def join(objs, name):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    merged = bpy.context.active_object
    merged.name = name
    return merged


def export(path, name):
    for obj in bpy.context.scene.objects:
        obj.select_set(obj.name == name)
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
    )
    size = os.path.getsize(path)
    polys = sum(len(o.data.polygons) for o in bpy.context.scene.objects if o.name == name)
    print("  %-12s %5d tris  %6d B" % (name, polys, size))


# --------------------------------------------------------------------- props

def build_barrel():
    paint = material("barrel_paint", (0.62, 0.16, 0.10), 0.35, 0.42)
    steel = material("barrel_steel", (0.42, 0.44, 0.47), 0.85, 0.35)
    dark = material("barrel_dark", (0.10, 0.10, 0.11), 0.6, 0.5)
    parts = [bevel(cylinder("body", 0.42, 1.30, (0, 0, 0.70), verts=32, mat=paint), 0.03)]
    for z in (0.34, 1.06):
        parts.append(cylinder("hoop", 0.452, 0.09, (0, 0, z), verts=32, mat=steel))
    parts.append(cylinder("foot", 0.45, 0.07, (0, 0, 0.035), verts=32, mat=steel))
    parts.append(bevel(cylinder("lid", 0.45, 0.09, (0, 0, 1.40), verts=32, mat=steel), 0.02))
    parts.append(cylinder("cap", 0.09, 0.07, (0.17, 0, 1.47), verts=12, mat=dark))
    obj = join(parts, "barrel")
    smooth(obj, 42.0)
    return obj


def build_crate():
    wood = material("crate_wood", (0.42, 0.27, 0.14), 0.0, 0.85)
    frame = material("crate_frame", (0.30, 0.19, 0.10), 0.0, 0.9)
    metal = material("crate_metal", (0.35, 0.36, 0.38), 0.8, 0.45)
    parts = [bevel(cube("body", (1.06, 1.06, 1.06), (0, 0, 0.56), mat=wood), 0.02)]
    for sx in (-0.53, 0.53):
        for sy in (-0.53, 0.53):
            parts.append(cube("post", (0.10, 0.10, 1.16), (sx, sy, 0.58), mat=frame))
    for sy in (-0.56, 0.56):
        for z in (0.30, 0.86):
            parts.append(cube("batten", (1.16, 0.06, 0.12), (0, sy, z), mat=frame))
    parts.append(cube("plate", (0.30, 0.04, 0.20), (0, 0.56, 0.62), mat=metal))
    obj = join(parts, "crate")
    return obj


def build_cone():
    orange = material("cone_orange", (0.85, 0.28, 0.04), 0.0, 0.55)
    white = material("cone_white", (0.92, 0.92, 0.94), 0.0, 0.5)
    dark = material("cone_base", (0.09, 0.09, 0.10), 0.1, 0.8)
    parts = [bevel(cube("base", (0.52, 0.52, 0.06), (0, 0, 0.03), mat=dark), 0.02)]
    parts.append(cylinder("cone", 0.215, 0.62, (0, 0, 0.37), verts=24,
                          radius_top=0.05, mat=orange))
    parts.append(cylinder("band1", 0.16, 0.08, (0, 0, 0.30), verts=24,
                          radius_top=0.135, mat=white))
    parts.append(cylinder("band2", 0.112, 0.07, (0, 0, 0.46), verts=24,
                          radius_top=0.09, mat=white))
    obj = join(parts, "cone")
    smooth(obj, 40.0)
    return obj


def build_streetlamp():
    metal = material("lamp_metal", (0.30, 0.31, 0.33), 0.75, 0.45)
    dark = material("lamp_dark", (0.12, 0.12, 0.13), 0.6, 0.5)
    lens = material("lamp_lens", (1.0, 0.94, 0.78), 0.0, 0.2,
                    emission=(1.0, 0.90, 0.65), emission_strength=6.0)
    parts = [bevel(cylinder("foot", 0.22, 0.30, (0, 0, 0.15), verts=20, mat=metal), 0.03)]
    parts.append(cylinder("pole", 0.085, 4.20, (0, 0, 2.40), verts=16, mat=metal))
    parts.append(cube("arm", (0.09, 1.05, 0.09), (0, -0.48, 4.42), mat=metal))
    parts.append(bevel(cube("head", (0.30, 0.62, 0.12), (0, -1.00, 4.34), mat=dark), 0.03))
    parts.append(cube("lens", (0.24, 0.54, 0.04), (0, -1.00, 4.26), mat=lens))
    obj = join(parts, "streetlamp")
    smooth(obj, 40.0)
    return obj


def build_dumpster():
    paint = material("dumpster_paint", (0.10, 0.34, 0.22), 0.25, 0.55)
    lid = material("dumpster_lid", (0.09, 0.26, 0.17), 0.3, 0.5)
    metal = material("dumpster_metal", (0.32, 0.33, 0.35), 0.8, 0.4)
    parts = [bevel(cube("body", (1.30, 0.95, 1.00), (0, 0, 0.62), mat=paint), 0.04)]
    parts.append(bevel(cube("lid", (1.36, 1.00, 0.12), (0, -0.02, 1.16), mat=lid), 0.03))
    parts.append(cube("rim", (1.34, 0.10, 0.16), (0, 0.48, 1.02), mat=metal))
    for sx in (-0.5, 0.5):
        parts.append(cube("rail", (0.06, 0.06, 0.5), (sx, -0.50, 0.45), mat=metal))
    obj = join(parts, "dumpster")
    bevel(obj, 0.01)
    return obj


def build_planter():
    concrete = material("planter_concrete", (0.66, 0.64, 0.60), 0.0, 0.9)
    soil = material("planter_soil", (0.20, 0.15, 0.10), 0.0, 0.95)
    trunk = material("planter_trunk", (0.28, 0.19, 0.12), 0.0, 0.9)
    leaf = material("planter_leaf", (0.20, 0.42, 0.16), 0.0, 0.8)
    parts = [bevel(cube("box", (1.00, 1.00, 0.70), (0, 0, 0.35), mat=concrete), 0.03)]
    parts.append(cube("soil", (0.86, 0.86, 0.06), (0, 0, 0.71), mat=soil))
    parts.append(cylinder("trunk", 0.09, 1.10, (0, 0, 1.30), verts=12, mat=trunk))
    for dx, dy, dz, r in ((0, 0, 2.05, 0.55), (0.28, 0.10, 1.75, 0.42), (-0.24, -0.16, 1.85, 0.40)):
        parts.append(sphere("leaf", r, (dx, dy, dz), scale=(1.0, 1.0, 0.8), mat=leaf))
    obj = join(parts, "planter")
    return obj


def build_barrier():
    metal = material("barrier_metal", (0.55, 0.56, 0.58), 0.85, 0.35)
    reflect = material("barrier_reflect", (0.90, 0.20, 0.12), 0.0, 0.3,
                       emission=(0.9, 0.2, 0.1), emission_strength=1.5)
    parts = []
    for sx in (-1.10, 0.0, 1.10):
        parts.append(cube("post", (0.09, 0.09, 1.00), (sx, 0, 0.50), mat=metal))
    parts.append(bevel(cube("rail", (2.40, 0.07, 0.26), (0, 0, 0.92), mat=metal), 0.02))
    for sx in (-0.6, 0.6):
        parts.append(cube("stripe", (0.36, 0.02, 0.20), (sx, -0.045, 0.92), mat=reflect))
    obj = join(parts, "barrier")
    return obj


def build_car_body():
    """Modelled around the car origin (wheels sit at y = 0 in the game), so the
    exported mesh lines up with VehicleWheel3D positions without an offset."""
    paint = material("car_paint", (0.72, 0.10, 0.08), 0.45, 0.22)
    glass = material("car_glass", (0.32, 0.44, 0.52), 0.0, 0.06, alpha=0.45)
    trim = material("car_trim", (0.09, 0.09, 0.10), 0.4, 0.5)
    chrome = material("car_chrome", (0.80, 0.82, 0.85), 0.95, 0.15)
    head = material("car_head", (1.0, 0.95, 0.82), 0.0, 0.12,
                    emission=(1.0, 0.95, 0.8), emission_strength=5.0)
    tail = material("car_tail", (0.95, 0.16, 0.12), 0.0, 0.18,
                    emission=(1.0, 0.15, 0.1), emission_strength=4.0)
    parts = [bevel(cube("body", (2.00, 4.20, 0.62), (0, 0, -0.05), mat=paint), 0.09, 3)]
    parts.append(bevel(cube("nose", (1.86, 0.90, 0.34), (0, -1.60, 0.30), mat=paint), 0.05))
    parts.append(bevel(cube("boot", (1.90, 0.80, 0.34), (0, 1.70, 0.28), mat=paint), 0.05))
    parts.append(bevel(cube("roof", (1.62, 1.90, 0.10), (0, -0.10, 0.92), mat=paint), 0.05))
    parts.append(cube("windscreen", (1.50, 0.10, 0.50), (0, -0.95, 0.62), rot=(math.radians(-28), 0, 0), mat=glass))
    parts.append(cube("rear_glass", (1.50, 0.10, 0.45), (0, 0.82, 0.62), rot=(math.radians(24), 0, 0), mat=glass))
    parts.append(cube("side_l", (0.10, 1.86, 0.45), (-0.80, -0.05, 0.62), mat=glass))
    parts.append(cube("side_r", (0.10, 1.86, 0.45), (0.80, -0.05, 0.62), mat=glass))
    parts.append(cube("bumper_f", (1.95, 0.18, 0.22), (0, -2.15, -0.20), mat=trim))
    parts.append(cube("bumper_r", (1.95, 0.18, 0.22), (0, 2.15, -0.20), mat=trim))
    parts.append(cube("grille", (1.40, 0.10, 0.20), (0, -2.15, -0.05), mat=chrome))
    for sx in (-0.68, 0.68):
        parts.append(cube("head", (0.34, 0.10, 0.16), (sx, -2.14, 0.05), mat=head))
        parts.append(cube("tail", (0.34, 0.10, 0.16), (sx, 2.14, 0.08), mat=tail))
        parts.append(cube("mirror", (0.12, 0.22, 0.10), (sx * 1.42, -0.85, 0.60), mat=trim))
    obj = join(parts, "car_body")
    return obj


def build_neon_sign():
    """A vertical shop sign with a glowing neon tube frame."""
    steel = material("neon_steel", (0.16, 0.17, 0.19), 0.7, 0.45)
    glow = material("neon_glow", (0.95, 0.25, 0.55), 0.0, 0.25,
                    emission=(1.0, 0.25, 0.55), emission_strength=6.0)
    glow2 = material("neon_glow2", (0.25, 0.85, 0.95), 0.0, 0.25,
                     emission=(0.3, 0.9, 1.0), emission_strength=6.0)
    parts = [cube("panel", (0.90, 0.16, 2.60), (0, 0, 1.40), mat=steel)]
    parts.append(cube("tube_v_l", (0.07, 0.07, 2.20), (-0.42, -0.10, 1.40), mat=glow))
    parts.append(cube("tube_v_r", (0.07, 0.07, 2.20), (0.42, -0.10, 1.40), mat=glow))
    parts.append(cube("tube_h_t", (0.80, 0.07, 0.07), (0, -0.10, 2.42), mat=glow))
    parts.append(cube("tube_h_b", (0.80, 0.07, 0.07), (0, -0.10, 0.38), mat=glow2))
    parts.append(cube("letter_a", (0.44, 0.06, 0.10), (0, -0.14, 1.75), mat=glow2))
    parts.append(cube("letter_b", (0.44, 0.06, 0.10), (0, -0.14, 1.10), mat=glow2))
    return join(parts, "neon_sign")


def build_road_sign():
    """An overhead direction sign on a single post."""
    steel = material("sign_steel", (0.52, 0.54, 0.57), 0.85, 0.35)
    panel = material("sign_panel", (0.10, 0.42, 0.30), 0.0, 0.4,
                     emission=(0.1, 0.5, 0.35), emission_strength=0.6)
    stripe = material("sign_stripe", (0.95, 0.95, 0.95), 0.0, 0.5)
    parts = [cylinder("post", 0.10, 3.40, (0, 0, 1.70), mat=steel)]
    parts.append(bevel(cube("board", (3.40, 0.14, 1.10), (0, 0, 3.10), mat=panel), 0.03))
    for i, sx in enumerate((-1.0, 0.0, 1.0)):
        parts.append(cube("line%d" % i, (0.90, 0.05, 0.16), (sx, -0.10, 3.10), mat=stripe))
    parts.append(cube("arrow", (0.50, 0.05, 0.16), (0.9, -0.10, 2.72), mat=stripe))
    return join(parts, "road_sign")


PROPS = {
    "barrel": build_barrel,
    "crate": build_crate,
    "cone": build_cone,
    "streetlamp": build_streetlamp,
    "dumpster": build_dumpster,
    "planter": build_planter,
    "barrier": build_barrier,
    "car_body": build_car_body,
    "neon_sign": build_neon_sign,
    "road_sign": build_road_sign,
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("models ->", OUT_DIR)
    for name, builder in PROPS.items():
        reset()
        obj = builder()
        export(os.path.join(OUT_DIR, name + ".glb"), obj.name)


if __name__ == "__main__":
    main()
    print("done")
