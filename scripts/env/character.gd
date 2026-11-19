class_name Character
extends Node3D
## Humanoid actor: a skinned mesh on a Skeleton3D, played by an AnimationPlayer
## (idle/walk/run, aiming variants, death). Rigid skinning - one bone per part -
## keeps it cheap, and the weapon attaches to the right hand bone so it follows
## the animation.

const SKIN := Color(0.80, 0.62, 0.48)
const SKIN_DARK := Color(0.55, 0.40, 0.30)
const BLEND := 0.2

# Silhouette presets. `rifleman` is the baseline soldier, `heavy` a bulky
# armoured unit, `scout` a light unit, `elite` a New Game+ veteran and
# `civilian` an unarmed bystander with no military gear.
const VARIANT_RIFLEMAN := "rifleman"
const VARIANT_HEAVY := "heavy"
const VARIANT_SCOUT := "scout"
const VARIANT_ELITE := "elite"
const VARIANT_CIVILIAN := "civilian"

## Physics ragdoll: one capsule/box per bone, jointed along the hierarchy. Built
## lazily on the first death so live actors cost nothing. `len` is the distance
## to the child bone (the capsule is offset down by half of it), `box` overrides
## the shape for the pelvis and the feet.
const RAGDOLL_BONES := {
	"hips": {"box": Vector3(0.30, 0.22, 0.26), "mass": 10.0, "offset": Vector3(0, -0.02, 0)},
	"spine": {"r": 0.15, "len": 0.30, "mass": 9.0},
	"chest": {"r": 0.18, "len": 0.24, "mass": 12.0},
	"head": {"r": 0.11, "len": 0.22, "mass": 5.0},
	"arm_l": {"r": 0.07, "len": 0.30, "mass": 3.0},
	"arm_r": {"r": 0.07, "len": 0.30, "mass": 3.0},
	"forearm_l": {"r": 0.055, "len": 0.26, "mass": 2.0},
	"forearm_r": {"r": 0.055, "len": 0.26, "mass": 2.0},
	"hand_l": {"r": 0.05, "len": 0.10, "mass": 1.0},
	"hand_r": {"r": 0.05, "len": 0.10, "mass": 1.0},
	"leg_l": {"r": 0.085, "len": 0.42, "mass": 7.0},
	"leg_r": {"r": 0.085, "len": 0.42, "mass": 7.0},
	"shin_l": {"r": 0.065, "len": 0.38, "mass": 5.0},
	"shin_r": {"r": 0.065, "len": 0.38, "mass": 5.0},
	"foot_l": {"box": Vector3(0.11, 0.08, 0.24), "mass": 2.0, "offset": Vector3(0, -0.02, -0.06)},
	"foot_r": {"box": Vector3(0.11, 0.08, 0.24), "mass": 2.0, "offset": Vector3(0, -0.02, -0.06)},
}

var _skeleton: Skeleton3D
var _anim: AnimationPlayer
var _ragdoll: PhysicalBoneSimulator3D
var _ragdoll_built := false
var _material: StandardMaterial3D
var _weapon_mount: BoneAttachment3D
var _bones: Dictionary = {}
var _aiming := false
var _dead := false
var _part_count := 0
var _variant := VARIANT_RIFLEMAN
## Set while a one-shot clip (hit reaction, reload) owns the skeleton, so the
## locomotion chooser does not immediately override it.
var _one_shot := false


## `clothes` colours the body, `accent` the gear, `heavy` builds a bulkier
## figure and `variant` picks the silhouette (defaults to rifleman/heavy).
static func make(clothes: Color, accent: Color, heavy := false, variant := "") -> Character:
	var c := Character.new()
	c._build(clothes, accent, heavy, variant)
	return c


func body_part_count() -> int:
	return _part_count


func variant() -> String:
	return _variant


func is_dead() -> bool:
	return _dead


