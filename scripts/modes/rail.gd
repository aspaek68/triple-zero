extends Node3D
## ACTE 2 — Rail shooter.
## La caméra avance sur un rail scripté en trois tronçons (rue, hall, piste) ;
## le joueur ne contrôle que la visée (stick droit ou souris). Abattre les
## menaces, épargner les civils, et toucher les bonus pour le score.

const RAIL_SPEED := 8.0
const PAD_RETICLE_SPEED := 900.0
const SECTIONS := [
	{"name": "RUE", "length": 60.0},
	{"name": "HALL", "length": 70.0},
	{"name": "PISTE", "length": 80.0},
]

var _camera: Camera3D
var _weapon: Weapon
var _rail_len := 210.0
var _travel := 0.0
var _aim := Vector2.ZERO
var _shake := 0.0
var _targets: Array = []
var _bonuses: Array = []
var _barrels: Array = []
var _ended := false
var _intro: Cinematic
var _weather: Weather
var _replay: Replay
var _hud: Hud
var _pause: PauseMenu
var _section := 0
var _combo := 0
var _combo_timer := 0.0


func _ready() -> void:
	EnvBuilder.setup_world(self, -40.0)
	_build_rail()
	_build_camera()
	_spawn_script()
	_build_props()
	_hud = Hud.new()
	_hud.build("ACTE 2 — AÉROPORT", "Objectif : couvrir l'évacuation",
		"Souris viser • Clic/Space tirer • Rouge = menaces • C météo • R replay",
		"Stick D viser • X/RT tirer • Rouge = menaces • Y météo • Back replay")
	add_child(_hud)
	_pause = PauseMenu.new()
	add_child(_pause)
	_aim = get_viewport().get_visible_rect().size * 0.5
	_hud.set_reticle_position(_aim)
	_weather = Director.spawn_weather(self, _camera, _hud)
	_replay = Director.spawn_replay(self)
	for t in _targets:
		var col := Color(0.9, 0.35, 0.3) if t.hostile else Color(0.4, 0.7, 0.95)
		_replay.track(t.node, col, Vector3(0.8, 1.8, 0.8))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_play_intro()


## Short fly-in over the runway before the ride starts.
func _play_intro() -> void:
	_intro = Cinematic.new()
	add_child(_intro)
	_intro.finished.connect(_on_intro_done)
	_intro.play("ACTE 2 — AÉROPORT", "Objectif : couvrir l'évacuation, épargner les civils",
		Vector3(0, 34, 40), Vector3(0, 12, 8), Vector3(0, 2, -40))


func _on_intro_done() -> void:
	Audio.start_music("rail")
	if _hud:
		_hud.set_reticle_visible(true)
		_hud.set_reticle_position(_aim)


func _exit_tree() -> void:
	Audio.stop_music()
	Options.stop_rumble()


# ---------------------------------------------------------------- level build

func _build_rail() -> void:
	# One continuous corridor whose walls/floor colour shifts per section.
	var z := 0.0
	for s in SECTIONS:
		var length: float = s["length"]
		_build_section(z, length, s["name"])
		z -= length


func _build_section(start_z: float, length: float, name: String) -> void:
	var mid := start_z - length / 2.0
	var floor_col := EnvBuilder.MAT_ROAD
	var wall_col := EnvBuilder.MAT_WALL_A
	match name:
		"HALL":
			wall_col = EnvBuilder.MAT_WALL_B
		"PISTE":
			floor_col = EnvBuilder.MAT_METAL
			wall_col = EnvBuilder.MAT_WALL_C
	_slab(Vector3(0, -0.5, mid), Vector3(26, 1, length + 6), floor_col)
	_slab(Vector3(-13, 6, mid), Vector3(2, 12, length + 6), wall_col)
	_slab(Vector3(13, 6, mid), Vector3(2, 12, length + 6), wall_col)
	# Overhead beams + pillars give speed cues and depth.
	for i in range(4):
		var bz := start_z - (length * (i + 0.5) / 4.0)
		_slab(Vector3(0, 11, bz), Vector3(26, 1, 1.2), EnvBuilder.MAT_METAL)
		_slab(Vector3(-10, 3, bz), Vector3(1.5, 6, 1.5), EnvBuilder.MAT_METAL)
		_slab(Vector3(10, 3, bz), Vector3(1.5, 6, 1.5), EnvBuilder.MAT_METAL)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.position = Vector3(0, 2.2, 8)
	_camera.current = true
	_camera.fov = 78.0
	add_child(_camera)
	_weapon = Weapon.make()
	_weapon.position = Vector3(0.18, -0.2, -0.4)
	_weapon.rotation_degrees = Vector3(0, 4, 0)
	_camera.add_child(_weapon)


