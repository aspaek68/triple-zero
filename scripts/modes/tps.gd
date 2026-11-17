extends Node3D
## ACTE 1 — Action/infiltration à la troisième personne.
## Trois zones reliées, vagues d'ennemis (soldats + lourds), caisses de
## couverture, trousses de soin, itinéraire alterné en hauteur, puis
## extraction au point d'évacuation une fois la zone sécurisée.

const WALK := 5.0
const SPRINT := 8.5
const GRAVITY := 24.0
const JUMP := 6.5
const PAD_LOOK_SPEED := 2.4
const FIRE_COOLDOWN := 0.16

var _player: CharacterBody3D
var _yaw := 0.0
var _pitch := -0.18
var _arm: SpringArm3D
var _hud: Hud
var _intro: Cinematic
var _weather: Weather
var _replay: Replay
var _camera: Camera3D
var _character: Character
var _weapon: Weapon
var _enemies: Array = []
var _pickups: Array = []
var _waves: Array = []
var _wave_index := 0
var _zone := 1
var _extraction := Vector3.ZERO
var _extraction_open := false
var _in_cover := false
var _alt_taken := false
var _alt_taken_2 := false
var _civilians: Array = []
var _event_hangar := false
var _event_rooftop := false
var _event_alarm := false
var _event_power_outage := false
var _event_blocked_elevator := false
var _event_smoke := false
var _reinforcements_pending := 0
var _ended := false
var _health := 100
var _fire_cooldown := 0.0
var _invuln := 0.0
var _damage_flash := 0.0
var _reticle_scan := 0.0
var _shake := 0.0
# Equipment modifiers
var _player_speed_multiplier := 1.0
var _enemy_detection_reduction := 0.0


func _ready() -> void:
	EnvBuilder.setup_world(self)
	_build_zone_one()
	_build_zone_two()
	_build_zone_three()
	_build_extraction()
	_build_props()
	_build_civilians()
	_build_player(Vector3(0, 1.2, 34))
	# Equipment: changes how the act is approached, never raw power.
	if Progress.has_equipment(0, 0):
		_player_speed_multiplier = 1.2
	if Progress.has_equipment(0, 1):
		_enemy_detection_reduction = 0.3
	_hud = Hud.new()
	_hud.build("ACTE 1 — TOUR", "Objectif : sécuriser les trois zones",
		"ZQSD bouger • Souris viser • Clic/Space tirer • Ctrl couvert • C météo • R replay",
		"Stick G bouger • Stick D viser • X/LT tirer • B couvert • Y météo • Back replay")
	add_child(_hud)
	_weather = Director.spawn_weather(self, _player, _hud)
	_replay = Director.spawn_replay(self)
	_replay.track(_player, Color(0.4, 0.9, 0.5), Vector3(0.9, 1.8, 0.9))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_play_intro()
	_start_wave()


## Short fly-in over the tower before control is handed over.
func _play_intro() -> void:
	_intro = Cinematic.new()
	add_child(_intro)
	_intro.finished.connect(_on_intro_done)
	_intro.play("ACTE 1 — TOUR", "Objectif : sécuriser les trois zones, puis rejoindre l'extraction",
		Vector3(0, 46, 78), Vector3(0, 14, 30), Vector3(0, 2, -20))


func _on_intro_done() -> void:
	Audio.start_music("tps")
	if _hud:
		_hud.set_reticle_center()
		_hud.set_reticle_visible(true)


func _exit_tree() -> void:
	Audio.stop_music()
	Options.stop_rumble()


# ---------------------------------------------------------------- level build

func _build_zone_one() -> void:
	# Entrance plaza: wide cover field, first contact.
	_floor(Vector3(0, -0.5, 24), Vector3(80, 1, 60))
	_perimeter(Vector2(0, 24), Vector2(80, 60))
	for c in [Vector3(-12, 0, 18), Vector3(12, 0, 18), Vector3(-4, 0, 8), Vector3(16, 0, 4), Vector3(-18, 0, 6)]:
		_crate(c, Vector3(4, 1.4, 2.2))
	_slab(Vector3(0, 5, 12), Vector3(6, 0.4, 12), EnvBuilder.MAT_WALL_C)  # arch over the road
	# Explosive barrels and breakable crates: cover that also blows up.
	for b in [Vector3(-8, 0, 14), Vector3(9, 0, 10), Vector3(2, 0, 0)]:
		add_child(Destructible.make(Destructible.Kind.BARREL, b))
	add_child(Destructible.make(Destructible.Kind.CRATE, Vector3(14, 0, 16)))
	_waves.append({
		"zone": 1,
		"spawns": [Vector3(0, 1, -2), Vector3(-16, 1, -4), Vector3(16, 1, -6)],
		"heavies": [],
	})