func _build(clothes: Color, accent: Color, heavy: bool, variant: String) -> void:
	_variant = variant
	if _variant == "":
		_variant = VARIANT_HEAVY if heavy else VARIANT_RIFLEMAN
	if heavy:
		scale = Vector3.ONE * 1.18
	_skeleton = Skeleton3D.new()
	_skeleton.name = "Skeleton"
	add_child(_skeleton)
	_build_skeleton()

	var skin := SKIN_DARK if heavy else SKIN
	var a := {
		"vertex": PackedVector3Array(), "normal": PackedVector3Array(),
		"uv": PackedVector2Array(), "color": PackedColorArray(),
		"bones": PackedInt32Array(), "weights": PackedFloat32Array(),
		"index": PackedInt32Array(),
	}
	if FileAccess.file_exists("res://assets/models/humanoid.glb"):
		_build_body_from_glb(a, clothes, accent, skin)
		_add_gear(a, _variant, accent)
	else:
		_build_body(a, clothes, accent, skin, _variant)

	_material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	_material.roughness = 0.72
	# Subsurface scattering: skin reads as organic rather than plastic (Forward+).
	# GL Compatibility ignores these and logs two warnings per run ("Subsurface
	# scattering is only available..." + "Transmittance..."). The headless tests
	# use the dummy driver, so only a real windowed run showed them.
	if RenderingServer.get_current_rendering_method() == "forward_plus":
		_material.subsurf_scatter_enabled = true
		_material.subsurf_scatter_strength = 0.4
		_material.subsurf_scatter_skin_mode = true
		_material.subsurf_scatter_transmittance_enabled = true
		_material.subsurf_scatter_transmittance_color = Color(0.85, 0.35, 0.25)
		_material.subsurf_scatter_transmittance_depth = 0.6
	# Woven micro-detail (if the generated texture exists): breaks up the flat
	# plastic look of the blockout body without recolouring it.
	var fabric := EnvBuilder.load_texture("res://assets/textures/fabric.png")
	if fabric:
		_material.albedo_texture = fabric
		_material.uv1_scale = Vector3(2, 2, 2)
		var fabric_normal := EnvBuilder.load_texture("res://assets/textures/fabric_normal.png")
		if fabric_normal:
			_material.normal_enabled = true
			_material.normal_texture = fabric_normal
			_material.normal_scale = 0.45
	var mesh := ArrayMesh.new()
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = a.vertex
	arr[Mesh.ARRAY_NORMAL] = a.normal
	arr[Mesh.ARRAY_TEX_UV] = a.uv
	arr[Mesh.ARRAY_COLOR] = a.color
	arr[Mesh.ARRAY_BONES] = a.bones
	arr[Mesh.ARRAY_WEIGHTS] = a.weights
	arr[Mesh.ARRAY_INDEX] = a.index
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh.surface_set_material(0, _material)
	var mi := MeshInstance3D.new()
	mi.name = "Body"
	mi.mesh = mesh
	_skeleton.add_child(mi)
	mi.skeleton = mi.get_path_to(_skeleton)

	_weapon_mount = BoneAttachment3D.new()
	_weapon_mount.name = "WeaponMount"
	_weapon_mount.bone_name = "hand_r"
	_weapon_mount.position = Vector3(0, -0.04, -0.12)
	_skeleton.add_child(_weapon_mount)

	_build_animations()


# -------------------------------------------------------------------- skeleton

func _build_skeleton() -> void:
	_bone("root", Vector3(0, 0, 0), "")
	_bone("hips", Vector3(0, 0.95, 0), "root")
	_bone("spine", Vector3(0, 0.10, 0), "hips")
	_bone("chest", Vector3(0, 0.30, 0), "spine")
	_bone("head", Vector3(0, 0.22, 0), "chest")
	for side in ["l", "r"]:
		var s := 1.0 if side == "l" else -1.0
		_bone("arm_" + side, Vector3(0.22 * s, 0.10, 0), "chest")
		_bone("forearm_" + side, Vector3(0, -0.30, 0), "arm_" + side)
		_bone("hand_" + side, Vector3(0, -0.26, 0), "forearm_" + side)
		_bone("leg_" + side, Vector3(0.11 * s, -0.05, 0), "hips")
		_bone("shin_" + side, Vector3(0, -0.42, 0), "leg_" + side)
		_bone("foot_" + side, Vector3(0, -0.38, 0), "shin_" + side)


func _bone(bone_name: String, offset: Vector3, parent: String) -> void:
	var idx := _skeleton.add_bone(bone_name)
	_skeleton.set_bone_rest(idx, Transform3D(Basis(), offset))
	if parent != "" and _bones.has(parent):
		_skeleton.set_bone_parent(idx, _bones[parent])
	_bones[bone_name] = idx


# ------------------------------------------------------------------------ mesh

