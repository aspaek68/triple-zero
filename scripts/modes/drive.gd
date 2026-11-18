extends Node3D
## ACTE 3 — Conduite arcade.
## Circuit urbain à virages, checkpoints qui prolongent le chrono, trafic à
## éviter et boost court. Atteindre la dernière porte avant la fin du temps.
## Jouable à la manette (stick gauche, gâchettes) ou au clavier.

const MAX_SPEED := 42.0
const ACCEL := 26.0
const BRAKE := 40.0
const TURN_RATE := 1.9
const BOOST_SPEED := 60.0
const BOOST_DURATION := 2.0
const BOOST_COOLDOWN := 5.0
const CHECKPOINT_RADIUS := 12.0
const TIME_PER_CHECKPOINT := 8.0
const ROAD_WIDTH := 22.0

# Off-road shortcuts between path nodes; driving through one is an alternate route.
const SHORTCUTS := [
	{"at": Vector2(2, -180), "radius": 18.0},
	{"at": Vector2(-2, -430), "radius": 18.0},
]

# Secondary objectives on the road: gear to recover and a radio relay to restore.
const SECONDARIES := [
	{"at": Vector2(0, -19), "kind": "equipment"},
	{"at": Vector2(34, -150), "kind": "equipment"},
	{"at": Vector2(-28, -290), "kind": "comm"},
]

# Track centreline, in (x, z). Turns are handled by rotating the road segments.
const PATH := [
	Vector2(0, 12), Vector2(0, -50), Vector2(34, -110), Vector2(34, -190),
	Vector2(-28, -250), Vector2(-28, -330), Vector2(24, -390), Vector2(24, -450),
	Vector2(-36, -510), Vector2(-36, -590), Vector2(30, -640), Vector2(30, -700),
]

var _car: VehicleBody3D
var _chase: Camera3D
var _shake := 0.0
var _speed := 0.0
var _time := 30.0
var _boost_left := 0.0
var _boost_cd := 0.0
var _engine_beat := 0.0
var _crash_cooldown := 0.0
var _checkpoint := 1
var _checkpoints: Array = []
var _traffic: Array = []
var _chasers: Array = []
var _intro: Cinematic
var _ended := false
var _hud: Hud
var _pause: PauseMenu
var _path: Array = []
var _weather: Weather
var _replay: Replay
var _wheels: Array = []
var _shortcuts_taken := 0
var _secondaries: Array = []


func _ready() -> void:
	EnvBuilder.setup_world(self, -55.0)
	_path = LevelData.active_path(PATH)
	_build_ground()
	_build_track()
	_build_city()
	_build_traffic()
	_build_props()
	_build_shortcuts()
	_build_secondaries()
	_build_car()
	_build_chase()
	_build_chasers()
	_hud = Hud.new()
	_time = 24.0 if GameState.ng_plus else 30.0
	_hud.build("ACTE 3 — VILLE", "Objectif : franchir les portes avant la fin du chrono",
		"ZQSD conduire • Espace frein à main • Maj boost • C météo • R replay",
		"Stick G conduire • B frein à main • RT boost • Y météo • Back replay")
	add_child(_hud)
	_pause = PauseMenu.new()
	add_child(_pause)
	_weather = Director.spawn_weather(self, _car, _hud)
	_replay = Director.spawn_replay(self)
	_replay.track(_car, Color(0.95, 0.75, 0.25), Vector3(2.0, 1.0, 4.2))
	for c in _chasers:
		_replay.track(c["body"], Color(0.9, 0.3, 0.25), Vector3(2.0, 1.0, 4.2))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_play_intro()


func _exit_tree() -> void:
	Audio.stop_music()
	Options.stop_rumble()


# ---------------------------------------------------------------- level build

func _build_ground() -> void:
	_slab(Vector3(0, -0.6, -340), Vector3(560, 1, 820), EnvBuilder.MAT_GROUND)


func _build_track() -> void:
	for i in _path.size() - 1:
		var a: Vector2 = _path[i]
		var b: Vector2 = _path[i + 1]
		_build_segment(a, b)
	# Checkpoint gates at every path node except the start.
	for i in range(1, _path.size()):
		var p: Vector2 = _path[i]
		_checkpoints.append(_build_gate(Vector3(p.x, 0, p.y), i))