func _build_zone_two() -> void:
	# Hangar corridor: tighter, with a heavy guarding the far end.
	_floor(Vector3(0, -0.5, -24), Vector3(46, 1, 50))
	_slab(Vector3(-22, 5, -24), Vector3(2, 12, 50), EnvBuilder.MAT_WALL_A)
	_slab(Vector3(22, 5, -24), Vector3(2, 12, 50), EnvBuilder.MAT_WALL_A)
	for z in [-10.0, -20.0, -30.0, -40.0]:
		_crate(Vector3(-10, 0, z), Vector3(5, 1.6, 2.4))
		_crate(Vector3(10, 0, z), Vector3(5, 1.6, 2.4))
	# Raised catwalk along the left wall: alternate route, reachable by a ramp.
	_slab(Vector3(-18, 4.0, -24), Vector3(6, 0.5, 46), EnvBuilder.MAT_WALL_C)
	_ramp(Vector3(-18, 1.6, 4), Vector3(6, 0.4, 10))
	# Second route: service catwalk along the right wall, its own ramp.
	_slab(Vector3(18, 4.0, -24), Vector3(6, 0.5, 46), EnvBuilder.MAT_METAL)
	_ramp(Vector3(18, 1.6, 4), Vector3(6, 0.4, 10))
	# Barrels tucked beside the cover: shooting them clears a whole cluster.
	for b in [Vector3(-13, 0, -12), Vector3(-13.8, 0, -13), Vector3(13, 0, -24), Vector3(12, 0, -36)]:
		add_child(Destructible.make(Destructible.Kind.BARREL, b))
	_waves.append({
		"zone": 2,
		"spawns": [Vector3(0, 1, -14), Vector3(-6, 1, -30), Vector3(8, 1, -34)],
		"heavies": [Vector3(0, 1, -42)],
	})


func _build_zone_three() -> void:
	# Rooftop approach: open, elevated platforms, last stand.
	_floor(Vector3(0, 4.0, -62), Vector3(50, 1, 36))
	_slab(Vector3(0, 2.0, -62), Vector3(50, 4, 36), EnvBuilder.MAT_GROUND)  # support block
	_slab(Vector3(0, 12, -78), Vector3(50, 10, 2), EnvBuilder.MAT_WALL_A)
	_slab(Vector3(-25, 12, -62), Vector3(2, 10, 36), EnvBuilder.MAT_WALL_A)
	_slab(Vector3(25, 12, -62), Vector3(2, 10, 36), EnvBuilder.MAT_WALL_A)
	for c in [Vector3(-10, 5, -56), Vector3(10, 5, -56), Vector3(0, 5, -70)]:
		_crate(c, Vector3(5, 1.6, 2.4))
	for b in [Vector3(-4, 4, -66), Vector3(-5, 4, -67), Vector3(6, 4, -58)]:
		add_child(Destructible.make(Destructible.Kind.BARREL, b))
	_waves.append({
		"zone": 3,
		"spawns": [Vector3(-8, 5, -72), Vector3(8, 5, -72), Vector3(0, 5, -76)],
		"heavies": [Vector3(-14, 5, -60)],
	})


func _build_extraction() -> void:
	_extraction = Vector3(0, 4.5, -78)
	_slab(Vector3(0, 4.6, -78), Vector3(10, 0.3, 8), EnvBuilder.MAT_GLASS)
	# A visible beacon so the player knows where to fall back to.
	var beacon := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.3
	cyl.bottom_radius = 0.3
	cyl.height = 8.0
	beacon.mesh = cyl
	beacon.position = _extraction + Vector3(0, 4, 0)
	var mat := EnvBuilder.material(Color(0.3, 0.9, 0.5))
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.9, 0.5)
	mat.emission_energy_multiplier = 1.6
	beacon.material_override = mat
	add_child(beacon)


