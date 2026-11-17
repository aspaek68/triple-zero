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

var _skeleton: Skeleton3D
var _anim: AnimationPlayer
var _material: StandardMaterial3D
var _weapon_mount: BoneAttachment3D
var _bones: Dictionary = {}
var _aiming := false
var _dead := false
var _part_count := 0
var _variant := VARIANT_RIFLEMAN


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
	_build_body(a, clothes, accent, skin, _variant)

	_material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	_material.roughness = 0.72
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
	_part(a, Vector3(0, 0.95, 0), Vector3(0.36, 0.24, 0.26), "hips", clothes)
	_part(a, Vector3(0, 1.16, 0), Vector3(0.40, 0.30, 0.27), "spine", clothes)
	_part(a, Vector3(0, 1.40, 0), Vector3(0.46, 0.34, 0.30), "chest", clothes)
	_part(a, Vector3(0, 1.36, 0), Vector3(0.50, 0.30, 0.34), "chest", accent)
	_part(a, Vector3(0, 1.70, 0), Vector3(0.24, 0.26, 0.24), "head", skin)
	_part(a, Vector3(0, 1.83, 0), Vector3(0.27, 0.12, 0.27), "head", accent)
	for side in ["l", "r"]:
		var s := 1.0 if side == "l" else -1.0
		_part(a, Vector3(0.24 * s, 1.30, 0), Vector3(0.13, 0.32, 0.14), "arm_" + side, clothes, 0.85)
		_part(a, Vector3(0.24 * s, 1.02, 0), Vector3(0.11, 0.28, 0.12), "forearm_" + side, clothes, 0.9)
		_part(a, Vector3(0.24 * s, 0.87, 0), Vector3(0.10, 0.10, 0.10), "hand_" + side, skin)
		_part(a, Vector3(0.11 * s, 0.70, 0), Vector3(0.15, 0.42, 0.16), "leg_" + side, clothes, 0.8)
		_part(a, Vector3(0.11 * s, 0.29, 0), Vector3(0.13, 0.40, 0.14), "shin_" + side, clothes, 0.85)
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
	_anim.add_animation_library("", lib)


## Locomotion cycle: legs and arms swing with `amount`; `aiming` raises the arms.
func _loco_anim(length: float, amount: float, aiming: bool) -> Animation:
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR
	var swing := 0.5 * amount
	var arm := 0.45 * amount
	_rot(anim, "leg_l", [[0.0, swing], [0.25, 0.0], [0.5, -swing], [0.75, 0.0], [1.0, swing]])
	_rot(anim, "leg_r", [[0.0, -swing], [0.25, 0.0], [0.5, swing], [0.75, 0.0], [1.0, -swing]])
	_rot(anim, "shin_l", [[0.0, -0.12], [0.25, -0.65 * amount], [0.5, -0.05], [0.75, -0.4 * amount], [1.0, -0.12]])
	_rot(anim, "shin_r", [[0.0, -0.05], [0.25, -0.4 * amount], [0.5, -0.12], [0.75, -0.65 * amount], [1.0, -0.05]])
	_rot(anim, "spine", [[0.0, 0.05 * amount], [0.5, 0.12 * amount], [1.0, 0.05 * amount]])
	if aiming:
		_rot(anim, "arm_l", [[0.0, -1.25], [1.0, -1.25]])
		_rot(anim, "arm_r", [[0.0, -1.45], [1.0, -1.45]])
		_rot(anim, "forearm_l", [[0.0, -0.55], [1.0, -0.55]])
		_rot(anim, "forearm_r", [[0.0, -0.65], [1.0, -0.65]])
	else:
		_rot(anim, "arm_l", [[0.0, -arm], [0.25, 0.0], [0.5, arm], [0.75, 0.0], [1.0, -arm]])
		_rot(anim, "arm_r", [[0.0, arm], [0.25, 0.0], [0.5, -arm], [0.75, 0.0], [1.0, arm]])
		_rot(anim, "forearm_l", [[0.0, -0.2], [1.0, -0.2]])
		_rot(anim, "forearm_r", [[0.0, -0.2], [1.0, -0.2]])
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


# ------------------------------------------------------------------- interface

## Chooses the right clip for the current speed and aiming state and blends in.
func animate_walk(delta: float, speed01: float) -> void:
	if _dead or _anim == null:
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


## Plays the death fall once; the actor keeps the final pose.
func die() -> void:
	if _dead:
		return
	_dead = true
	if _anim and _anim.has_animation("death"):
		_anim.speed_scale = 1.0
		_anim.play("death", 0.1)


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