func _build_segment(a: Vector2, b: Vector2) -> void:
	var dir := (b - a)
	var length := dir.length()
	var angle := dir.angle()  # radians in the XZ plane
	var mid := (a + b) / 2.0
	var center := Vector3(mid.x, 0.02, mid.y)

	# Road surface.
	var road := _slab(center, Vector3(ROAD_WIDTH, 0.1, length + 4), EnvBuilder.MAT_ROAD)
	road.rotation.y = -angle

	# Side barriers, offset perpendicular to the segment.
	var perp := Vector2(-dir.y, dir.x).normalized() * (ROAD_WIDTH / 2.0 + 1.0)
	for side in [1.0, -1.0]:
		var off: Vector2 = perp * side
		var wall_center := Vector3(mid.x + off.x, 1.4, mid.y + off.y)
		var wall := _slab(wall_center, Vector3(1.2, 2.8, length + 4), EnvBuilder.MAT_WALL_A)
		wall.rotation.y = -angle



## A dense skyline of textured blocks with lit windows, plus neon signs and
## overhead direction signs, so the route reads as a real city street.
func _build_city() -> void:
	var walls := [EnvBuilder.MAT_WALL_A, EnvBuilder.MAT_WALL_B, EnvBuilder.MAT_WALL_C,
		EnvBuilder.MAT_GROUND, EnvBuilder.MAT_METAL]
	var glow := EnvBuilder.material(Color(1.0, 0.9, 0.55), 0.2)
	glow.emission_enabled = true
	glow.emission = Color(1.0, 0.88, 0.5)
	glow.emission_energy_multiplier = 1.3
	var neon := EnvBuilder.material(Color(0.95, 0.25, 0.55), 0.25)
	var steel := EnvBuilder.material(Color(0.5, 0.52, 0.55), 0.4, 0.8)
	for i in _path.size() - 1:
		var a: Vector2 = _path[i]
		var b: Vector2 = _path[i + 1]
		var dir := (b - a).normalized()
		var perp := Vector2(-dir.y, dir.x)
		var angle := -dir.angle()
		var blocks := int((b - a).length() / 34.0) + 1
		for side in [1.0, -1.0]:
			for k in blocks:
				var t := (k + 0.5) / blocks
				var base: Vector2 = a.lerp(b, t) + perp * side * 24.0
				var h := 12.0 + float((i * 7 + k * 5) % 6) * 5.0
				var w := 16.0 + float((i + k) % 3) * 4.0
				_building(Vector3(base.x, 0, base.y), Vector3(w, h, 16.0), angle,
					walls[(i + k) % walls.size()], glow)
				if (i + k) % 3 == 0:
					var face: Vector2 = base - perp * side * 9.0
					EnvBuilder.prop_native_at(self, "neon_sign", EnvBuilder.cone_fallback(), neon,
						Vector3(face.x, 3.0, face.y), angle + (PI / 2.0 if side > 0 else -PI / 2.0))
			if i % 2 == 0:
				var sp: Vector2 = a.lerp(b, 0.5) + perp * side * (ROAD_WIDTH / 2.0 + 3.5)
				EnvBuilder.prop_native_at(self, "road_sign", EnvBuilder.lamp_fallback(), steel,
					Vector3(sp.x, 0, sp.y), angle)


## One city block: a textured box with a few emissive window bands.
func _building(pos: Vector3, size: Vector3, angle: float, color: Color, glow: Material) -> void:
	var body := _slab(pos + Vector3(0, size.y / 2.0, 0), size, color)
	body.rotation.y = angle
	# Distance culling for the city shell (the occlusion box still covers it).
	var shell := body.get_child(0) as MeshInstance3D
	if shell:
		shell.visibility_range_end = 320.0
		shell.visibility_range_end_margin = 24.0
		shell.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	# Occlusion culling: each building occludes what is behind it.
	var occ := OccluderInstance3D.new()
	var box_occ := BoxOccluder3D.new()
	box_occ.size = size
	occ.occluder = box_occ
	body.add_child(occ)
	var bands := clampi(int(size.y / 5.0), 1, 3)
	for f in bands:
		var strip := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(size.x * 0.88, 0.6, size.z + 0.06)
		strip.mesh = box
		strip.position = Vector3(0, size.y / 2.0 - 3.0 - f * 5.0, 0)
		strip.material_override = glow
		strip.visibility_range_end = 320.0
		strip.visibility_range_end_margin = 24.0
		strip.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		body.add_child(strip)