## Roadside cones and lamps so the corridor reads as a real place.
func _build_props() -> void:
	var cone_mat := EnvBuilder.material(Color(0.85, 0.35, 0.10), 0.6)
	var lamp_mat := EnvBuilder.material(Color(0.35, 0.37, 0.40), 0.4, 0.7)
	var neon := EnvBuilder.material(Color(0.95, 0.25, 0.55), 0.25)
	var steel := EnvBuilder.material(Color(0.5, 0.52, 0.55), 0.4, 0.8)
	var z := -6.0
	var i := 0
	while z > -_rail_len + 6.0:
		var side := -1.0 if i % 2 == 0 else 1.0
		EnvBuilder.prop_native_at(self, "cone", EnvBuilder.cone_fallback(), cone_mat, Vector3(side * 4.2, 0.5, z))
		if i % 4 == 0:
			EnvBuilder.prop_native_at(self, "streetlamp", EnvBuilder.lamp_fallback(), lamp_mat,
					Vector3(side * 8.0, 0.5, z), 0.0)
		if i % 5 == 0:
			EnvBuilder.prop_native_at(self, "neon_sign", EnvBuilder.cone_fallback(), neon,
					Vector3(side * 10.5, 0.5, z - 3.0), 90.0 if side > 0 else -90.0)
		if i % 6 == 3:
			EnvBuilder.prop_native_at(self, "road_sign", EnvBuilder.lamp_fallback(), steel,
					Vector3(side * 9.0, 0.5, z), 0.0)
		if i % 7 == 2:
			EnvBuilder.prop_native_at(self, "planter", EnvBuilder.cone_fallback(), cone_mat,
					Vector3(side * 6.5, 0.5, z))
		z -= 9.0
		i += 1


## Lays out threats, civilians, score bonuses and explosive barrels on the rail.
func _spawn_script() -> void:
	var z := -10.0
	var i := 0
	while z > -_rail_len + 6.0:
		var lane: float = [-6.0, 0.0, 6.0][i % 3]
		var roll := i % 6
		if roll == 3:
			# Bonus: shootable score pickup, never a penalty.
			_bonuses.append(_spawn_bonus(Vector3(lane, 1.8, z)))
		elif roll == 5:
			# Barrel: hitting it wipes out nearby hostiles in one shot.
			_barrels.append(_spawn_barrel(Vector3(lane, 1.2, z)))
		else:
			var hostile := roll != 2
			_targets.append(_spawn_target(Vector3(lane, 1.5, z), hostile))
		z -= 11.0
		i += 1
	# Alternate routes: shoot the glowing switch before a junction to branch off.
	_bonuses.append(_spawn_route_switch(Vector3(-6.0, 2.6, -58.0)))
	_bonuses.append(_spawn_route_switch(Vector3(6.0, 2.6, -126.0)))
	# Secondary objectives: recover dropped gear, then restore the radio relay.
	_bonuses.append(_spawn_secondary(Vector3(-5.0, 1.6, -32.0), "equipment"))
	_bonuses.append(_spawn_secondary(Vector3(5.0, 1.6, -96.0), "equipment"))
	_bonuses.append(_spawn_secondary(Vector3(0.0, 2.4, -168.0), "comm"))