func _floor(center: Vector3, size: Vector3) -> void:
	_slab(center, size, EnvBuilder.MAT_ROAD)


func _perimeter(center: Vector2, size: Vector2) -> void:
	_slab(Vector3(center.x, 6, center.y - size.y / 2.0), Vector3(size.x, 12, 2), EnvBuilder.MAT_WALL_A)
	_slab(Vector3(center.x, 6, center.y + size.y / 2.0), Vector3(size.x, 12, 2), EnvBuilder.MAT_WALL_A)
	_slab(Vector3(center.x - size.x / 2.0, 6, center.y), Vector3(2, 12, size.y), EnvBuilder.MAT_WALL_A)
	_slab(Vector3(center.x + size.x / 2.0, 6, center.y), Vector3(2, 12, size.y), EnvBuilder.MAT_WALL_A)


func _crate(center: Vector3, size: Vector3) -> void:
	_slab(center + Vector3(0, size.y / 2.0, 0), size, EnvBuilder.MAT_METAL)


func _ramp(center: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = center
	body.rotation_degrees = Vector3(-18, 0, 0)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = EnvBuilder.material(EnvBuilder.MAT_METAL)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)
	add_child(body)


## Street furniture: lamps along the route and cones marking hazards. These are
## generated glTF props when assets/models/ is present, primitives otherwise.
func _build_props() -> void:
	var lamp_mat := EnvBuilder.material(Color(0.35, 0.37, 0.40), 0.4, 0.7)
	var cone_mat := EnvBuilder.material(Color(0.85, 0.35, 0.10), 0.6)
	for z in [26.0, 14.0, 2.0, -12.0, -26.0, -40.0]:
		for x in [-30.0, 30.0]:
			EnvBuilder.prop_native_at(self, "streetlamp", EnvBuilder.lamp_fallback(), lamp_mat, Vector3(x, 0, z), 90.0 if x > 0 else -90.0)
	for c in [Vector3(-6, 0, 20), Vector3(6, 0, 20), Vector3(-2, 0, 4), Vector3(20, 0, -30)]:
		EnvBuilder.prop_native_at(self, "cone", EnvBuilder.cone_fallback(), cone_mat, c)
	# Street furniture that doubles as cover.
	for d in [Vector3(-22, 0, 12), Vector3(24, 0, -18)]:
		EnvBuilder.prop_native_at(self, "dumpster", EnvBuilder.cone_fallback(), cone_mat, d, 90.0)
	for p in [Vector3(-15, 0, 28), Vector3(18, 0, 24), Vector3(-20, 0, -34)]:
		EnvBuilder.prop_native_at(self, "planter", EnvBuilder.cone_fallback(), cone_mat, p)
	for b in [Vector3(-26, 0, -6), Vector3(26, 0, -2)]:
		EnvBuilder.prop_native_at(self, "barrier", EnvBuilder.cone_fallback(), cone_mat, b, 90.0)
	# Shop neon on the plaza walls and direction signs on the plaza approach.
	var neon := EnvBuilder.material(Color(0.95, 0.25, 0.55), 0.25)
	var steel := EnvBuilder.material(Color(0.5, 0.52, 0.55), 0.4, 0.8)
	for n in [Vector3(-38, 6.0, 30), Vector3(38, 6.0, 14), Vector3(-38, 6.0, -8)]:
		EnvBuilder.prop_native_at(self, "neon_sign", EnvBuilder.cone_fallback(), neon, n, 90.0 if n.x > 0 else -90.0)
	EnvBuilder.prop_native_at(self, "road_sign", EnvBuilder.lamp_fallback(), steel, Vector3(0, 0, 40))
	for p in [Vector3(-28, 0, -40), Vector3(28, 0, -40)]:
		EnvBuilder.prop_native_at(self, "dumpster", EnvBuilder.cone_fallback(), cone_mat, p, 0.0)
	for p in [Vector3(-30, 0, 20), Vector3(30, 0, 26)]:
		EnvBuilder.prop_native_at(self, "planter", EnvBuilder.cone_fallback(), cone_mat, p)