## Lamps and barriers spaced along the track edges.
func _build_props() -> void:
	var lamp_mat := EnvBuilder.material(Color(0.35, 0.37, 0.40), 0.4, 0.7)
	for i in _path.size() - 1:
		var a: Vector2 = _path[i]
		var b: Vector2 = _path[i + 1]
		var dir := (b - a).normalized()
		var perp := Vector2(-dir.y, dir.x)
		for side in [1.0, -1.0]:
			var p: Vector2 = a.lerp(b, 0.5) + perp * side * (ROAD_WIDTH / 2.0 + 2.0)
			EnvBuilder.prop_native_at(self, "streetlamp", EnvBuilder.lamp_fallback(), lamp_mat,
					Vector3(p.x, 0, p.y), -dir.angle() + (0.0 if side > 0 else PI))
			var q: Vector2 = a.lerp(b, 0.22) + perp * side * (ROAD_WIDTH / 2.0 - 0.6)
			EnvBuilder.prop_native_at(self, "barrier", EnvBuilder.cone_fallback(), lamp_mat,
					Vector3(q.x, 0, q.y), -dir.angle())


func _build_gate(pos: Vector3, index: int) -> Dictionary:
	var holder := Node3D.new()
	holder.position = pos
	add_child(holder)
	var color := Color(0.95, 0.85, 0.3) if index < _path.size() - 1 else Color(0.3, 0.9, 0.5)
	for side in [-1.0, 1.0]:
		var post := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.4
		cyl.bottom_radius = 0.4
		cyl.height = 7.0
		post.mesh = cyl
		post.position = Vector3(side * (ROAD_WIDTH / 2.0 - 1.0), 3.5, 0)
		var mat := EnvBuilder.material(color)
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.4
		post.material_override = mat
		holder.add_child(post)
	var top := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(ROAD_WIDTH, 0.6, 0.6)
	top.mesh = box
	top.position = Vector3(0, 6.6, 0)
	var tmat := EnvBuilder.material(color)
	tmat.emission_enabled = true
	tmat.emission = color
	tmat.emission_energy_multiplier = 1.2
	top.material_override = tmat
	holder.add_child(top)
	return {"node": holder, "pos": pos, "passed": false}


func _build_traffic() -> void:
	# Static parked/blocking vehicles as obstacles along the route, plus a few
	# explosive fuel tankers (hazard stripes) that detonate on impact.
	for i in range(1, _path.size() - 1):
		var a: Vector2 = _path[i]
		var b: Vector2 = _path[i + 1]
		var dir := (b - a).normalized()
		var perp := Vector2(-dir.y, dir.x)
		for k in 2:
			var t := 0.35 + k * 0.3
			var base := a.lerp(b, t)
			var lane := perp * (4.0 if k == 0 else -4.0)
			_spawn_obstacle(Vector3(base.x + lane.x, 0.7, base.y + lane.y), -dir.angle(), false)
		# One fuel tanker per segment, near the centre of the road.
		var mid := a.lerp(b, 0.7)
		_spawn_obstacle(Vector3(mid.x, 0.7, mid.y), -dir.angle(), true)