func _build_body(a: Dictionary, clothes: Color, accent: Color, skin: Color, kind: String) -> void:
	# Smooth lofted volumes (superellipse cross-sections, rounded caps) instead of
	# flat-shaded boxes: the silhouette reads as a body, not as a blockout.
	_loft(a, Vector3(0, 0.95, 0), Vector3(0.36, 0.26, 0.26), "hips", clothes,
		[0.80, 0.94, 1.0, 0.98, 0.88], 14, 0.55, 2.6)
	_loft(a, Vector3(0, 1.17, 0), Vector3(0.39, 0.30, 0.27), "spine", clothes,
		[0.90, 0.86, 0.90, 0.99, 1.0], 14, 0.45, 2.9)
	_loft(a, Vector3(0, 1.40, 0), Vector3(0.46, 0.36, 0.30), "chest", clothes,
		[0.84, 0.94, 1.0, 1.0, 0.90], 16, 0.40, 3.1)
	# Chest rig / plate carrier, slightly wider than the chest itself.
	_loft(a, Vector3(0, 1.40, 0), Vector3(0.49, 0.28, 0.33), "chest", accent,
		[0.90, 0.98, 1.0, 0.98, 0.90], 16, 0.30, 3.4)
	_loft(a, Vector3(0, 1.70, 0), Vector3(0.235, 0.28, 0.235), "head", skin,
		[0.60, 0.82, 0.97, 1.0, 0.86], 14, 0.85, 2.4)
	for side in ["l", "r"]:
		var s := 1.0 if side == "l" else -1.0
		_loft(a, Vector3(0.24 * s, 1.30, 0), Vector3(0.135, 0.32, 0.145), "arm_" + side, clothes,
			[0.70, 0.90, 1.0, 0.94, 0.80], 12, 0.75, 2.2)
		_loft(a, Vector3(0.24 * s, 1.02, 0), Vector3(0.115, 0.28, 0.125), "forearm_" + side, clothes,
			[0.76, 0.94, 1.0, 0.90, 0.74], 12, 0.70, 2.2)
		_loft(a, Vector3(0.24 * s, 0.87, 0), Vector3(0.10, 0.12, 0.105), "hand_" + side, skin,
			[0.80, 1.0, 0.94, 0.74], 10, 0.65, 2.8)
		_loft(a, Vector3(0.11 * s, 0.70, 0), Vector3(0.155, 0.42, 0.165), "leg_" + side, clothes,
			[0.86, 1.0, 1.0, 0.86, 0.74], 14, 0.50, 2.4)
		_loft(a, Vector3(0.11 * s, 0.29, 0), Vector3(0.135, 0.40, 0.145), "shin_" + side, clothes,
			[0.74, 0.90, 1.0, 0.90, 0.78], 12, 0.45, 2.4)
		_part(a, Vector3(0.11 * s, 0.06, -0.04), Vector3(0.14, 0.12, 0.24), "foot_" + side, accent)
	_add_gear(a, kind, accent)


## Military kit that turns the blockout figure into a readable soldier, or a
## lighter scarf-and-bag silhouette for civilians.
func _add_gear(a: Dictionary, kind: String, accent: Color) -> void:
	var gear := accent.darkened(0.12)
	var strap := Color(0.10, 0.10, 0.12)
	match kind:
		VARIANT_CIVILIAN:
			_part(a, Vector3(0, 1.52, 0), Vector3(0.34, 0.08, 0.30), "chest", accent)
			_part(a, Vector3(0.20, 1.20, 0.14), Vector3(0.16, 0.22, 0.10), "chest", accent)
		VARIANT_SCOUT:
			# Soft cap, belt and a single chest pouch: light and fast.
			_part(a, Vector3(0, 1.84, 0), Vector3(0.27, 0.07, 0.27), "head", gear)
			_part(a, Vector3(0, 1.79, -0.13), Vector3(0.26, 0.025, 0.07), "head", strap)
			_part(a, Vector3(0, 1.07, 0), Vector3(0.37, 0.05, 0.27), "hips", strap)
			_part(a, Vector3(0, 1.31, -0.17), Vector3(0.22, 0.10, 0.05), "chest", gear)
		VARIANT_HEAVY, VARIANT_ELITE:
			# Full helmet, shoulder plates, knee pads, backpack and chest rig.
			_part(a, Vector3(0, 1.84, 0), Vector3(0.31, 0.15, 0.31), "head", gear)
			_part(a, Vector3(0, 1.77, -0.14), Vector3(0.28, 0.05, 0.07), "head", strap)
			for side in ["l", "r"]:
				var s := 1.0 if side == "l" else -1.0
				_part(a, Vector3(0.27 * s, 1.48, 0), Vector3(0.20, 0.13, 0.22), "arm_" + side, gear)
				_part(a, Vector3(0.12 * s, 0.36, -0.07), Vector3(0.16, 0.13, 0.17), "shin_" + side, gear)
			_part(a, Vector3(0, 1.43, 0.20), Vector3(0.34, 0.36, 0.16), "chest", gear)
			for i in 3:
				_part(a, Vector3(-0.12 + i * 0.12, 1.31, -0.18), Vector3(0.10, 0.12, 0.05), "chest", strap)
			_add_visor(Color(1.0, 0.32, 0.18) if kind == VARIANT_HEAVY else Color(0.35, 0.9, 1.0))
		_:
			# Rifleman: helmet, chest rig, backpack and knee pads.
			_part(a, Vector3(0, 1.84, 0), Vector3(0.28, 0.12, 0.28), "head", gear)
			_part(a, Vector3(0, 1.79, -0.13), Vector3(0.26, 0.03, 0.07), "head", strap)
			for side in ["l", "r"]:
				var s := 1.0 if side == "l" else -1.0
				_part(a, Vector3(0.12 * s, 0.36, -0.07), Vector3(0.15, 0.11, 0.16), "shin_" + side, gear)
			for i in 3:
				_part(a, Vector3(-0.12 + i * 0.12, 1.31, -0.18), Vector3(0.10, 0.12, 0.05), "chest", strap)
			_part(a, Vector3(0, 1.43, 0.19), Vector3(0.30, 0.32, 0.14), "chest", gear)
			_add_visor(Color(0.35, 0.9, 1.0))