## A shootable secondary objective: blue crate (equipment) or orange relay.
func _spawn_secondary(pos: Vector3, kind: String) -> Dictionary:
	var quad := Sprite3D.new()
	quad.position = pos
	quad.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	quad.pixel_size = 0.012
	var color := Color(0.35, 0.75, 1.0) if kind == "equipment" else Color(1.0, 0.62, 0.2)
	quad.modulate = color
	var tex := GradientTexture2D.new()
	tex.width = 64
	tex.height = 64
	tex.gradient = _solid_gradient(color)
	quad.texture = tex
	add_child(quad)
	return {"node": quad, "alive": true, "kind": kind}


## A green switch that opens an alternate route when shot.
func _spawn_route_switch(pos: Vector3) -> Dictionary:
	var quad := Sprite3D.new()
	quad.position = pos
	quad.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	quad.pixel_size = 0.012
	var color := Color(0.35, 1.0, 0.55)
	quad.modulate = color
	var tex := GradientTexture2D.new()
	tex.width = 64
	tex.height = 64
	tex.gradient = _solid_gradient(color)
	quad.texture = tex
	add_child(quad)
	return {"node": quad, "alive": true, "route": true}


func _spawn_barrel(pos: Vector3) -> Dictionary:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.5
	cyl.height = 1.5
	mesh.mesh = cyl
	mesh.position = pos
	var mat := EnvBuilder.material(EnvBuilder.MAT_ACCENT)
	if ResourceLoader.exists("res://assets/textures/hazard.png"):
		mat.albedo_texture = load("res://assets/textures/hazard.png")
		mat.uv1_scale = Vector3(3, 3, 3)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.5, 0.1)
	mat.emission_energy_multiplier = 0.6
	mesh.material_override = mat
	add_child(mesh)
	return {"node": mesh, "alive": true}


func _spawn_target(pos: Vector3, hostile: bool) -> Dictionary:
	# Humanoid figures so threats and civilians read as people, not quads.
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = PI if hostile else 0.0
	add_child(root)
	var clothes := Color(0.45, 0.22, 0.20) if hostile else Color(0.30, 0.45, 0.55)
	var accent := Color(0.18, 0.18, 0.20) if hostile else Color(0.85, 0.85, 0.88)
	var kind := Character.VARIANT_CIVILIAN
	if hostile:
		kind = Character.VARIANT_RIFLEMAN
		if GameState.ng_plus and randf() < 0.3:
			kind = Character.VARIANT_ELITE
		elif randf() < 0.2:
			kind = Character.VARIANT_SCOUT
		if kind == Character.VARIANT_ELITE:
			clothes = Color(0.18, 0.20, 0.24)
			accent = Color(0.45, 0.12, 0.12)
		elif kind == Character.VARIANT_SCOUT:
			clothes = Color(0.34, 0.40, 0.28)
			accent = Color(0.16, 0.18, 0.16)
	var character := Character.make(clothes, accent, false, kind)
	root.add_child(character)
	if hostile:
		var weapon := Weapon.make()
		character.weapon_mount().add_child(weapon)
	return {
		"node": root,
		"hostile": hostile,
		"alive": true,
		"base_x": pos.x,
		"phase": randf() * TAU,
	}


func _spawn_bonus(pos: Vector3) -> Dictionary:
	var quad := Sprite3D.new()
	quad.position = pos
	quad.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	quad.pixel_size = 0.01
	var color := Color(0.95, 0.85, 0.3)
	quad.modulate = color
	var tex := GradientTexture2D.new()
	tex.width = 48
	tex.height = 48
	tex.gradient = _solid_gradient(color)
	quad.texture = tex
	add_child(quad)
	return {"node": quad, "alive": true}


func _solid_gradient(c: Color) -> Gradient:
	var g := Gradient.new()
	g.colors = [c, c]
	return g


# ---------------------------------------------------------------------- input

func _input(event: InputEvent) -> void:
	if _ended or _intro_locked():
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var screen := get_viewport().get_visible_rect().size
		_aim += event.relative * 3.0 * Options.mouse_sensitivity
		_clamp_aim(screen)
		_sync_reticle()
	elif event.is_action_pressed("weather"):
		Director.cycle_weather(_weather)
	elif event.is_action_pressed("replay") and _replay and _replay.has_footage():
		Director.start_replay(self, _replay, _hud, Callable())
	elif event.is_action_pressed("pause") and _pause:
		# The mode handles pause in `_input`; without marking the event handled
		# the overlay's own `_unhandled_input` would receive the same press and
		# close it in the same frame.
		get_viewport().set_input_as_handled()
		_pause.open()