func _spawn_obstacle(pos: Vector3, angle: float, explosive: bool) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation.y = angle
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.9, 1.3, 4.0) if not explosive else Vector3(2.2, 1.6, 5.5)
	mesh.mesh = box
	if explosive:
		var mat := EnvBuilder.material(EnvBuilder.MAT_ACCENT, 0.4)
		if ResourceLoader.exists("res://assets/textures/hazard.png"):
			mat.albedo_texture = load("res://assets/textures/hazard.png")
			mat.uv1_scale = Vector3(3, 3, 3)
		mat.emission_enabled = true
		mat.emission = Color(0.9, 0.5, 0.1)
		mat.emission_energy_multiplier = 0.5
		mesh.material_override = mat
	else:
		mesh.material_override = EnvBuilder.material(Color(0.45, 0.5, 0.6), 0.5)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	body.add_child(shape)
	if explosive:
		body.add_to_group("fuel")
	add_child(body)
	_traffic.append({"body": body, "explosive": explosive})


func _build_car() -> void:
	_car = VehicleBody3D.new()
	_car.position = Vector3(0, 1.0, 12)
	_car.mass = 900.0
	add_child(_car)

	var paint := EnvBuilder.material(EnvBuilder.MAT_ACCENT, 0.3, 0.4)
	var glass := EnvBuilder.material(EnvBuilder.MAT_GLASS, 0.08, 0.0)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color = Color(EnvBuilder.MAT_GLASS.r, EnvBuilder.MAT_GLASS.g, EnvBuilder.MAT_GLASS.b, 0.55)
	var trim := EnvBuilder.material(Color(0.10, 0.10, 0.11), 0.55, 0.3)
	var chrome := EnvBuilder.material(Color(0.75, 0.77, 0.80), 0.2, 0.9)

	# Modelled body keeps its authored materials (paint, glass, chrome, lights);
	# fall back to primitives when the model file is missing.
	var body := EnvBuilder.prop_native("car_body", BoxMesh.new(), paint)
	if body.mesh is BoxMesh:
		_add_car_box(Vector3(2.0, 0.62, 4.2), Vector3(0, -0.05, 0), paint)
		_add_car_box(Vector3(1.86, 0.34, 0.9), Vector3(0, 0.30, -1.6), paint)
		_add_car_box(Vector3(1.9, 0.34, 0.8), Vector3(0, 0.28, 1.7), paint)
		_add_car_box(Vector3(1.62, 0.10, 1.9), Vector3(0, 0.92, -0.1), paint)
		var wind := _add_car_box(Vector3(1.5, 0.5, 0.1), Vector3(0, 0.62, -0.95), glass)
		wind.rotation_degrees = Vector3(-28, 0, 0)
		var rear := _add_car_box(Vector3(1.5, 0.45, 0.1), Vector3(0, 0.62, 0.82), glass)
		rear.rotation_degrees = Vector3(24, 0, 0)
		_add_car_box(Vector3(1.95, 0.22, 0.18), Vector3(0, -0.2, -2.15), trim)
		_add_car_box(Vector3(1.95, 0.22, 0.18), Vector3(0, -0.2, 2.15), trim)
		_add_car_box(Vector3(1.4, 0.2, 0.1), Vector3(0, -0.05, -2.15), chrome)
	_car.add_child(body)
	# Headlight beams stay procedural so they can point and cast light.
	for sx in [-0.7, 0.7]:
		_add_car_light(Vector3(sx, 0.05, -2.14), Color(1.0, 0.95, 0.8), true)
		_add_car_light(Vector3(sx, 0.08, 2.14), Color(1.0, 0.2, 0.15), false)

	var col := CollisionShape3D.new()
	var bshape := BoxShape3D.new()
	bshape.size = Vector3(2.0, 0.9, 4.2)
	col.shape = bshape
	_car.add_child(col)

	var wheel_mesh := EnvBuilder.material(Color(0.08, 0.08, 0.09), 0.9, 0.0)
	var rim_mesh := EnvBuilder.material(Color(0.72, 0.74, 0.78), 0.25, 0.9)
	for p in [Vector3(-0.95, 0, 1.4), Vector3(0.95, 0, 1.4), Vector3(-0.95, 0, -1.4), Vector3(0.95, 0, -1.4)]:
		var wheel := VehicleWheel3D.new()
		wheel.position = p
		wheel.wheel_radius = 0.4
		wheel.wheel_rest_length = 0.15
		wheel.use_as_traction = p.z < 0.0
		wheel.use_as_steering = p.z > 0.0
		_car.add_child(wheel)
		_wheels.append(wheel)
		var tyre := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.4
		cyl.bottom_radius = 0.4
		cyl.height = 0.28
		cyl.radial_segments = 20
		tyre.mesh = cyl
		tyre.rotation_degrees = Vector3(0, 0, 90)
		tyre.position = p + Vector3(signf(p.x) * 0.02, 0, 0)
		tyre.material_override = wheel_mesh
		_car.add_child(tyre)
		var rim := MeshInstance3D.new()
		var rcyl := CylinderMesh.new()
		rcyl.top_radius = 0.22
		rcyl.bottom_radius = 0.22
		rcyl.height = 0.30
		rcyl.radial_segments = 12
		rim.mesh = rcyl
		rim.rotation_degrees = Vector3(0, 0, 90)
		rim.position = tyre.position
		rim.material_override = rim_mesh
		_car.add_child(rim)


