class_name Weapon
extends Node3D
## An assault rifle assembled from primitives: barrel, receiver, handguard,
## magazine, pistol grip, stock and an optic. Used in first-person view and
## mounted in the hands of characters, with recoil and muzzle flash.

var _recoil := 0.0
var _rest := Vector3.ZERO
var _flash: MeshInstance3D
var _flash_timer := 0.0
var _muzzle_marker: Node3D


static func make() -> Weapon:
	var w := Weapon.new()
	w._build()
	return w


func _build() -> void:
	var metal := EnvBuilder.material(Color(0.16, 0.17, 0.19), 0.35, 0.85)
	var dark := EnvBuilder.material(Color(0.10, 0.10, 0.12), 0.5, 0.6)
	var polymer := EnvBuilder.material(Color(0.13, 0.14, 0.15), 0.75, 0.0)
	var glass := EnvBuilder.material(Color(0.2, 0.5, 0.55), 0.1, 0.0)

	# Receiver (main body).
	_box(Vector3(0.07, 0.09, 0.34), Vector3(0, 0, 0.02), metal)
	# Handguard forward of the receiver.
	_box(Vector3(0.06, 0.07, 0.26), Vector3(0, 0.005, -0.28), polymer)
	# Barrel.
	_cyl(0.018, 0.36, Vector3(0, 0.01, -0.52), Vector3(90, 0, 0), metal)
	# Muzzle brake.
	_cyl(0.028, 0.07, Vector3(0, 0.01, -0.71), Vector3(90, 0, 0), dark)
	# Magazine, angled forward.
	var mag := _box(Vector3(0.045, 0.20, 0.09), Vector3(0, -0.15, -0.02), polymer)
	mag.rotation_degrees = Vector3(-14, 0, 0)
	# Pistol grip, angled back.
	var grip := _box(Vector3(0.05, 0.15, 0.07), Vector3(0, -0.13, 0.14), polymer)
	grip.rotation_degrees = Vector3(18, 0, 0)
	# Trigger guard.
	_box(Vector3(0.04, 0.012, 0.09), Vector3(0, -0.07, 0.08), dark)
	# Stock.
	_box(Vector3(0.05, 0.07, 0.20), Vector3(0, -0.01, 0.30), polymer)
	_box(Vector3(0.055, 0.11, 0.05), Vector3(0, -0.02, 0.40), dark)
	# Optic: base, tube, lens.
	_box(Vector3(0.04, 0.03, 0.10), Vector3(0, 0.075, -0.04), dark)
	_cyl(0.028, 0.14, Vector3(0, 0.10, -0.04), Vector3(90, 0, 0), dark)
	_cyl(0.03, 0.012, Vector3(0, 0.10, -0.11), Vector3(90, 0, 0), glass)
	# Iron sight post at the front.
	_box(Vector3(0.012, 0.05, 0.012), Vector3(0, 0.055, -0.40), dark)

	# Muzzle flash quad, hidden until fired.
	_flash = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.35, 0.35)
	_flash.mesh = quad
	var flash_mat := EnvBuilder.material(Color(1.0, 0.85, 0.4))
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1.0, 0.8, 0.3)
	flash_mat.emission_energy_multiplier = 3.0
	_flash.material_override = flash_mat
	_flash.position = Vector3(0, 0.01, -0.74)
	_flash.visible = false
	add_child(_flash)

	_muzzle_marker = Node3D.new()
	_muzzle_marker.position = Vector3(0, 0.01, -0.74)
	add_child(_muzzle_marker)

	_rest = position


func _box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.material_override = mat
	add_child(mi)
	return mi


func _cyl(radius: float, height: float, pos: Vector3, rot_deg: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = height
	cm.radial_segments = 12
	mi.mesh = cm
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.material_override = mat
	add_child(mi)
	return mi


func muzzle() -> Node3D:
	return _muzzle_marker


## Fires: kicks the weapon back and shows the flash briefly.
func fire() -> void:
	_recoil = 0.06
	_flash.visible = true
	_flash_timer = 0.045
	_flash.rotation.z = randf_range(0, TAU)


func _process(delta: float) -> void:
	if _recoil > 0.0:
		_recoil = maxf(_recoil - delta * 0.5, 0.0)
		position = _rest + Vector3(0, _recoil * 0.2, _recoil)
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_flash.visible = false