func _process(delta: float) -> void:
	if _ended or _intro_locked():
		return
	if _replay:
		_replay.sample()
	_travel += RAIL_SPEED * delta
	_camera.position.z = 8.0 - _travel
	# Screen shake (x/y only; z is driven by travel).
	if _shake > 0.001:
		_camera.position.x = randf_range(-1.0, 1.0) * _shake
		_camera.position.y = 2.2 + randf_range(-1.0, 1.0) * _shake
		_shake = lerpf(_shake, 0.0, clampf(delta * 10.0, 0.0, 1.0))
	else:
		_camera.position.x = 0.0
		_camera.position.y = 2.2
		_shake = 0.0
	_update_section()
	_animate_targets(delta)
	_combo_timer = maxf(_combo_timer - delta, 0.0)
	if _combo_timer <= 0.0:
		_combo = 0
	Audio.set_intensity(clampf(_combo / 6.0, 0.0, 1.0))

	if _travel >= _rail_len:
		_finish()
		return

	_pad_aim(delta)
	_clamp_aim(get_viewport().get_visible_rect().size)
	_sync_reticle()
	_update_reticle_hot()
	if Input.is_action_just_pressed("shoot"):
		_shoot()


func _update_section() -> void:
	var acc := 0.0
	for idx in SECTIONS.size():
		acc += SECTIONS[idx]["length"]
		if _travel < acc:
			if idx != _section:
				_section = idx
				if _hud:
					_hud.set_objective("Secteur %s — protégez les civils" % SECTIONS[idx]["name"])
			return


func _animate_targets(delta: float) -> void:
	# Hostiles drift sideways so the player must track them, while walking.
	for t in _targets:
		if not t.alive:
			continue
		var character: Character = t.node.get_child(0) if t.node.get_child_count() > 0 else null
		if t.hostile:
			t.phase += delta * 1.6
			var p: Vector3 = t.node.position
			p.x = t.base_x + sin(t.phase) * 3.0
			t.node.position = p
			if character:
				character.aim(0.0)
				character.animate_walk(delta, 0.7)
		elif character:
			character.animate_walk(delta, 0.25)


func _pad_aim(delta: float) -> void:
	if GameState.last_device != "gamepad":
		return
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look.length_squared() < 0.0001:
		return
	_aim += look * PAD_RETICLE_SPEED * Options.gamepad_sensitivity * delta
	_clamp_aim(get_viewport().get_visible_rect().size)
	_sync_reticle()


func _clamp_aim(screen: Vector2) -> void:
	_aim.x = clampf(_aim.x, 0, screen.x)
	_aim.y = clampf(_aim.y, 0, screen.y)


## Mirrors the screen-space aim point onto the shared HUD reticle.
func _sync_reticle() -> void:
	if _hud:
		_hud.set_reticle_position(_aim)


## Tints the reticle while a valid target sits inside its tolerance.
func _update_reticle_hot() -> void:
	if _hud == null or _camera == null:
		return
	var tolerance: float = 40.0 + Options.aim_tolerance()
	if Progress.has_equipment(GameState.Mode.RAIL, 1):
		tolerance *= 1.4
	var hot := false
	for t in _targets:
		if t.alive and _screen_distance(t.node.global_position, _aim) <= tolerance:
			hot = true
			break
	if not hot:
		for b in _bonuses:
			if b.alive and _screen_distance(b.node.global_position, _aim) <= tolerance:
				hot = true
				break
	if not hot:
		for bar in _barrels:
			if bar.alive and _screen_distance(bar.node.global_position, _aim) <= tolerance:
				hot = true
				break
	_hud.set_reticle_hot(hot)


# -------------------------------------------------------------------- shooting

## True while the intro cinematic still owns the camera.
func _intro_locked() -> bool:
	return _intro != null and is_instance_valid(_intro) and not _intro.is_done()