func _add_car_box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.position = pos
	mi.material_override = mat
	_car.add_child(mi)
	return mi


func _add_car_light(pos: Vector3, color: Color, front: bool) -> void:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.34, 0.16, 0.08)
	mi.mesh = box
	mi.position = pos
	var mat := EnvBuilder.material(color, 0.2)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.5 if front else 1.5
	mi.material_override = mat
	_car.add_child(mi)
	if front:
		var beam := SpotLight3D.new()
		beam.position = pos + Vector3(0, 0, -0.1)
		beam.rotation_degrees = Vector3(-8, 0, 0)
		beam.light_color = color
		beam.light_energy = 2.0
		beam.spot_range = 26.0
		beam.spot_angle = 34.0
		_car.add_child(beam)


func _build_chase() -> void:
	_chase = Camera3D.new()
	_chase.current = true
	_chase.fov = 72.0
	add_child(_chase)


# --------------------------------------------------------------------- driving

func _physics_process(delta: float) -> void:
	if _ended or _intro_locked():
		return
	if _replay:
		_replay.sample()
	_apply_grip()
	_check_shortcuts()
	_check_secondaries()
	_time -= delta
	if _time <= 0.0:
		_finish(false)
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steer := Input.get_action_strength("move_left") - Input.get_action_strength("move_right")

	if _boost_left > 0.0:
		_boost_left -= delta
	if _boost_cd > 0.0:
		_boost_cd -= delta
	if Input.is_action_just_pressed("boost") and _boost_cd <= 0.0 and _boost_left <= 0.0:
		var duration := BOOST_DURATION * (1.4 if Progress.has_equipment(1, 1) else 1.0)
		_boost_left = duration
		_boost_cd = BOOST_COOLDOWN
		Audio.boost_whoosh()
		Options.rumble(0.6, 0.3, 0.4)

	var top := BOOST_SPEED if _boost_left > 0.0 else MAX_SPEED
	if throttle > 0.0:
		_car.engine_force = throttle * ACCEL * _car.mass
	elif throttle < 0.0:
		_car.engine_force = throttle * ACCEL * _car.mass * 0.5
	else:
		_car.engine_force = 0.0
	_car.brake = BRAKE * _car.mass if Input.is_action_pressed("handbrake") else 0.0
	_car.steering = steer * TURN_RATE * (1.0 - clampf(absf(_car.linear_velocity.length()) / top, 0.0, 0.7))

	_speed = _car.linear_velocity.length()

	_engine_beat -= delta
	if _engine_beat <= 0.0 and _speed > 1.0:
		_engine_beat = clampf(0.28 - _speed * 0.004, 0.08, 0.3)
		Audio.engine_loop_note()

	_check_checkpoints()
	_check_collisions(delta)
	_update_chase(delta)
	_update_hud()
	Audio.set_intensity(clampf(_speed / MAX_SPEED, 0.0, 1.0))


