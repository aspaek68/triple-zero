class_name Vfx
extends RefCounted
## Short-lived shot feedback shared by the two shooting acts: a thin tracer
## from the muzzle to the impact, and a small emissive spark where the shot
## lands. Everything is unshaded, casts no shadow and frees itself, so it stays
## cheap and works on the compatibility renderer.

## Draws a tracer from `from` to `to` under `parent` (a Node3D in the world).
static func tracer(parent: Node3D, from: Vector3, to: Vector3,
	color := Color(1.0, 0.85, 0.45)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var dist := from.distance_to(to)
	if dist < 0.6:
		return
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.014
	mesh.bottom_radius = 0.014
	mesh.height = dist
	mesh.radial_segments = 4
	mesh.rings = 1
	var mat := _unshaded(color, 1.8)
	var body := MeshInstance3D.new()
	body.mesh = mesh
	body.material_override = mat
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(body)
	body.global_position = (from + to) * 0.5
	var dir := (to - from) / dist
	var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	body.look_at(body.global_position + dir, up)
	# The cylinder's axis is +Y: turn it onto the shot direction (-Z after
	# look_at).
	body.rotate_object_local(Vector3.RIGHT, -PI * 0.5)
	var tween := body.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.08)
	tween.tween_callback(body.queue_free)


## A small dust puff at an impact on ground-like surfaces.
static func dust(parent: Node3D, point: Vector3, normal: Vector3,
		color := Color(0.62, 0.58, 0.5)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var n := normal.normalized() if normal.length_squared() > 0.0001 else Vector3.UP
	var particles := GPUParticles3D.new()
	particles.amount = 12
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.fixed_fps = 60
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.direction = n
	proc.spread = 50.0
	proc.initial_velocity_min = 0.5
	proc.initial_velocity_max = 2.0
	proc.gravity = Vector3(0, -2.0, 0)
	proc.scale_min = 0.08
	proc.scale_max = 0.18
	var grad := Gradient.new()
	grad.colors = [Color(color.r, color.g, color.b, 0.7), Color(color.r, color.g, color.b, 0.0)]
	grad.offsets = [0.0, 1.0]
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	proc.color_ramp = gtex
	particles.process_material = proc
	var mesh := SphereMesh.new()
	mesh.radius = 0.04
	mesh.height = 0.08
	mesh.radial_segments = 4
	mesh.rings = 2
	mesh.material = _unshaded(color, 0.6)
	particles.draw_pass_1 = mesh
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(particles)
	particles.global_position = point + n * 0.02
	particles.emitting = true
	var tree := particles.get_tree()
	if tree:
		tree.create_timer(0.6).timeout.connect(particles.queue_free)


## A rising smoke puff for explosions.
static func smoke(parent: Node3D, point: Vector3,
		color := Color(0.45, 0.45, 0.45)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var particles := GPUParticles3D.new()
	particles.amount = 32
	particles.lifetime = 1.6
	particles.one_shot = true
	particles.explosiveness = 0.85
	particles.fixed_fps = 60
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.direction = Vector3.UP
	proc.spread = 30.0
	proc.initial_velocity_min = 0.6
	proc.initial_velocity_max = 2.0
	proc.gravity = Vector3(0, 0.4, 0)
	proc.scale_min = 0.4
	proc.scale_max = 1.0
	proc.damping_min = 0.5
	proc.damping_max = 1.2
	var grad := Gradient.new()
	grad.colors = [Color(color.r, color.g, color.b, 0.75), Color(color.r, color.g, color.b, 0.0)]
	grad.offsets = [0.0, 1.0]
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	proc.color_ramp = gtex
	particles.process_material = proc
	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	mesh.radial_segments = 6
	mesh.rings = 3
	mesh.material = _unshaded(color, 0.4)
	particles.draw_pass_1 = mesh
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(particles)
	particles.global_position = point + Vector3(0, 0.3, 0)
	particles.emitting = true
	var tree := particles.get_tree()
	if tree:
		tree.create_timer(2.0).timeout.connect(particles.queue_free)


## A persistent dark mark where a shot hit a solid surface.
static func impact_mark(parent: Node3D, point: Vector3, normal: Vector3,
		color := Color(0.08, 0.07, 0.06)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var n := normal.normalized() if normal.length_squared() > 0.0001 else Vector3.UP
	var node := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.2, 0.2)
	node.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color.r, color.g, color.b, 0.85)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	node.global_position = point + n * 0.015
	var up := Vector3.UP if absf(n.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	node.look_at(node.global_position - n, up)
	var tree := node.get_tree()
	if tree:
		tree.create_timer(6.0).timeout.connect(func():
			if is_instance_valid(node):
				var t := node.create_tween()
				t.tween_property(mat, "albedo_color:a", 0.0, 1.5)
				t.tween_callback(node.queue_free))


## A brief spark burst at the impact point, flying along the surface normal.
static func spark(parent: Node3D, point: Vector3, normal: Vector3,
		color := Color(1.0, 0.75, 0.3)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var n := normal.normalized() if normal.length_squared() > 0.0001 else Vector3.UP
	var particles := GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 0.25
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.fixed_fps = 60
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.direction = n
	proc.spread = 55.0
	proc.initial_velocity_min = 2.5
	proc.initial_velocity_max = 5.5
	proc.gravity = Vector3(0, -9.8, 0)
	proc.scale_min = 0.04
	proc.scale_max = 0.10
	proc.color = color
	particles.process_material = proc
	var mesh := SphereMesh.new()
	mesh.radius = 0.025
	mesh.height = 0.05
	mesh.radial_segments = 4
	mesh.rings = 2
	mesh.material = _unshaded(color, 2.5)
	particles.draw_pass_1 = mesh
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(particles)
	particles.global_position = point + n * 0.04
	particles.emitting = true
	var tree := particles.get_tree()
	if tree:
		tree.create_timer(0.35).timeout.connect(particles.queue_free)


static func _unshaded(color: Color, energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color.r, color.g, color.b, 1.0)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	return mat
