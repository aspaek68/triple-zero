import bpy
import os

OUT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "models", "humanoid.glb"))

BONES = {
    "root": (0, 0, 0), "hips": (0, 0.95, 0), "spine": (0, 1.05, 0),
    "chest": (0, 1.35, 0), "head": (0, 1.57, 0),
    "arm_l": (-0.24, 1.45, 0), "forearm_l": (-0.24, 1.15, 0), "hand_l": (-0.24, 0.89, 0),
    "arm_r": (0.24, 1.45, 0), "forearm_r": (0.24, 1.15, 0), "hand_r": (0.24, 0.89, 0),
    "leg_l": (-0.11, 0.90, 0), "shin_l": (-0.11, 0.48, 0), "foot_l": (-0.11, 0.10, 0),
    "leg_r": (0.11, 0.90, 0), "shin_r": (0.11, 0.48, 0), "foot_r": (0.11, 0.10, 0),
}

SKIN = (0.80, 0.62, 0.48)
CLOTHES = (0.30, 0.40, 0.30)
ACCENT = (0.10, 0.10, 0.12)

BONE_COLOR = {
    "head": SKIN, "neck": SKIN,
    "arm_l": CLOTHES, "forearm_l": CLOTHES, "hand_l": SKIN,
    "arm_r": CLOTHES, "forearm_r": CLOTHES, "hand_r": SKIN,
    "leg_l": CLOTHES, "shin_l": CLOTHES, "foot_l": ACCENT,
    "leg_r": CLOTHES, "shin_r": CLOTHES, "foot_r": ACCENT,
    "hips": CLOTHES, "spine": CLOTHES, "chest": CLOTHES, "root": CLOTHES,
}

PARTS = [
    # head: cranium, brow, jaw
    ((0, 1.78, 0.02), 0.12), ((0, 1.70, 0.06), 0.10), ((0, 1.62, -0.04), 0.07),
    # neck
    ((0, 1.56, 0), 0.07),
    # torso: pecs, chest, mid, lower, pelvis
    ((-0.10, 1.42, -0.06), 0.11), ((0.10, 1.42, -0.06), 0.11),
    ((0, 1.40, 0), 0.20), ((0, 1.28, 0), 0.19), ((0, 1.12, 0), 0.17), ((0, 0.98, 0), 0.16),
    # deltoids
    ((-0.26, 1.46, 0), 0.085), ((0.26, 1.46, 0), 0.085),
    # arms with bicep/tricep
    ((-0.24, 1.42, 0.02), 0.070), ((-0.24, 1.30, -0.02), 0.062), ((-0.24, 1.16, 0), 0.058),
    ((0.24, 1.42, 0.02), 0.070), ((0.24, 1.30, -0.02), 0.062), ((0.24, 1.16, 0), 0.058),
    # forearms
    ((-0.24, 1.02, 0), 0.052), ((-0.24, 0.92, 0), 0.048),
    ((0.24, 1.02, 0), 0.052), ((0.24, 0.92, 0), 0.048),
    # hands
    ((-0.24, 0.84, 0), 0.046), ((0.24, 0.84, 0), 0.046),
    # legs: thigh/glute/calf
    ((-0.13, 0.86, -0.04), 0.085), ((-0.11, 0.72, 0), 0.078), ((-0.11, 0.56, 0.02), 0.070),
    ((0.13, 0.86, -0.04), 0.085), ((0.11, 0.72, 0), 0.078), ((0.11, 0.56, 0.02), 0.070),
    # shins
    ((-0.11, 0.38, 0), 0.060), ((-0.11, 0.22, 0), 0.054),
    ((0.11, 0.38, 0), 0.060), ((0.11, 0.22, 0), 0.054),
    # feet
    ((-0.11, 0.07, 0.06), 0.052), ((-0.11, 0.05, 0.12), 0.040),
    ((0.11, 0.07, 0.06), 0.052), ((0.11, 0.05, 0.12), 0.040),
]


def nearest_bone(pos):
    best = None; best_d = 1e9
    for name, bp in BONES.items():
        d = (pos[0]-bp[0])**2 + (pos[1]-bp[1])**2 + (pos[2]-bp[2])**2
        if d < best_d:
            best_d = d; best = name
    return best


def main():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.object.metaball_add(type="BALL", location=(0, 0, 0))
    mb_obj = bpy.context.active_object
    mb_obj.name = "HumanoidMB"
    mb = mb_obj.data
    mb.resolution = 0.03
    mb.threshold = 0.55
    mb.elements.remove(mb.elements[0])
    for loc, r in PARTS:
        el = mb.elements.new(type="BALL")
        el.co = loc
        el.radius = r
    bpy.context.view_layer.objects.active = mb_obj
    mb_obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    mesh_obj = bpy.context.active_object
    mesh_obj.name = "Humanoid"
    bpy.ops.object.shade_smooth()
    mod = mesh_obj.modifiers.new(name="Remesh", type="REMESH")
    mod.mode = "VOXEL"; mod.voxel_size = 0.022; mod.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    mod = mesh_obj.modifiers.new(name="Subdiv", type="SUBSURF")
    mod.levels = 1; mod.render_levels = 1
    bpy.ops.object.modifier_apply(modifier=mod.name)
    mod = mesh_obj.modifiers.new(name="Decimate", type="DECIMATE")
    mod.ratio = 0.4
    bpy.ops.object.modifier_apply(modifier=mod.name)
    # cleanup
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.001)
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    # vertex colors
    if not mesh_obj.data.color_attributes:
        mesh_obj.data.color_attributes.new(name="Col", type="FLOAT_COLOR", domain="POINT")
    col = mesh_obj.data.color_attributes["Col"]
    for i, v in enumerate(mesh_obj.data.vertices):
        bone = nearest_bone(v.co)
        c = BONE_COLOR.get(bone, CLOTHES)
        col.data[i].color = (c[0], c[1], c[2], 1.0)
    # export
    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_obj
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=OUT, export_format="GLB", use_selection=True,
        export_vertex_color="ACTIVE", export_normals=True,
    )
    print("EXPORTED:", OUT)


if __name__ == "__main__":
    main()