## Crashing into scenery bleeds speed; hitting a fuel tanker detonates it.
func _check_collisions(delta: float) -> void:
	var speed := _car.linear_velocity.length()
	if speed < 6.0:
		_crash_cooldown = maxf(_crash_cooldown - delta, 0.0)
		return
	for i in _car.get_slide_collision_count():
		var collision: KinematicCollision3D = _car.get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider is StaticBody3D and collider.is_in_group("fuel"):
			_detonate_tanker(collider)
			continue
		if _crash_cooldown <= 0.0:
			_crash_cooldown = 0.6
			Audio.crash()
			Options.rumble(0.7, 0.4, 0.2)
			_add_shake(0.6)
			# A hard impact scrubs off a chunk of speed.
			_car.linear_velocity *= 0.55
		_crash_cooldown = maxf(_crash_cooldown - delta, 0.0)


func _detonate_tanker(body: Node3D) -> void:
	if not is_instance_valid(body) or body.is_queued_for_deletion():
		return
	var pos := body.global_position
	body.remove_from_group("fuel")
	Audio.explosion()
	Options.rumble(1.0, 0.6, 0.5)
	_add_shake(1.0)
	_spawn_flash(pos)
	Vfx.smoke(self, pos)
	if _replay:
		_replay.event("explosion", pos)
	body.queue_free()
	# The blast shoves the car sideways for a moment.
	_car.linear_velocity += (pos - _car.global_position).normalized() * 8.0


func _add_shake(amount: float) -> void:
	_shake = maxf(_shake, amount * Options.screen_shake)


func _spawn_flash(pos: Vector3) -> void:
	var flash := OmniLight3D.new()
	flash.position = pos + Vector3(0, 1.5, 0)
	flash.light_color = Color(1.0, 0.6, 0.2)
	flash.light_energy = 10.0
	flash.omni_range = 14.0
	add_child(flash)
	var tween := flash.create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 0.4)
	tween.tween_callback(flash.queue_free)


func _check_checkpoints() -> void:
	if _checkpoint >= _checkpoints.size():
		return
	var gate: Dictionary = _checkpoints[_checkpoint]
	if _car.global_position.distance_to(gate.pos) < CHECKPOINT_RADIUS:
		gate.passed = true
		_time += TIME_PER_CHECKPOINT
		Audio.hit_confirm()
		Options.rumble(0.2, 0.1, 0.15)
		_checkpoint += 1
		if _checkpoint >= _checkpoints.size():
			_finish(true)


## Short fly-in over the city before the chase starts.
func _play_intro() -> void:
	_intro = Cinematic.new()
	add_child(_intro)
	_intro.finished.connect(_on_intro_done)
	_intro.play("ACTE 3 — VILLE", "Objectif : franchir les portes avant la fin du chrono",
		Vector3(0, 60, 70), Vector3(0, 18, 20), Vector3(0, 0, -60))


func _on_intro_done() -> void:
	Audio.start_music("drive")


## True while the intro cinematic still owns the camera.
func _intro_locked() -> bool:
	return _intro != null and is_instance_valid(_intro) and not _intro.is_done()


# ------------------------------------------------------------------ chasers

## Rival cars that hunt the player along the track. Two spawn behind and one
## ahead; they steer toward the player and ram, so a clean run means shaking
## them off rather than trading paint.
func _build_chasers() -> void:
	var paint := EnvBuilder.material(Color(0.12, 0.12, 0.14), 0.3, 0.5)
	for i in 3:
		var z := 12.0 + 14.0 * (i + 1)
		var body := VehicleBody3D.new()
		body.position = Vector3(6.0 * (1 if i % 2 == 0 else -1), 1.0, z)
		body.mass = 850.0
		add_child(body)
		var model := EnvBuilder.prop_native("car_body", BoxMesh.new(), paint)
		body.add_child(model)
		var col := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(2.0, 0.9, 4.2)
		col.shape = bs
		body.add_child(col)
		for p in [Vector3(-0.95, 0, 1.4), Vector3(0.95, 0, 1.4), Vector3(-0.95, 0, -1.4), Vector3(0.95, 0, -1.4)]:
			var wheel := VehicleWheel3D.new()
			wheel.position = p
			wheel.wheel_radius = 0.4
			wheel.wheel_rest_length = 0.15
			wheel.use_as_traction = p.z < 0.0
			wheel.use_as_steering = p.z > 0.0
			body.add_child(wheel)
		_chasers.append({"body": body, "wrecked": false, "cooldown": 0.0})