## Small emissive visor attached to the head bone. Adds a readable "face" to
## helmeted units without a second material on the skinned body.
func _add_visor(color: Color) -> void:
	var mount := BoneAttachment3D.new()
	mount.name = "HeadGear"
	mount.bone_name = "head"
	_skeleton.add_child(mount)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.20, 0.05, 0.03)
	mi.mesh = box
	mi.position = Vector3(0, 0.13, -0.13)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.8
	mi.material_override = mat
	mount.add_child(mi)


## Builds the body from the Blender-authored mesh (`assets/models/humanoid.glb`),
## skinning every vertex to its nearest bone (rigid 1-bone skinning, same as the
## procedural body). Falls back to the lofted body if the file is missing.
func _build_body_from_glb(a: Dictionary, clothes: Color, accent: Color, skin: Color) -> void:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file("res://assets/models/humanoid.glb", state) != OK:
		_build_body(a, clothes, accent, skin, _variant)
		return
	var scene := doc.generate_scene(state) as Node3D
	if scene == null:
		_build_body(a, clothes, accent, skin, _variant)
		return
	var mi := _find_mesh_instance(scene)
	if mi == null or mi.mesh == null:
		scene.queue_free()
		_build_body(a, clothes, accent, skin, _variant)
		return
	var src := mi.mesh as ArrayMesh
	var arrays := src.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL] if arrays[Mesh.ARRAY_NORMAL] != null else PackedVector3Array()
	var cols: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV] != null else PackedVector2Array()
	var idxs: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()

	# Bone world positions for nearest-bone skinning.
	var bone_pos := []
	for bn in _bones.keys():
		var bi: int = _bones[bn]
		var gtr := _skeleton.get_bone_global_rest(bi)
		bone_pos.append({"idx": bi, "pos": gtr.origin})

	# Deindex into a flat triangle soup.
	var dv := PackedVector3Array()
	var dn := PackedVector3Array()
	var dc := PackedColorArray()
	var du := PackedVector2Array()
	if idxs.size() > 0:
		for i in idxs:
			dv.append(verts[i])
			if norms.size() == verts.size():
				dn.append(norms[i])
			if cols.size() == verts.size():
				dc.append(cols[i])
			if uvs.size() == verts.size():
				du.append(uvs[i])
	else:
		dv = verts
		dn = norms
		dc = cols
		du = uvs

	for i in dv.size():
		a.vertex.append(dv[i])
		if dn.size() == dv.size():
			a.normal.append(dn[i])
		else:
			a.normal.append(Vector3.UP)
		if du.size() == dv.size():
			a.uv.append(du[i])
		else:
			a.uv.append(Vector2.ZERO)
		var c := clothes
		if dc.size() == dv.size():
			c = dc[i]
		a.color.append(c)
		var v := dv[i]
		var best_idx := 0
		var best_d := 1e18
		for bp in bone_pos:
			var d := v.distance_squared_to(bp["pos"])
			if d < best_d:
				best_d = d
				best_idx = bp["idx"]
		a.bones.append_array([best_idx, 0, 0, 0])
		a.weights.append_array([1.0, 0.0, 0.0, 0.0])
	for i in dv.size():
		a.index.append(i)
	_part_count += 1
	scene.queue_free()


func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child in node.get_children():
		var found := _find_mesh_instance(child)
		if found:
			return found
	return null


