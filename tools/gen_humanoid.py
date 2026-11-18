import bpy
import bmesh
import math
import os

OUT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "models", "humanoid.glb"))

# Bone world positions (must match Character._build_skeleton rest transforms).
BONES = {
    "root": (0, 0, 0),
    "hips": (0, 0.95, 0),
    "spine": (0, 1.05, 0),
    "chest": (0, 1.35, 0),
    "head": (0, 1.57, 0),
    "arm_l": (-0.24, 1.45, 0),
    "forearm_l": (-0.24, 1.15, 0),
    "hand_l": (-0.24, 0.89, 0),
    "arm_r": (0.24, 1.45, 0),
    "forearm_r": (0.24, 1.15, 0),
    "hand_r": (0.24, 0.89, 0),
    "leg_l": (-0.11, 0.90, 0),
    "shin_l": (-0.11, 0.48, 0),
    "foot_l": (-0.11, 0.10, 0),
    "leg_r": (0.11, 0.90, 0),
    "shin_r": (0.11, 0.48, 0),
    "foot_r": (0.11, 0.10, 0),
}

SKIN = (0.80, 0.62, 0.48)
CLOTHES = (0.30, 0.40, 0.30)
ACCENT = (0.10, 0.10, 0.12)
GEAR = (0.18, 0.20, 0.22)

BONE_COLOR = {
    "head": SKIN, "neck": SKIN,
    "arm_l": CLOTHES, "forearm_l": CLOTHES, "hand_l": SKIN,
    "arm_r": CLOTHES, "forearm_r": CLOTHES, "hand_r": SKIN,
    "leg_l": CLOTHES, "shin_l": CLOTHES, "foot_l": ACCENT,
    "leg_r": CLOTHES, "shin_r": CLOTHES, "foot_r": ACCENT,
    "hips": CLOTHES, "spine": CLOTHES, "chest": CLOTHES, "root": CLOTHES,
}

# Metaball layout: (location, radius). Multiple balls blend into one body.
PARTS = [
    # head
    ((0, 1.72, 0), 0.13),
    ((0, 1.58, 0), 0.075),  # neck
    # torso
    ((0, 1.42, 0), 0.20),
    ((0, 1.22, 0), 0.19),
    ((0, 1.00, 0), 0.17),
    # arms
    ((-0.24, 1.45, 0), 0.068), ((-0.24, 1.25, 0), 0.062), ((-0.24, 1.02, 0), 0.056), ((-0.24, 0.87, 0), 0.050),
    ((0.24, 1.45, 0), 0.068), ((0.24, 1.25, 0), 0.062), ((0.24, 1.02, 0), 0.056), ((0.24, 0.87, 0), 0.050),
    # legs
    ((-0.11, 0.80, 0), 0.078), ((-0.11, 0.55, 0), 0.070), ((-0.11, 0.25, 0), 0.062), ((-0.11, 0.06, 0.04), 0.055),
    ((0.11, 0.80, 0), 0.078), ((0.11, 0.55, 0), 0.070), ((0.11, 0.25, 0), 0.062), ((0.11, 0.06, 0.04), 0.055),
]


def build_metaballs():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    # Create a metaball object
    bpy.ops.object.metaball_add(type="BALL", location=(0, 0, 0))
    mb_obj = bpy.context.active_object
    mb_obj.name = "HumanoidMB"
    mb = mb_obj.data
    mb.resolution = 0.035
    mb.threshold = 0.6
    # Remove the default element
    mb.elements.remove(mb.elements[0])
    for loc, r in PARTS:
        el = mb.elements.new(type="BALL")
        el.co = loc
        el.radius = r
    return mb_obj


def nearest_bone(pos):
    best = None
    best_d = 1e9
    for name, bp in BONES.items():
        d = (pos[0]-bp[0])**2 + (pos[1]-bp[1])**2 + (pos[2]-bp[2])**2
        if d < best_d:
            best_d = d
            best = name
    return best


def paint_vertex_colors(mesh):
    if not mesh.color_attributes:
        mesh.color_attributes.new(name="Col", type="FLOAT_COLOR", domain="POINT")
    col = mesh.color_attributes["Col"]
    for i, v in enumerate(mesh.vertices):
        bone = nearest_bone(v.co)
        c = BONE_COLOR.get(bone, CLOTHES)
        col.data[i].color = (c[0], c[1], c[2], 1.0)


def main():
    mb_obj = build_metaballs()
    bpy.context.view_layer.objects.active = mb_obj
    mb_obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    mesh_obj = bpy.context.active_object
    mesh_obj.name = "Humanoid"

    # Smooth shading
    bpy.ops.object.shade_smooth()

    # Remesh for clean topology
    mod = mesh_obj.modifiers.new(name="Remesh", type="REMESH")
    mod.mode = "VOXEL"
    mod.voxel_size = 0.025
    mod.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier=mod.name)

    # Subdivision for smoothness
    mod = mesh_obj.modifiers.new(name="Subdiv", type="SUBSURF")
    mod.levels = 1
    mod.render_levels = 1
    bpy.ops.object.modifier_apply(modifier=mod.name)

    # Decimate to keep polycount sane
    mod = mesh_obj.modifiers.new(name="Decimate", type="DECIMATE")
    mod.ratio = 0.35
    bpy.ops.object.modifier_apply(modifier=mod.name)

    # Cleanup
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.001)
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")

    # Paint vertex colors
    paint_vertex_colors(mesh_obj.data)

    # Export GLB
    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_obj
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=OUT,
        export_format="GLB",
        use_selection=True,
        export_vertex_color="ACTIVE",
        export_normals=True,
    )
    print("EXPORTED:", OUT)


if __name__ == "__main__":
    main()