func _update_chasers(delta: float) -> void:
	for c in _chasers:
		var body: VehicleBody3D = c["body"]
		if c["wrecked"] or not is_instance_valid(body):
			continue
		c["cooldown"] = maxf(c["cooldown"] - delta, 0.0)
		# Steer toward the player and keep the throttle pinned.
		var to_player := _car.global_position - body.global_position
		var flat := Vector3(to_player.x, 0, to_player.z)
		var dist := flat.length()
		var forward := -body.global_transform.basis.z
		var angle := forward.signed_angle_to(flat.normalized(), Vector3.UP)
		body.steering = clampf(angle * 1.4, -0.6, 0.6)
		body.engine_force = ACCEL * body.mass * 0.7
		# Ramming the player costs the player speed and rattles the camera.
		if dist < 3.4 and c["cooldown"] <= 0.0:
			c["cooldown"] = 1.2
			_car.linear_velocity *= 0.8
			Audio.crash()
			Options.rumble(0.6, 0.3, 0.3)
		# A boost is enough to wreck a chaser on contact.
		if dist < 3.0 and _boost_left > 0.0:
			_wreck_chaser(c)


## Explodes a chaser and clears it from the hunt.
func _wreck_chaser(c: Dictionary) -> void:
	if c["wrecked"]:
		return
	c["wrecked"] = true
	var body: VehicleBody3D = c["body"]
	var pos := body.global_position
	Audio.explosion()
	Options.rumble(1.0, 0.6, 0.5)
	_add_shake(1.0)
	_spawn_flash(pos)
	Vfx.smoke(self, pos)
	if _replay:
		_replay.event("explosion", pos)
	body.queue_free()
	Score.register_kill()


func _alive_chasers() -> int:
	var n := 0
	for c in _chasers:
		if not c["wrecked"]:
			n += 1
	return n


func _unhandled_input(event: InputEvent) -> void:
	if _ended or _intro_locked():
		return
	if event.is_action_pressed("pause") and _pause:
		get_viewport().set_input_as_handled()
		_pause.open()
	elif event.is_action_pressed("weather"):
		Director.cycle_weather(_weather)
	elif event.is_action_pressed("replay") and _replay and _replay.has_footage():
		Director.start_replay(self, _replay, _hud, Callable())


## Glowing rings mark the off-road shortcuts; driving through one is rewarded.
func _build_shortcuts() -> void:
	for s in SHORTCUTS:
		var at: Vector2 = s["at"]
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 6.0
		torus.outer_radius = 7.0
		ring.mesh = torus
		ring.position = Vector3(at.x, 0.4, at.y)
		var mat := EnvBuilder.material(Color(0.35, 1.0, 0.55))
		mat.emission_enabled = true
		mat.emission = Color(0.35, 1.0, 0.55)
		mat.emission_energy_multiplier = 1.4
		ring.material_override = mat
		add_child(ring)


func _check_shortcuts() -> void:
	var p := Vector2(_car.global_position.x, _car.global_position.z)
	for i in SHORTCUTS.size():
		if i < _shortcuts_taken:
			continue
		var s: Dictionary = SHORTCUTS[i]
		if p.distance_to(s["at"]) < s["radius"]:
			_shortcuts_taken = i + 1
			Score.register_alternate_path()
			Audio.hit_confirm()
			if _hud:
				_hud.set_status("RACCOURCI — itinéraire alternatif")


## Glowing pickups on the road: gear crates and a radio relay. Drive through one
## to secure it; they never block the racing line.
func _build_secondaries() -> void:
	for s in SECONDARIES:
		var at: Vector2 = s["at"]
		var node: Node3D = Node3D.new()
		node.position = Vector3(at.x, 0.0, at.y)
		if s["kind"] == "equipment":
			var crate := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(1.4, 1.4, 1.4)
			crate.mesh = box
			crate.position.y = 1.2
			var mat := EnvBuilder.material(Color(0.35, 0.75, 1.0))
			mat.emission_enabled = true
			mat.emission = Color(0.35, 0.75, 1.0)
			mat.emission_energy_multiplier = 1.1
			crate.material_override = mat
			node.add_child(crate)
		else:
			var mast := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.18
			cyl.bottom_radius = 0.3
			cyl.height = 4.0
			mast.mesh = cyl
			mast.position.y = 2.2
			var mat := EnvBuilder.material(Color(1.0, 0.62, 0.2))
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.62, 0.2)
			mat.emission_energy_multiplier = 1.2
			mast.material_override = mat
			node.add_child(mast)
		add_child(node)
		_secondaries.append({"node": node, "kind": s["kind"], "taken": false})