func _shoot() -> void:
	if _ended or _intro_locked():
		return
	Audio.gunshot()
	if _weapon:
		_weapon.fire()
	Options.rumble(0.4, 0.15, 0.1)
	_add_shake(0.25)
	if _hud:
		_hud.reticle_kick()
	var muzzle_from: Vector3 = _weapon.muzzle().global_position if _weapon else _camera.global_position
	var ray := _aim_ray()
	var screen := _aim
	var tolerance: float = 40.0 + Options.aim_tolerance()
	# Rail equipment: assisted targeting widens the reticle tolerance.
	if Progress.has_equipment(GameState.Mode.RAIL, 1):
		tolerance *= 1.4

	var best: Dictionary = {}
	var best_kind := ""
	var best_dist := 1e9
	for t in _targets:
		if not t.alive:
			continue
		var d := _screen_distance(t.node.global_position, screen)
		if d < best_dist:
			best_dist = d
			best = t
			best_kind = "target"
	for b in _bonuses:
		if not b.alive:
			continue
		var d := _screen_distance(b.node.global_position, screen)
		if d < best_dist:
			best_dist = d
			best = b
			best_kind = "bonus"
	for bar in _barrels:
		if not bar.alive:
			continue
		var d := _screen_distance(bar.node.global_position, screen)
		if d < best_dist:
			best_dist = d
			best = bar
			best_kind = "barrel"

	if best.is_empty() or best_dist > tolerance:
		Vfx.tracer(self, muzzle_from, ray["point"])
		if ray["surface"]:
			Vfx.spark(self, ray["point"], ray["normal"])
			Vfx.dust(self, ray["point"], ray["normal"])
			Vfx.impact_mark(self, ray["point"], ray["normal"])
		Score.register_shot(false)
		_combo = 0
		return

	var aim_point := _target_point(best, best_kind)
	Vfx.tracer(self, muzzle_from, aim_point)
	Vfx.spark(self, aim_point, (muzzle_from - aim_point).normalized())

	if best_kind == "barrel":
		Vfx.smoke(self, best.node.global_position)
		Vfx.impact_mark(self, best.node.global_position, Vector3.UP)
		_detonate_barrel(best)
		return

	if best_kind == "bonus":
		best.alive = false
		best.node.queue_free()
		Score.register_shot(true)
		if best.get("route", false):
			Score.register_alternate_path()
			Score.time_bonus += 500
			if _hud:
				_hud.set_status("ITINÉRAIRE ALTERNATIF — bonus")
		elif best.get("kind", "") == "equipment":
			Score.register_equipment_recovered()
			Score.time_bonus += 300
			if _hud:
				_hud.set_status("MATÉRIEL RÉCUPÉRÉ")
		elif best.get("kind", "") == "comm":
			Score.register_comm_restored()
			Score.time_bonus += 400
			if _hud:
				_hud.set_status("COMMUNICATIONS RÉTABLIES")
		else:
			Score.time_bonus += 250
		if _hud:
			_hud.set_secondary_objectives(Score.civilians_saved, Score.equipment_recovered, Score.comm_restored)
		_combo += 1
		_combo_timer = 2.0
		Audio.hit_confirm()
		if _hud:
			_hud.reticle_hit()
		return

	if best.hostile:
		Score.register_shot(true)
		Audio.hit_confirm()
		if _hud:
			_hud.reticle_hit()
		_combo += 1
		_combo_timer = 2.0
		Score.time_bonus += _combo * 20
		best.alive = false
		_kill_target(best)
		_multiball_extra(screen, tolerance, best)
	else:
		Score.register_shot(false)
		Score.register_civilian(false)
		Audio.civilian_hit()
		Options.rumble(0.8, 0.2, 0.3)
		_combo = 0
		best.alive = false
		_kill_target(best)