## Smooth lofted volume (fallback when the GLB is missing).
## `profile` (multipliers, bottom to top) with hemispherical caps. `squareness`
## 2.0 gives a circle, higher values approach a rounded rectangle (torsos).
func _loft(a: Dictionary, center: Vector3, size: Vector3, bone: String, color: Color,
		profile: Array, sides: int, roundness: float, squareness: float) -> void:
	if not _bones.has(bone):
		return
	var bi: int = _bones[bone]
	var rings: int = profile.size()
	if rings < 2:
		return
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var idx := PackedInt32Array()
	var half_y := size.y * 0.5
	var end_rx := size.x * 0.5 * float(profile[rings - 1])
	var end_rz := size.z * 0.5 * float(profile[rings - 1])
	var cap_h := minf(end_rx, end_rz) * roundness
	var expo := 2.0 / squareness

	for i in rings:
		var t := float(i) / float(rings - 1)
		var mult: float = float(profile[i])
		var y := lerpf(-half_y, half_y, t)
		for s in sides:
			var ang := TAU * float(s) / float(sides)
			var ca := cos(ang)
			var sa := sin(ang)
			var sx := signf(ca) * pow(absf(ca), expo)
			var sz := signf(sa) * pow(absf(sa), expo)
			verts.append(center + Vector3(sx * size.x * 0.5 * mult, y, sz * size.z * 0.5 * mult))
			uvs.append(Vector2(float(s) / float(sides), t))

	# Hemispherical caps (cap_steps-1 rings + a pole each): domed, not cut flat.
	var cap_steps := 3
	for cap in [1.0, -1.0]:
		var first_ring := verts.size()
		for k in range(1, cap_steps):
			var theta := (PI * 0.5) * float(k) / float(cap_steps)
			var rs := cos(theta)
			var y: float = cap * (half_y + cap_h * sin(theta))
			for s in sides:
				var ang := TAU * float(s) / float(sides)
				var ca := cos(ang)
				var sa := sin(ang)
				var sx := signf(ca) * pow(absf(ca), expo)
				var sz := signf(sa) * pow(absf(sa), expo)
				verts.append(center + Vector3(sx * end_rx * rs, y, sz * end_rz * rs))
				uvs.append(Vector2(float(s) / float(sides), 0.0 if cap < 0.0 else 1.0))
		var pole := verts.size()
		verts.append(center + Vector3(0, cap * (half_y + cap_h), 0))
		uvs.append(Vector2(0.5, 0.0 if cap < 0.0 else 1.0))
		# Bridge the body ring -> each cap ring -> pole.
		var prev := 0 if cap < 0.0 else (rings - 1) * sides
		for k in range(0, cap_steps - 1):
			var ring := first_ring + k * sides
			for s in sides:
				var s2 := (s + 1) % sides
				idx.append_array([prev + s, prev + s2, ring + s2, prev + s, ring + s2, ring + s])
			prev = ring
		for s in sides:
			var s2 := (s + 1) % sides
			idx.append_array([prev + s, prev + s2, pole])

	# Side walls between the body rings.
	for i in rings - 1:
		for s in sides:
			var s2 := (s + 1) % sides
			var i0 := i * sides + s
			var i1 := i * sides + s2
			var i2 := (i + 1) * sides + s2
			var i3 := (i + 1) * sides + s
			idx.append_array([i0, i1, i2, i0, i2, i3])

	# Make every triangle face outward (these volumes are star-shaped around
	# `center`), which removes any winding mistake at the cap/body seams.
	for i in range(0, idx.size(), 3):
		var ia := idx[i]
		var ib := idx[i + 1]
		var ic := idx[i + 2]
		var face := (verts[ib] - verts[ia]).cross(verts[ic] - verts[ia])
		var centroid := (verts[ia] + verts[ib] + verts[ic]) / 3.0
		if face.dot(centroid - center) < 0.0:
			idx[i + 1] = ic
			idx[i + 2] = ib
	var normals := _compute_normals(verts, idx)

	var base: int = a.vertex.size()
	for i in verts.size():
		a.vertex.append(verts[i])
		a.normal.append(normals[i])
		a.uv.append(uvs[i])
		a.color.append(color)
		a.bones.append_array([bi, 0, 0, 0])
		a.weights.append_array([1.0, 0.0, 0.0, 0.0])
	for i in idx.size():
		a.index.append(base + idx[i])
	_part_count += 1


## Area-weighted smooth normals for an indexed triangle soup.
func _compute_normals(verts: PackedVector3Array, idx: PackedInt32Array) -> PackedVector3Array:
	var normals := PackedVector3Array()
	normals.resize(verts.size())
	for i in range(0, idx.size(), 3):
		var ia := idx[i]
		var ib := idx[i + 1]
		var ic := idx[i + 2]
		var face := (verts[ib] - verts[ia]).cross(verts[ic] - verts[ia])
		normals[ia] = normals[ia] + face
		normals[ib] = normals[ib] + face
		normals[ic] = normals[ic] + face
	for i in normals.size():
		var l := normals[i].length()
		normals[i] = normals[i] / l if l > 0.000001 else Vector3.UP
	return normals