func _check_secondaries() -> void:
	var p := Vector2(_car.global_position.x, _car.global_position.z)
	for s in _secondaries:
		if s["taken"]:
			continue
		var node: Node3D = s["node"]
		node.rotation.y += 0.03
		var at := Vector2(node.global_position.x, node.global_position.z)
		if p.distance_to(at) < 5.0:
			s["taken"] = true
			node.visible = false
			if s["kind"] == "equipment":
				Score.register_equipment_recovered()
				Score.time_bonus += 300
				if _hud:
					_hud.set_status("MATÉRIEL RÉCUPÉRÉ")
			else:
				Score.register_comm_restored()
				Score.time_bonus += 400
				if _hud:
					_hud.set_status("COMMUNICATIONS RÉTABLIES")
			if _hud:
				_hud.set_secondary_objectives(Score.civilians_saved, Score.equipment_recovered, Score.comm_restored)
			Audio.hit_confirm()


## Wet roads cut the tyres' friction, so the storm makes the car slide.
func _apply_grip() -> void:
	var wet: float = _weather.wetness() if _weather else 0.0
	var friction := lerpf(1.6, 0.95, clampf(wet, 0.0, 1.0))
	# Drive equipment: sport tyres hold the road a little better.
	if Progress.has_equipment(1, 0):
		friction *= 1.15
	for w in _wheels:
		(w as VehicleWheel3D).wheel_friction_slip = friction


func _update_chase(delta: float) -> void:
	var target := _car.global_transform
	var desired := target.origin - target.basis.z * 7.5 + Vector3(0, 3.2, 0)
	_chase.global_position = _chase.global_position.lerp(desired, delta * 4.0)
	_chase.look_at(_car.global_position + Vector3(0, 1.0, 0), Vector3.UP)
	if _shake > 0.001:
		_chase.global_position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake
		_shake = lerpf(_shake, 0.0, clampf(delta * 10.0, 0.0, 1.0))
	else:
		_shake = 0.0


func _update_hud() -> void:
	if _hud:
		var boost := Loc.t("PRÊT") if _boost_cd <= 0.0 else "%.1fs" % maxf(_boost_cd, 0.0)
		_hud.set_status("Vitesse %3d km/h • Porte %d/%d • Temps %4.1fs • Boost %s • Poursuivants %d" % [
			int(_speed * 3.6), _checkpoint, _checkpoints.size(), maxf(_time, 0.0), boost, _alive_chasers()
		])


func _finish(success: bool) -> void:
	if _ended:
		return
	_ended = true
	GameState.last_act_success = success
	_car.engine_force = 0.0
	# A failed run (out of time) cannot satisfy the armed challenge: report the
	# real reason instead of a verdict that contradicts "ACTE ÉCHOUÉ".
	if not success:
		Progress.fail("temps écoulé")
	var challenge := Progress.evaluate()
	if success and challenge["success"]:
		Progress.mark_act_cleared(GameState.Mode.DRIVE)
	if success:
		Score.time_bonus += int(maxf(_time, 0.0) * 100.0)
		Progress.record_run(GameState.Mode.DRIVE, Score.total(), Score.rank())
	Audio.stop_music()
	Options.stop_rumble()
	if _replay and _replay.has_footage() and Options.replay_enabled:
		Director.start_replay(self, _replay, _hud, _on_replay_done)
		return
	_on_replay_done()


func _on_replay_done() -> void:
	GameState.show_results_on_load = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _slab(center: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = EnvBuilder.material(color)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)
	add_child(body)
	return body