## Secondary objective: civilians hiding in the three zones. Reach them before
## the zone is cleared to save them; each one feeds the score.
func _build_civilians() -> void:
	var spots := [
		Vector3(-24, 0, 20),
		Vector3(14, 0, -30),
		Vector3(16, 4.5, -64),
	]
	for pos in spots:
		var root := Node3D.new()
		root.position = pos
		var character := Character.make(Color(0.30, 0.45, 0.55), Color(0.85, 0.85, 0.88), false, "civilian")
		root.add_child(character)
		add_child(root)
		_civilians.append({"node": root, "character": character, "saved": false, "lost": false})


func _update_civilians(delta: float) -> void:
	for c in _civilians:
		if c["saved"] or c["lost"]:
			continue
		var character: Character = c["character"]
		if character:
			character.animate_walk(delta, 0.0)
		if c["node"].global_position.distance_to(_player.global_position) < 3.0:
			c["saved"] = true
			Score.register_civilian(true)
			Audio.hit_confirm()
			if _hud:
				_hud.set_status("CIVIL SECOURU — %d/3" % _saved_civilians())


func _saved_civilians() -> int:
	var n := 0
	for c in _civilians:
		if c["saved"]:
			n += 1
	return n


## Leaving a zone before reaching its civilian means losing them.
func _lose_unsaved_civilians(zone: int) -> void:
	for c in _civilians:
		if c["saved"] or c["lost"]:
			continue
		var z: float = c["node"].global_position.z
		var in_zone := false
		match zone:
			1:
				in_zone = z > 4.0
			2:
				in_zone = z <= 4.0 and z > -50.0
			3:
				in_zone = z <= -50.0
		if in_zone:
			c["lost"] = true
			Score.register_civilian(false)
			if _hud:
				_hud.set_status("CIVIL PERDU — la zone a été abandonnée")


# -------------------------------------------------------------------- enemies

func _start_wave() -> void:
	if _wave_index >= _waves.size():
		_open_extraction()
		return
	var wave: Dictionary = _waves[_wave_index]
	_zone = wave["zone"]
	for pos in wave["spawns"]:
		_add_enemy(Enemy.make(pos, false))
	for pos in wave["heavies"]:
		_add_enemy(Enemy.make(pos, true))
	if _hud:
		_hud.set_objective("Zone %d — %d hostiles" % [_zone, _enemies.size()])


func _add_enemy(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)
	_enemies.append(enemy)
	if _replay:
		_replay.track(enemy, Color(0.9, 0.35, 0.3), Vector3(0.8, 1.8, 0.8))


func _on_enemy_died(enemy: Enemy) -> void:
	if _enemies.has(enemy):
		_enemies.erase(enemy)
		_maybe_drop_pickup(enemy)
		# Secondary objective: equipment recovery from enemies
		Score.register_equipment_recovered()
	if _replay:
		_replay.event("explosion", enemy.global_position)
	if _enemies.is_empty():
		_advance_wave()


# --------------------------------------------------------------------- player

func _build_player(pos: Vector3) -> void:
	_player = CharacterBody3D.new()
	_player.position = pos
	_player.add_to_group("player")
	var shape := CollisionShape3D.new()
	var cs := CapsuleShape3D.new()
	cs.radius = 0.4
	cs.height = 1.8
	shape.shape = cs
	shape.position.y = 0.9
	_player.add_child(shape)

	# Visible body under the camera; the camera sits at eye height.
	_character = Character.make(Color(0.22, 0.30, 0.24), Color(0.14, 0.16, 0.18))
	_player.add_child(_character)

	_arm = SpringArm3D.new()
	_arm.spring_length = 4.5
	_arm.position = Vector3(0, 1.5, 0)
	_arm.rotation_degrees = Vector3(_pitch * 57.3, 0, 0)
	_player.add_child(_arm)

	var cam := Camera3D.new()
	cam.fov = 70.0
	cam.current = true
	_arm.add_child(cam)
	_camera = cam

	# First-person weapon, parented to the camera so it stays in view.
	_weapon = Weapon.make()
	_weapon.position = Vector3(0.16, -0.18, -0.35)
	_weapon.rotation_degrees = Vector3(0, 3, 0)
	_camera.add_child(_weapon)

	add_child(_player)


# ---------------------------------------------------------------------- input