## Adds a (optionally tapered) box fully weighted to one bone.
func _part(a: Dictionary, center: Vector3, size: Vector3, bone: String, color: Color, top := 1.0) -> void:
	if not _bones.has(bone):
		return
	var b := size * 0.5
	var t := Vector3(b.x * top, b.y, b.z * top)
	var faces := [
		[Vector3(1, 0, 0), [Vector3(b.x, -b.y, -b.z), Vector3(b.x, b.y, -t.z), Vector3(b.x, b.y, t.z), Vector3(b.x, -b.y, b.z)]],
		[Vector3(-1, 0, 0), [Vector3(-b.x, -b.y, b.z), Vector3(-b.x, b.y, t.z), Vector3(-b.x, b.y, -t.z), Vector3(-b.x, -b.y, -b.z)]],
		[Vector3(0, 1, 0), [Vector3(-t.x, b.y, t.z), Vector3(t.x, b.y, t.z), Vector3(t.x, b.y, -t.z), Vector3(-t.x, b.y, -t.z)]],
		[Vector3(0, -1, 0), [Vector3(-b.x, -b.y, -b.z), Vector3(b.x, -b.y, -b.z), Vector3(b.x, -b.y, b.z), Vector3(-b.x, -b.y, b.z)]],
		[Vector3(0, 0, 1), [Vector3(-b.x, -b.y, b.z), Vector3(b.x, -b.y, b.z), Vector3(t.x, b.y, t.z), Vector3(-t.x, b.y, t.z)]],
		[Vector3(0, 0, -1), [Vector3(b.x, -b.y, -b.z), Vector3(-b.x, -b.y, -b.z), Vector3(-t.x, b.y, -t.z), Vector3(t.x, b.y, -t.z)]],
	]
	var bi: int = _bones[bone]
	for f in faces:
		var base: int = a.vertex.size()
		var n: Vector3 = f[0]
		var face_uv := [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
		var vi := 0
		for v in f[1]:
			a.vertex.append(v + center)
			a.normal.append(n)
			a.uv.append(face_uv[vi])
			a.color.append(color)
			a.bones.append_array([bi, 0, 0, 0])
			a.weights.append_array([1.0, 0.0, 0.0, 0.0])
			vi += 1
		a.index.append_array([base, base + 1, base + 2, base, base + 2, base + 3])
	_part_count += 1


# ------------------------------------------------------------------ animations

func _build_animations() -> void:
	_anim = AnimationPlayer.new()
	_anim.name = "AnimationPlayer"
	_skeleton.add_child(_anim)
	var lib := AnimationLibrary.new()
	lib.add_animation("idle", _loco_anim(2.0, 0.0, false))
	lib.add_animation("walk", _loco_anim(1.0, 1.0, false))
	lib.add_animation("run", _loco_anim(0.66, 1.7, false))
	lib.add_animation("aim_idle", _loco_anim(2.0, 0.0, true))
	lib.add_animation("aim_walk", _loco_anim(1.0, 1.0, true))
	lib.add_animation("aim_run", _loco_anim(0.66, 1.7, true))
	lib.add_animation("death", _death_anim())
	lib.add_animation("hit", _hit_anim())
	lib.add_animation("reload", _reload_anim())
	_anim.add_animation_library("", lib)
	_anim.animation_finished.connect(_on_anim_finished)


func _on_anim_finished(_clip: StringName) -> void:
	_one_shot = false


# ------------------------------------------------------------------- ragdoll

## Builds the physics rig once: one PhysicalBone3D per skeleton bone, shapes
## sized from RAGDOLL_BONES. Joints are created by the simulator from the bone
## hierarchy.
func _build_ragdoll() -> void:
	if _ragdoll_built:
		return
	_ragdoll_built = true
	_ragdoll = PhysicalBoneSimulator3D.new()
	_ragdoll.name = "Ragdoll"
	_skeleton.add_child(_ragdoll)
	for bone_name in RAGDOLL_BONES:
		var cfg: Dictionary = RAGDOLL_BONES[bone_name]
		var pb := PhysicalBone3D.new()
		pb.name = "PB_" + String(bone_name)
		pb.bone_name = StringName(bone_name)
		pb.mass = float(cfg.get("mass", 4.0))
		pb.friction = 0.9
		pb.bounce = 0.0
		pb.linear_damp = 0.15
		pb.angular_damp = 0.5
		pb.gravity_scale = 1.2
		# Dead bodies settle on the world (mask 1) but no longer block shots or
		# shove living actors (own layer 0).
		pb.collision_layer = 0
		pb.collision_mask = 1
		var cs := CollisionShape3D.new()
		var offset: Vector3 = cfg.get("offset", Vector3.ZERO)
		if cfg.has("box"):
			var box := BoxShape3D.new()
			box.size = cfg["box"]
			cs.shape = box
			if not cfg.has("offset"):
				offset = Vector3(0, -box.size.y * 0.5, 0)
		else:
			var r: float = float(cfg.get("r", 0.1))
			var length: float = float(cfg.get("len", 0.2))
			var cap := CapsuleShape3D.new()
			cap.radius = r
			cap.height = maxf(length + r * 2.0, r * 2.0 + 0.001)
			cs.shape = cap
			if not cfg.has("offset"):
				offset = Vector3(0, -length * 0.5, 0)
		cs.position = offset
		pb.add_child(cs)
		_ragdoll.add_child(pb)


## Hands the body over to physics. `push` is an optional impulse (m/s) applied
## to every bone, e.g. the direction the killing shot came from.
func _start_ragdoll(push := Vector3.ZERO) -> void:
	if _ragdoll == null:
		_build_ragdoll()
	if _anim:
		_anim.stop()
	if _ragdoll == null:
		return
	_ragdoll.physical_bones_start_simulation()
	if push.length_squared() > 0.0001:
		for child in _ragdoll.get_children():
			var pb := child as PhysicalBone3D
			if pb:
				pb.linear_velocity = push


## True once the body is simulated by physics (used by tests/diagnostics).
func is_ragdoll_active() -> bool:
	return _ragdoll != null and _ragdoll.is_simulating_physics()


## Locomotion cycle: legs and arms swing with `amount`; `aiming` raises the arms.
## Key times are scaled to the clip length so run (0.66 s) and idle (2 s) both
## complete a full cycle instead of holding or truncating.
func _loco_anim(length: float, amount: float, aiming: bool) -> Animation:
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR
	var q := length
	var swing := 0.5 * amount
	var arm := 0.45 * amount
	_rot(anim, "leg_l", [[0.0, swing], [0.25 * q, 0.0], [0.5 * q, -swing], [0.75 * q, 0.0], [q, swing]])
	_rot(anim, "leg_r", [[0.0, -swing], [0.25 * q, 0.0], [0.5 * q, swing], [0.75 * q, 0.0], [q, -swing]])
	_rot(anim, "shin_l", [[0.0, -0.12], [0.25 * q, -0.65 * amount], [0.5 * q, -0.05], [0.75 * q, -0.4 * amount], [q, -0.12]])
	_rot(anim, "shin_r", [[0.0, -0.05], [0.25 * q, -0.4 * amount], [0.5 * q, -0.12], [0.75 * q, -0.65 * amount], [q, -0.05]])
	_rot(anim, "spine", [[0.0, 0.05 * amount], [0.5 * q, 0.12 * amount], [q, 0.05 * amount]])
	# Breathing: the chest lifts slightly every cycle, even standing still.
	_rot(anim, "chest", [[0.0, 0.0], [0.5 * q, 0.035 + 0.05 * amount], [q, 0.0]])
	# Two footfalls per cycle, so the pelvis bobs twice.
	if amount > 0.05:
		var bob := 0.035 * amount
		_pos(anim, "hips", [[0.0, 0.0], [0.25 * q, bob], [0.5 * q, 0.0], [0.75 * q, bob], [q, 0.0]])
	if aiming:
		_rot(anim, "arm_l", [[0.0, -1.25], [q, -1.25]])
		_rot(anim, "arm_r", [[0.0, -1.45], [q, -1.45]])
		_rot(anim, "forearm_l", [[0.0, -0.55], [q, -0.55]])
		_rot(anim, "forearm_r", [[0.0, -0.65], [q, -0.65]])
	else:
		_rot(anim, "arm_l", [[0.0, -arm], [0.25 * q, 0.0], [0.5 * q, arm], [0.75 * q, 0.0], [q, -arm]])
		_rot(anim, "arm_r", [[0.0, arm], [0.25 * q, 0.0], [0.5 * q, -arm], [0.75 * q, 0.0], [q, arm]])
		_rot(anim, "forearm_l", [[0.0, -0.2], [q, -0.2]])
		_rot(anim, "forearm_r", [[0.0, -0.2], [q, -0.2]])
	return anim


func _death_anim() -> Animation:
	var anim := Animation.new()
	anim.length = 0.9
	anim.loop_mode = Animation.LOOP_NONE
	_rot(anim, "hips", [[0.0, 0.0], [0.5, -1.3], [0.9, -1.55]])
	_rot(anim, "spine", [[0.0, 0.0], [0.5, 0.4], [0.9, 0.5]])
	_rot(anim, "arm_l", [[0.0, 0.0], [0.9, 0.6]])
	_rot(anim, "arm_r", [[0.0, 0.0], [0.9, 0.6]])
	return anim


func _rot(anim: Animation, bone: String, keys: Array) -> void:
	if not _bones.has(bone):
		return
	var t := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(t, NodePath(":" + bone))
	for k in keys:
		anim.rotation_track_insert_key(t, k[0], Quaternion(Vector3.RIGHT, k[1]))


## Vertical offset track, expressed relative to the bone's rest position.
func _pos(anim: Animation, bone: String, keys: Array) -> void:
	if not _bones.has(bone):
		return
	var t := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t, NodePath(":" + bone))
	var rest := _skeleton.get_bone_rest(_bones[bone]).origin
	for k in keys:
		anim.position_track_insert_key(t, k[0], rest + Vector3(0, k[1], 0))