## Multiball equipment: a second hostile close to the reticle is hit too.
func _multiball_extra(screen: Vector2, tolerance: float, first: Dictionary) -> void:
	if not Progress.has_equipment(GameState.Mode.RAIL, 0):
		return
	var second: Dictionary = {}
	var best_dist := 1e9
	for t in _targets:
		if not t.alive or not t.hostile or t == first:
			continue
		var d := _screen_distance(t.node.global_position, screen)
		if d < best_dist and d <= tolerance:
			best_dist = d
			second = t
	if second.is_empty():
		return
	second.alive = false
	var chest: Vector3 = second.node.global_position + Vector3(0, 1.4, 0)
	Vfx.spark(self, chest, (_camera.global_position - chest).normalized())
	_kill_target(second)
	Score.time_bonus += 100
	_combo += 1
	Audio.hit_confirm()
	if _hud:
		_hud.reticle_hit()


## Marks a target dead and plays its fall animation before removing it.
func _kill_target(target: Dictionary) -> void:
	var character := _character_of(target)
	if character:
		character.die()
	get_tree().create_timer(1.2).timeout.connect(target.node.queue_free)


func _character_of(target: Dictionary) -> Character:
	for c in target.node.get_children():
		if c is Character:
			return c
	return null


## World point under the screen-space reticle, plus the surface normal there.
func _aim_ray() -> Dictionary:
	var origin := _camera.project_ray_origin(_aim)
	var dir := _camera.project_ray_normal(_aim)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * 160.0)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"point": origin + dir * 160.0, "normal": -dir, "surface": false}
	return {"point": hit["position"], "normal": hit["normal"], "surface": true}


## Where a shot should land on a target: chest height for people, centre for
## pickups and barrels.
func _target_point(target: Dictionary, kind: String) -> Vector3:
	if kind == "target":
		return target.node.global_position + Vector3(0, 1.4, 0)
	return target.node.global_position


func _add_shake(amount: float) -> void:
	_shake = maxf(_shake, amount * Options.screen_shake)


func _screen_distance(world: Vector3, screen: Vector2) -> float:
	if _camera.is_position_behind(world):
		return 1e9
	return _camera.unproject_position(world).distance_to(screen)


## Shooting a barrel explodes it, wiping out hostiles caught in the blast.
func _detonate_barrel(barrel: Dictionary) -> void:
	barrel.alive = false
	var pos: Vector3 = barrel.node.global_position
	barrel.node.queue_free()
	Audio.explosion()
	Options.rumble(0.9, 0.5, 0.35)
	_add_shake(1.0)
	Score.register_shot(true)
	_combo += 1
	_combo_timer = 2.0
	if _hud:
		_hud.reticle_hit()
	var chain := 0
	for t in _targets:
		if t.alive and t.hostile and t.node.global_position.distance_to(pos) < 7.0:
			t.alive = false
			_kill_target(t)
			chain += 1
	Score.time_bonus += 150 + chain * 100
	_spawn_flash(pos)
	Vfx.smoke(self, pos)
	Vfx.impact_mark(self, pos, Vector3.UP)
	if _replay:
		_replay.event("explosion", pos)


func _spawn_flash(pos: Vector3) -> void:
	var flash := OmniLight3D.new()
	flash.position = pos + Vector3(0, 1, 0)
	flash.light_color = Color(1.0, 0.6, 0.2)
	flash.light_energy = 8.0
	flash.omni_range = 8.0
	add_child(flash)
	var tween := flash.create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 0.35)
	tween.tween_callback(flash.queue_free)


func _finish() -> void:
	if _ended:
		return
	_ended = true
	GameState.last_act_success = true
	var challenge := Progress.evaluate()
	if challenge["success"]:
		Progress.mark_act_cleared(GameState.Mode.RAIL)
	for t in _targets:
		if t.alive and not t.hostile:
			Score.register_civilian(true)
	Score.time_bonus += 2500
	Progress.record_run(GameState.Mode.RAIL, Score.total(), Score.rank())
	Audio.stop_music()
	Options.stop_rumble()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _replay and _replay.has_footage() and Options.replay_enabled:
		Director.start_replay(self, _replay, _hud, _on_replay_done)
		return
	_on_replay_done()


func _on_replay_done() -> void:
	GameState.show_results_on_load = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _slab(center: Vector3, size: Vector3, color: Color) -> void:
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