func _unhandled_input(event: InputEvent) -> void:
	if _ended or _intro_locked():
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity: float = Options.mouse_sensitivity
		_yaw -= event.relative.x * 0.0022 * sensitivity
		var sign_y: float = -1.0 if Options.invert_y else 1.0
		var dy: float = event.relative.y * 0.0022 * sensitivity * sign_y
		_pitch = clampf(_pitch - dy, -1.2, 0.6)
	elif event.is_action_pressed("weather"):
		Director.cycle_weather(_weather)
	elif event.is_action_pressed("replay") and _replay and _replay.has_footage():
		Director.start_replay(self, _replay, _hud, Callable())
	elif event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if _ended or _intro_locked():
		return
	if _replay:
		_replay.sample()
	_in_cover = Input.is_action_pressed("cover")
	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	_invuln = maxf(_invuln - delta, 0.0)
	_damage_flash = maxf(_damage_flash - delta, 0.0)

	_pad_look(delta)
	_update_reticle_scan(delta)

	# Screen shake (gated by Options.screen_shake).
	if _shake > 0.001:
		_camera.position = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake
		_shake = lerpf(_shake, 0.0, clampf(delta * 10.0, 0.0, 1.0))
	else:
		_camera.position = Vector3.ZERO
		_shake = 0.0

	if not _player.is_on_floor():
		_player.velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		_player.velocity.y = JUMP

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis := Basis(Vector3.UP, _yaw)
	var dir := (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed := (SPRINT if Input.is_action_pressed("sprint") else WALK) * (0.5 if _in_cover else 1.0) * _player_speed_multiplier
	_player.velocity.x = dir.x * speed
	_player.velocity.z = dir.z * speed
	_player.rotation.y = _yaw
	_player.move_and_slide()

	if _arm:
		_arm.rotation_degrees = Vector3(_pitch * 57.3, 0, 0)

	if _character:
		var horiz := Vector2(_player.velocity.x, _player.velocity.z).length()
		_character.animate_walk(delta, clampf(horiz / SPRINT, 0.0, 1.0))
		_character.aim(_pitch)

	# Update secondary objectives HUD during gameplay
	_hud.set_secondary_objectives(Score.civilians_saved, Score.equipment_recovered, Score.comm_restored)

	if Input.is_action_just_pressed("shoot"):
		_fire()

	_update_enemies(delta)
	_update_pickups()
	_update_extraction()
	_check_alternate_route()
	_check_dynamic_events()
	_update_civilians(delta)
	_update_music()


## Scripted "the situation degenerates" beats, each firing once.
func _check_dynamic_events() -> void:
	var z := _player.global_position.z
	if not _event_hangar and z < 2.0:
		_event_hangar = true
		_collapse(Vector3(-2, 0, -6))
	if not _event_rooftop and z < -50.0:
		_event_rooftop = true
		_ambush(Vector3(6, 5, -54))
	if not _event_alarm and z < -5.0 and _enemies.size() > 0:
		_event_alarm = true
		_trigger_alarm()
	if not _event_power_outage and z < -15.0:
		_event_power_outage = true
		_power_outage()
	if not _event_blocked_elevator and z < -30.0:
		_event_blocked_elevator = true
		_blocked_elevator()
	if not _event_smoke and z < -40.0:
		_event_smoke = true
		_smoke_effect()


## Enemy reinforcements spawn after dynamic events.
func _spawn_reinforcements() -> void:
	var count := 3 + _reinforcements_pending
	_reinforcements_pending = 0
	for i in count:
		var pos := Vector3(randf_range(-20, 20), 1.0, randf_range(-60, -20))
		_add_enemy(Enemy.make(pos, i >= count - 2))
	if _hud:
		_hud.set_status("RENFORTS — %d hostiles supplémentaires" % count)


## Trigger enemy reinforcements after alarm.
func _trigger_alarm() -> void:
	Audio.hit_confirm()
	if _hud:
		_hud.set_status("ALARME — tous les ennemis sont maintenant en alerte")
	for e in _enemies:
		if is_instance_valid(e) and not e._dying:
			e.cooldown = maxf(e.cooldown - 1.0, 0.0)
			if e.global_position.distance_to(_player.global_position) > 0.05:
				e.look_at(_player.global_position, Vector3.UP)
	if _hud:
		_hud.set_extra("SIRÈNE active — renforts imminents")
	# Schedule reinforcements after a delay.
	_reinforcements_pending = 2
	get_tree().create_timer(3.0).timeout.connect(_spawn_reinforcements)

## Coupure de courant : les lumières s'éteignent partiellement.
func _power_outage() -> void:
	if _hud:
		_hud.set_status("COUPURE DE COURANT — visibilité réduite")
	var sun := get_node_or_null("Sun") as DirectionalLight3D
	if sun:
		sun.light_energy *= 0.45
	var world_env := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env and world_env.environment:
		world_env.environment.ambient_light_energy *= 0.5


## Ascenseur bloqué : le joueur peut tomber dans le vide si il essaie.
func _blocked_elevator() -> void:
	if _hud:
		_hud.set_status("ASCENSEUR BLOQUÉ — passage coupé")


## Effet de fumée : réduit la visibilité (brouillard dense).
func _smoke_effect() -> void:
	if _hud:
		_hud.set_status("FUMÉE — visibilité réduite")
	if _weather:
		_weather.set_preset(3, 2.0)


## A section of the hangar gives way: debris crashes down and hostiles pour in.
func _collapse(pos: Vector3) -> void:
	Audio.explosion()
	Options.rumble(1.0, 0.7, 0.6)
	if _hud:
		_hud.set_status("EFFONDREMENT — planquez-vous !")
	for offset in [Vector3(-2, 0, 0), Vector3(2, 0, 0), Vector3(0, 0, -2), Vector3(0, 0, 2)]:
		var crate := Destructible.make(Destructible.Kind.CRATE, pos + offset + Vector3(0, 7, 0))
		add_child(crate)
		var tween := crate.create_tween()
		tween.tween_property(crate, "position:y", 0.0, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	for offset in [Vector3(-6, 0, 4), Vector3(6, 0, 4)]:
		_add_enemy(Enemy.make(pos + offset, false))


## Hostiles appear behind the player on the rooftop: a surprise flank.
func _ambush(pos: Vector3) -> void:
	Audio.crash()
	Options.rumble(0.8, 0.5, 0.4)
	if _hud:
		_hud.set_status("EMBUSCADE — hostiles sur le flanc !")
	for offset in [Vector3(-8, 0, 6), Vector3(8, 0, 6)]:
		_add_enemy(Enemy.make(pos + offset, false))


## The two raised catwalks (west and east) count as alternate paths.
func _check_alternate_route() -> void:
	var p := _player.global_position
	if not _alt_taken and p.x < -13.0 and p.z < 2.0 and p.z > -48.0 and p.y > 3.0:
		_alt_taken = true
		_take_alternate_route("ITINÉRAIRE ALTERNATIF — coursive ouest")
	if not _alt_taken_2 and p.x > 13.0 and p.z < 2.0 and p.z > -48.0 and p.y > 3.0:
		_alt_taken_2 = true
		_take_alternate_route("ITINÉRAIRE ALTERNATIF — coursive est")


func _take_alternate_route(label: String) -> void:
	Score.register_alternate_path()
	Audio.hit_confirm()
	if _hud:
		_hud.set_status(label + " — bonus")


func _pad_look(delta: float) -> void:
	if GameState.last_device != "gamepad":
		return
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look.length_squared() < 0.0001:
		return
	var sens: float = Options.gamepad_sensitivity
	_yaw -= look.x * PAD_LOOK_SPEED * sens * delta
	var sign_y: float = -1.0 if Options.invert_y else 1.0
	_pitch = clampf(_pitch - look.y * PAD_LOOK_SPEED * sens * delta * sign_y, -1.2, 0.6)


# ------------------------------------------------------------------- gameplay

## Music intensity rises with the number of hostiles still on their feet and
## with how close the player is to dying.
func _update_music() -> void:
	var threats := 0
	for e in _enemies:
		if is_instance_valid(e) and not e._dying:
			threats += 1
	var heat := clampf(float(threats) / 5.0, 0.0, 1.0)
	var danger := 1.0 - clampf(float(_health) / 100.0, 0.0, 1.0)
	Audio.set_intensity(maxf(heat, danger * 0.8))


func _update_enemies(delta: float) -> void:
	for e in _enemies:
		e.cooldown -= delta
		if e.cooldown <= 0.0:
			e.cooldown = randf_range(1.6, 3.0) if not e.heavy else randf_range(1.2, 2.0)
			var to_player: Vector3 = _player.global_position - e.global_position
			if to_player.length() < 34.0 * (1.0 - _enemy_detection_reduction):
				if to_player.length() > 0.05:
					e.look_at(_player.global_position, Vector3.UP)
				var base := 12 if e.heavy else 8
				_take_damage(int(base * Options.incoming_damage_scale()))


func _update_pickups() -> void:
	for p in _pickups.duplicate():
		if p.body.global_position.distance_to(_player.global_position) < 1.8:
			_health = mini(_health + 35, 100)
			Audio.hit_confirm()
			p.body.queue_free()
			_pickups.erase(p)
			if _hud:
				_hud.set_status("INTÉGRITÉ %d%%" % _health)


func _update_extraction() -> void:
	if not _extraction_open:
		return
	if _player.global_position.distance_to(_extraction) < 5.0:
		_finish()


## Public alias so explosions can damage the player via the "player" group.
func take_damage(amount: int) -> void:
	_take_damage(amount)


func _take_damage(amount: int) -> void:
	if _invuln > 0.0:
		return
	_invuln = 0.6
	_health = maxi(_health - amount, 0)
	Score.register_damage(amount)
	Progress.fail("touché")
	Audio.play_noise(0.08, -12.0, 0.6)
	Options.rumble(0.3, 0.6)
	_add_shake(1.0)
	if _hud:
		_hud.set_status("INTÉGRITÉ %d%%" % _health)
	if _health <= 0:
		_finish()


## True while the intro cinematic still owns the camera.
func _intro_locked() -> bool:
	return _intro != null and is_instance_valid(_intro) and not _intro.is_done()


func _fire() -> void:
	if _ended or _intro_locked() or not _camera or _fire_cooldown > 0.0:
		return
	_fire_cooldown = FIRE_COOLDOWN
	Audio.gunshot()
	Options.rumble(0.4, 0.15, 0.1)
	if _weapon:
		_weapon.fire()
	if _hud:
		_hud.reticle_kick()
	_add_shake(0.3)
	var from: Vector3 = _weapon.muzzle().global_position if _weapon else _camera.global_position
	var shot := _resolve_shot()
	Vfx.tracer(self, from, shot["point"])
	if shot["surface"]:
		Vfx.spark(self, shot["point"], shot["normal"])
		Vfx.dust(self, shot["point"], shot["normal"])
		var collider = shot.get("collider", null)
		if collider != null and not (collider is Enemy):
			Vfx.impact_mark(self, shot["point"], shot["normal"])
	Score.register_shot(shot["hit"])


## Shoots down the centre of the camera, so the shot always lands where the
## reticle is. A forgiving cone picks the nearest enemy inside the aim-assist
## radius when the ray misses by a hair. Returns where the shot landed and
## whether it counted as a hit, so `_fire()` can draw the tracer and spark.
func _resolve_shot() -> Dictionary:
	var from := _camera.global_position
	var aim_dir := -_camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(
		from, from + aim_dir * 120.0, 0xFFFFFFFF, [_player.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var point: Vector3 = hit["position"]
		var normal: Vector3 = hit["normal"]
		var collider = hit["collider"]
		if collider is Enemy:
			var enemy := collider as Enemy
			if enemy._dying:
				return {"hit": false, "point": point, "normal": normal, "surface": true, "collider": collider}
			Audio.hit_confirm()
			enemy.take_damage(1)
			if _hud:
				_hud.reticle_hit()
			return {"hit": true, "point": point, "normal": normal, "surface": true, "collider": collider}
		if collider is Destructible:
			var prop := collider as Destructible
			prop.take_damage(1)
			if _hud:
				_hud.reticle_hit()
			return {"hit": true, "point": point, "normal": normal, "surface": true, "collider": collider}
		return {"hit": false, "point": point, "normal": normal, "surface": true, "collider": collider}
	var assisted := _aim_assist_target(from, aim_dir)
	if assisted:
		Audio.hit_confirm()
		assisted.take_damage(1)
		if _hud:
			_hud.reticle_hit()
		var chest: Vector3 = assisted.global_position + Vector3(0, 0.9, 0)
		return {"hit": true, "point": chest, "normal": (from - chest).normalized(), "surface": true, "collider": assisted}
	# Nothing in the way: the tracer still flies off into the distance.
	return {"hit": false, "point": from + aim_dir * 120.0, "normal": -aim_dir, "surface": false, "collider": null}


## Nearest living enemy inside the aim-assist cone with a clear line of sight.
func _aim_assist_target(from: Vector3, aim_dir: Vector3) -> Enemy:
	var tolerance: float = Options.aim_tolerance()
	if tolerance <= 0.0:
		return null
	var screen_h := get_viewport().get_visible_rect().size.y
	if screen_h <= 0.0:
		return null
	var half_fov := deg_to_rad(_camera.fov * 0.5)
	var max_angle := atan(tan(half_fov) * tolerance / (screen_h * 0.5))
	var best: Enemy = null
	var best_angle := max_angle
	for e in _enemies:
		if not is_instance_valid(e) or e._dying or e.is_queued_for_deletion():
			continue
		var enemy := e as Enemy
		if enemy == null:
			continue
		var centre: Vector3 = enemy.global_position + Vector3(0, 0.9, 0)
		var to_enemy: Vector3 = centre - from
		var dist := to_enemy.length()
		if dist < 0.5 or dist > 80.0:
			continue
		var angle := aim_dir.angle_to(to_enemy / dist)
		if angle >= best_angle:
			continue
		if not _clear_line(from, centre):
			continue
		best = enemy
		best_angle = angle
	return best


func _add_shake(amount: float) -> void:
	_shake = maxf(_shake, amount * Options.screen_shake)


func _clear_line(from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to, 0xFFFFFFFF, [_player.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	return hit["collider"] is Enemy


## Keeps the crosshair warm while something shootable is under it.
func _update_reticle_scan(delta: float) -> void:
	if _hud == null or _camera == null:
		return
	_reticle_scan = maxf(_reticle_scan - delta, 0.0)
	if _reticle_scan > 0.0:
		return
	_reticle_scan = 0.08
	var from := _camera.global_position
	var aim_dir := -_camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(
		from, from + aim_dir * 120.0, 0xFFFFFFFF, [_player.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var hot := false
	if not hit.is_empty():
		var collider = hit["collider"]
		if collider is Enemy:
			hot = not (collider as Enemy)._dying
		elif collider is Destructible:
			hot = true
	if not hot:
		hot = _aim_assist_target(from, aim_dir) != null
	_hud.set_reticle_hot(hot)


func _maybe_drop_pickup(enemy: Enemy) -> void:
	# Heavies always drop health; grunts sometimes do.
	var drop_chance := 0.2 if GameState.ng_plus else 0.35
	if enemy.heavy or randf() < drop_chance:
		_pickups.append(_spawn_pickup(enemy.global_position))


func _spawn_pickup(pos: Vector3) -> Dictionary:
	var body := Area3D.new()
	body.position = pos + Vector3(0, 0.4, 0)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.7, 0.7)
	mesh.mesh = box
	var mat := EnvBuilder.material(Color(0.3, 0.85, 0.4))
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.85, 0.4)
	mat.emission_energy_multiplier = 1.4
	mesh.material_override = mat
	body.add_child(mesh)
	add_child(body)
	return {"body": body}


func _advance_wave() -> void:
	_lose_unsaved_civilians(_zone)
	_wave_index += 1
	if _wave_index >= _waves.size():
		_open_extraction()
		return
	Audio.hit_confirm()
	_start_wave()


func _open_extraction() -> void:
	_extraction_open = true
	if _hud:
		_hud.set_objective("Zones sécurisées — rejoignez le point d'extraction (balise verte)")
	_hud.set_status("EXTRACTION OUVERTE")
	# Secondary objective: restore communications
	Score.register_comm_restored()


func _finish() -> void:
	if _ended:
		return
	_ended = true
	Score.time_bonus += 3000
	Progress.record_run(GameState.Mode.TPS, Score.total(), Score.rank())
	var challenge := Progress.evaluate()
	if challenge["success"]:
		Progress.mark_act_cleared(GameState.Mode.TPS)
	if _hud:
		_hud.set_secondary_objectives(Score.civilians_saved, Score.equipment_recovered, Score.comm_restored)
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