# ------------------------------------------------------------------- interface

## Chooses the right clip for the current speed and aiming state and blends in.
func animate_walk(delta: float, speed01: float) -> void:
	if _dead or _anim == null:
		return
	if _one_shot:
		return
	var aiming := _aiming
	_aiming = false
	var clip := "idle"
	var sp := 1.0
	if speed01 < 0.06:
		clip = "aim_idle" if aiming else "idle"
	else:
		var running := speed01 > 0.55
		if aiming:
			clip = "aim_run" if running else "aim_walk"
		else:
			clip = "run" if running else "walk"
		sp = clampf(0.7 + speed01 * 1.3, 0.7, 2.0)
	if _anim.current_animation != clip and _anim.has_animation(clip):
		_anim.play(clip, BLEND)
	_anim.speed_scale = sp


## Requests the aiming pose for this frame (call every frame while aiming).
func aim(_pitch: float) -> void:
	_aiming = true


## Reload: right hand drops to the magazine and comes back; head glances down.
func _reload_anim() -> Animation:
	var anim := Animation.new()
	anim.length = 1.5
	anim.loop_mode = Animation.LOOP_NONE
	_rot(anim, "arm_r", [[0.0, 0.0], [0.2, -0.35], [0.6, -0.55], [1.0, -0.35], [1.5, 0.0]])
	_rot(anim, "forearm_r", [[0.0, -0.2], [0.2, -0.75], [0.6, -1.15], [1.0, -0.75], [1.5, -0.2]])
	_rot(anim, "arm_l", [[0.0, 0.0], [0.2, -0.25], [1.0, -0.25], [1.5, 0.0]])
	_rot(anim, "chest", [[0.0, 0.0], [0.3, 0.12], [1.2, 0.12], [1.5, 0.0]])
	_rot(anim, "head", [[0.0, 0.0], [0.2, 0.35], [1.1, 0.35], [1.5, 0.0]])
	return anim


func _hit_anim() -> Animation:
	var anim := Animation.new()
	anim.length = 0.45
	anim.loop_mode = Animation.LOOP_NONE
	_rot(anim, "hips", [[0.0, 0.0], [0.1, -0.4], [0.45, 0.0]])
	_rot(anim, "spine", [[0.0, 0.0], [0.1, 0.6], [0.45, 0.0]])
	_rot(anim, "chest", [[0.0, 0.0], [0.1, 0.3], [0.45, 0.0]])
	_rot(anim, "arm_l", [[0.0, 0.0], [0.1, 0.8], [0.45, 0.0]])
	_rot(anim, "arm_r", [[0.0, 0.0], [0.1, 0.8], [0.45, 0.0]])
	_rot(anim, "head", [[0.0, 0.0], [0.1, -0.3], [0.45, 0.0]])
	return anim


## Plays the death fall once; the actor keeps the final pose.
func die() -> void:
	if _dead:
		return
	_dead = true
	if is_inside_tree():
		var p := get_parent() as Node3D
		if p:
			Vfx.blood_splat(p, global_position)
	if _anim and _anim.has_animation("death"):
		_anim.speed_scale = 1.0
		_anim.play("death", 0.1)
	# The animation plays for a beat, then physics takes over so the body lands
	# on the geometry instead of sinking through it.
	var push := global_transform.basis.z * 0.8
	var timer := get_tree().create_timer(0.35) if is_inside_tree() else null
	if timer:
		# Bound method instead of a lambda: the connection is dropped
		# automatically when the character is freed, so it can never fire on a
		# dead instance (which logged "Lambda capture ... was freed").
		timer.timeout.connect(_fall_after_delay.bind(push))


## Delayed second half of `die()`: the fall animation has played, hand the body
## to the ragdoll. Does nothing if the actor was already removed.
func _fall_after_delay(push: Vector3) -> void:
	if not _dead:
		return
	Audio.body_fall()
	_start_ragdoll(push)


## Plays a hit stagger once (blends back to locomotion afterwards).
## Plays the reload gesture once (the magazine timer is owned by the mode).
func play_reload() -> void:
	if _dead or _anim == null:
		return
	if _anim.has_animation("reload"):
		_one_shot = true
		_anim.play("reload", 0.08)


## Plays a hit stagger once.
func hit_react() -> void:
	if _dead or _anim == null:
		return
	if _anim.has_animation("hit"):
		_one_shot = true
		_anim.play("hit", 0.05)


## Briefly flashes the body white to signal a hit.
func flash() -> void:
	if _material == null:
		return
	_material.emission_enabled = true
	_material.emission = Color(1, 1, 1)
	_material.emission_energy_multiplier = 1.5
	var tween := create_tween()
	tween.tween_property(_material, "emission_energy_multiplier", 0.0, 0.2)


## Node the weapon is attached to (the right hand bone).
func weapon_mount() -> Node3D:
	return _weapon_mount
