extends Node
## Headless functional check: autoloads, actors, HUD, scoring and the
## replayable-challenge / equipment systems. Prints "VERIFY RESULT: OK" and
## exits 0, or lists every failure and exits 1.

var _failures: Array = []


func _ready() -> void:
	_check_autoloads()
	_check_localisation()
	_check_options_persistence()
	_check_actors()
	_check_materials()
	_check_world()
	_check_models()
	_check_destructibles()
	_check_hud()
	_check_pause()
	_check_editor()
	_check_results_screen()
	await _check_vfx()
	_check_director()
	_check_score()
	_check_challenges()
	_check_death_is_failure()
	_check_drive_chasers()
	_check_equipment()
	_check_keybinds()

	if _failures.is_empty():
		print("VERIFY RESULT: OK")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("VERIFY FAIL: %s" % f)
		print("VERIFY RESULT: FAIL")
		get_tree().quit(1)


func _expect(cond: bool, message: String) -> void:
	if not cond:
		_failures.append(message)


## True when any Label under `root` contains `needle` (used to prove a line is
## hidden or shown without depending on the exact layout).
func _labels_contain(root: Node, needle: String) -> bool:
	for node in root.find_children("*", "Label", true, false):
		if (node as Label).text.contains(needle):
			return true
	return false


func _check_autoloads() -> void:
	_expect(GameState != null, "GameState autoload missing")
	_expect(Score != null, "Score autoload missing")
	_expect(Progress != null, "Progress autoload missing")
	_expect(Audio != null, "Audio autoload missing")
	_expect(Options != null, "Options autoload missing")
	_expect(LevelData != null, "LevelData autoload missing")
	_expect(Loc != null, "Loc autoload missing")


## FR keeps the source text; EN translates both fixed labels and the dynamic
## templates the modes format themselves.
func _check_localisation() -> void:
	var saved: String = Options.language
	Loc.set_language("fr")
	_expect(Loc.t("OPTIONS") == "OPTIONS", "FR should keep the source text")
	Loc.set_language("en")
	_expect(Loc.t("OPTIONS") == "OPTIONS", "EN label missing: OPTIONS")
	_expect(Loc.t("Partie libre") == "Free run", "EN label missing: challenge name")
	_expect(Loc.t("Terminer sans être touché ni causer de dégâts") ==
		"Finish without taking or dealing damage",
		"EN label missing: no-damage challenge description")
	_expect(Loc.t("MUNITIONS %d / %d") % [12, 30] == "AMMO 12 / 30",
		"EN ammo template not translated")
	# The modes use an em dash (U+2014) in these lines; the template keys must
	# match it exactly or the translation silently falls back to French.
	_expect(Loc.t("Zone 2 — 5 hostiles") == "Zone 2 — 5 hostiles",
		"EN dynamic template not matched")
	_expect(Loc.t("CIVIL SECOURU — 2/3") == "CIVILIAN RESCUED — 2/3",
		"EN em-dash template not matched")
	_expect(Loc.t("RENFORTS — 3 hostiles supplémentaires") ==
		"REINFORCEMENTS — 3 extra hostiles",
		"EN em-dash reinforcement template not matched")
	_expect(Loc.t("INTÉGRITÉ 75%") == "INTEGRITY 75%",
		"EN percent template not matched")
	_expect(Loc.t("DÉFI ÉCHOUÉ — %s") % Loc.t("civil touché") ==
		"CHALLENGE FAILED — civilian hit",
		"EN challenge failure template not translated")
	_expect(Loc.t("REPRENDRE") == "RESUME", "EN label missing: REPRENDRE")
	_expect(Loc.t("QUITTER LE JEU") == "QUIT GAME", "EN label missing: QUITTER LE JEU")
	_expect(Loc.t("FERMER LES RÉSULTATS") == "CLOSE RESULTS",
		"EN label missing: FERMER LES RÉSULTATS")
	_expect(Loc.t("ACTE SUIVANT") == "NEXT ACT", "EN label missing: ACTE SUIVANT")
	_expect(Loc.t("ACTE ÉCHOUÉ") == "ACT FAILED", "EN label missing: ACTE ÉCHOUÉ")
	_expect(Loc.t("Défi « %s » : %s%s") % ["Sans dégâts", Loc.t("échoué"), " — " + Loc.t("touché")] ==
		"Challenge \"Sans dégâts\": failed — hit", "EN challenge template not translated")
	_expect(Loc.t("ÉDITEUR DE NIVEAU") == "LEVEL EDITOR",
		"EN label missing: ÉDITEUR DE NIVEAU")
	_expect(Loc.t("Tester l'acte 3") == "Test act 3", "EN label missing: Tester l'acte 3")
	_expect(Loc.t("RALENTI") == "SLOW MOTION", "EN label missing: RALENTI")
	_expect(Loc.t("● RALENTI — R pour passer") == "● SLOW MOTION — R to skip",
		"EN replay caption not translated")
	_expect(Loc.t("temps écoulé") == "time ran out", "EN reason missing: temps écoulé")
	_expect(Loc.t("%d nœuds • %d props\nOutil : %s\nClic : ajouter/déplacer • Clic droit : supprimer") % [3, 2, "x"] ==
		"3 nodes • 2 props\nTool: x\nClick: add/move • Right click: delete",
		"EN editor status template not translated")
	Loc.set_language(saved)


## Weather/dynamic/replay were editable in the options screen but missing from
## `Options.load_from_disk()`/`save_to_disk()`, so they reset on every launch.
## Round-trip them through the real file, then restore the player's settings.
func _check_options_persistence() -> void:
	var saved_bytes := PackedByteArray()
	if FileAccess.file_exists(Options.PATH):
		saved_bytes = FileAccess.get_file_as_bytes(Options.PATH)
	var saved_weather: int = Options.weather
	var saved_dynamic: bool = Options.weather_dynamic
	var saved_replay: bool = Options.replay_enabled

	Options.weather = 3
	Options.weather_dynamic = false
	Options.replay_enabled = false
	Options.save_to_disk()
	Options.weather = 0
	Options.weather_dynamic = true
	Options.replay_enabled = true
	Options.load_from_disk()
	_expect(Options.weather == 3, "weather option was not persisted")
	_expect(not Options.weather_dynamic, "dynamic weather option was not persisted")
	_expect(not Options.replay_enabled, "replay option was not persisted")

	# Put the player's file and in-memory settings back exactly as they were.
	if saved_bytes.is_empty():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Options.PATH))
	else:
		var file := FileAccess.open(Options.PATH, FileAccess.WRITE)
		if file:
			file.store_buffer(saved_bytes)
			file.close()
	Options.weather = saved_weather
	Options.weather_dynamic = saved_dynamic
	Options.replay_enabled = saved_replay
	Options.load_from_disk()


func _check_actors() -> void:
	var character := Character.make(Color(0.3, 0.4, 0.3), Color(0.1, 0.1, 0.12))
	_expect(character != null, "Character.make returned null")
	if character:
		_expect(character.body_part_count() > 0, "skinned body has no parts")
		_expect(not character.is_dead(), "a fresh character is already dead")
		_expect(not character.is_ragdoll_active(), "ragdoll active before death")
		character.free()
	for kind in [Character.VARIANT_SCOUT, Character.VARIANT_ELITE, Character.VARIANT_CIVILIAN]:
		var variant := Character.make(Color(0.3, 0.4, 0.3), Color(0.1, 0.1, 0.12), false, kind)
		_expect(variant.variant() == kind, "Character variant not applied: " + kind)
		variant.free()
	var weapon := Weapon.make()
	_expect(weapon != null, "Weapon.make returned null")
	if weapon:
		weapon.free()
	var enemy := Enemy.make(Vector3.ZERO, false)
	_expect(enemy != null, "Enemy.make returned null")
	if enemy:
		_expect(enemy.variant != "", "Enemy has no visual variant")
		# A non-lethal hit must play the stagger, not just flash. The body has
		# to be in the tree for the flash tween and the AnimationPlayer.
		var host := Node3D.new()
		add_child(host)
		host.add_child(enemy)
		enemy.take_damage(1)
		_expect(enemy._character._one_shot, "enemy hit did not trigger a stagger")
		_expect(enemy._character._anim.current_animation == "hit",
			"enemy hit did not play the hit clip")
		host.free()


func _check_materials() -> void:
	var wall := EnvBuilder.material(EnvBuilder.MAT_WALL_A)
	_expect(wall != null, "EnvBuilder.material returned null")
	_expect(wall.albedo_texture != null, "wall material lost its texture")
	_expect(wall.uv1_triplanar, "wall material is not triplanar")
	var road := EnvBuilder.material(EnvBuilder.MAT_ROAD)
	_expect(road.albedo_texture != null, "road material lost its texture")
	if FileAccess.file_exists("res://assets/textures_cc0/concrete.png"):
		_expect(wall.albedo_color.is_equal_approx(Color.WHITE),
			"CC0 texture should not be palette-tinted")


func _check_world() -> void:
	var root := Node3D.new()
	add_child(root)
	EnvBuilder.setup_world(root)
	var world := root.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_expect(world != null, "setup_world built no WorldEnvironment")
	if world and world.environment and world.environment.sky:
		var mat := world.environment.sky.sky_material
		_expect(mat != null, "world has no sky material")
		var hdri := EnvBuilder.hdri_path()
		if hdri != "" and EnvBuilder.load_hdri(hdri) != null:
			_expect(mat is PanoramaSkyMaterial, "HDRI present but sky is not a panorama")
		else:
			_expect(mat is ProceduralSkyMaterial, "no HDRI but sky is not procedural")
	root.queue_free()


func _check_models() -> void:
	for model_name in ["barrel", "crate", "streetlamp", "barrier", "dumpster", "planter"]:
		var scene := EnvBuilder.load_model_scene(model_name)
		_expect(scene != null, "model scene missing: " + model_name)
		if scene == null:
			continue
		_expect(scene.get_child_count() > 0, "model scene empty: " + model_name)
		if EnvBuilder._cc0_model_path(model_name) != "":
			# CC0 props are normalized to MODEL_SIZE and dropped on the floor.
			var box := EnvBuilder._scene_aabb(scene, scene.transform)
			var longest := maxf(box.size.x, maxf(box.size.y, box.size.z))
			var target := float(EnvBuilder.MODEL_SIZE.get(model_name, 0.0))
			_expect(absf(longest - target) <= target * 0.02,
				"%s scaled to %.2f m, expected %.2f m" % [model_name, longest, target])
			_expect(absf(box.position.y) <= 0.01, "%s floats off the floor" % model_name)
		scene.free()


func _check_destructibles() -> void:
	for kind in [Destructible.Kind.BARREL, Destructible.Kind.CRATE]:
		var d := Destructible.make(kind, Vector3.ZERO)
		add_child(d)
		var shape: Shape3D = null
		for c in d.get_children():
			if c is CollisionShape3D:
				shape = (c as CollisionShape3D).shape
				_expect((c as CollisionShape3D).position.y > 0.0,
					"destructible %d collision sits below the floor" % kind)
		_expect(shape != null, "destructible %d has no collision" % kind)
		if shape is BoxShape3D:
			_expect((shape as BoxShape3D).size.length() > 0.1, "crate hitbox is empty")
		elif shape is CylinderShape3D:
			_expect((shape as CylinderShape3D).height > 0.1, "barrel hitbox is flat")
		d.queue_free()


func _check_hud() -> void:
	var hud := Hud.new()
	add_child(hud)
	hud.build("VERIFY", "check", "clavier", "manette")
	hud.set_secondary_objectives(2, 3, 1)
	hud.set_extra("extra")
	_expect(hud.get_child_count() > 0, "HUD built no nodes")

	# Reticle: hidden by default, then follows the centre or an explicit point.
	_expect(hud.get_node_or_null("Reticle") != null, "HUD has no reticle node")
	var centre := hud.get_viewport().get_visible_rect().size * 0.5
	_expect(hud.reticle_position().is_equal_approx(centre), "reticle does not sit at the screen centre")
	hud.set_reticle_visible(true)
	hud.set_reticle_position(Vector2(120, 80))
	_expect(hud.reticle_position() == Vector2(120, 80), "reticle ignores set_reticle_position")
	hud.reticle_kick()
	hud.reticle_hit()
	hud.set_reticle_hot(true)
	hud.set_reticle_visible(false)
	# `device_changed` passes the device name: the slot must accept it or every
	# mouse/gamepad switch logs a signal arity error (seen in the player log).
	GameState._set_device("gamepad")
	GameState._set_device("keyboard")
	# A language change while an act is running re-applies the static lines.
	var saved_lang: String = Options.language
	hud.set_title("ACTE 1 — TOUR")
	Loc.set_language("en")
	_expect(hud._title.text == "ACT 1 — TOWER",
		"HUD did not retranslate on language change")
	# A challenge that becomes unreachable mid-run must tell the player why,
	# and the notice must follow a language change too.
	hud.notify_challenge_failed("touché")
	_expect(hud._status.text == "CHALLENGE FAILED — hit",
		"challenge failure notice is not translated")
	Loc.set_language("fr")
	_expect(hud._status.text == "DÉFI ÉCHOUÉ — touché",
		"challenge failure notice did not retranslate")
	Loc.set_language(saved_lang)
	# No shots fired (driving act): the score line must not claim an accuracy,
	# and a shooting act must still show it.
	Score.reset()
	hud._refresh()
	_expect(not hud._score.text.contains("Précision") and
		not hud._score.text.contains("Accuracy"),
		"HUD shows an accuracy line with no shots fired")
	Score.register_shot(true)
	hud._refresh()
	_expect(hud._score.text.contains("Précision") or
		hud._score.text.contains("Accuracy"),
		"HUD hides accuracy when shots were fired")
	Score.reset()
	hud._refresh()
	hud.queue_free()


## The in-act pause overlay freezes the tree while open and releases it on
## close; the modes rely on that to stop the simulation behind the menu.
func _check_pause() -> void:
	var pause := PauseMenu.new()
	add_child(pause)
	_expect(not pause.is_open(), "pause menu starts open")
	_expect(pause.layer > 1, "pause menu draws below the HUD")
	pause.open()
	_expect(pause.is_open(), "pause menu did not open")
	_expect(get_tree().paused, "pause menu did not freeze the tree")
	# The options sub-screen runs while the tree is paused, then hands control
	# back to the pause panel.
	pause._open_options()
	_expect(pause._options != null, "pause menu did not open options")
	if pause._options != null:
		pause._options._close()
	_expect(pause._options == null, "pause options did not close")
	# One Escape press must not close both screens: the guard has to survive
	# the panel rebuild.
	_expect(pause._options_closing, "pause options guard was cleared by the rebuild")
	pause.close()
	_expect(not pause.is_open(), "pause menu did not close")
	_expect(not get_tree().paused, "pause menu did not release the tree")
	pause.queue_free()


## The level editor is reachable from the menu: it must build in either
## language and expose its status line (and it must not crash headless).
func _check_editor() -> void:
	var saved_lang: String = Options.language
	var saved_path: Array = LevelData.custom_path.duplicate()
	var saved_props: Array = LevelData.props.duplicate()
	Loc.set_language("en")
	var script: GDScript = load("res://scripts/ui/level_editor.gd")
	_expect(script != null, "level editor script does not load")
	if script == null:
		Loc.set_language(saved_lang)
		return
	var editor: Control = script.new()
	add_child(editor)
	var titled := false
	for node in editor.find_children("*", "Label", true, false):
		if (node as Label).text == "LEVEL EDITOR":
			titled = true
	_expect(titled, "level editor title missing or untranslated")
	_expect(editor._status != null and editor._status.text.contains("Tool:"),
		"level editor status template is not translated")
	_expect(Loc.t("Niveau enregistré") == "Level saved",
		"EN label missing: level saved notice")
	_expect(Loc.t("Aucun niveau enregistré") == "No saved level",
		"EN label missing: no saved level notice")
	editor._notice = "Niveau enregistré"
	editor._refresh()
	_expect(editor._status.text.begins_with("Level saved"),
		"level editor save confirmation is not translated")
	editor.queue_free()

	# `user://level.json` is hand-editable, so a malformed file must be
	# rejected or skipped entry by entry instead of crashing the editor/act.
	_expect(not LevelData.apply_data("not a level"),
		"level loader accepted a non-dictionary file")
	_expect(not LevelData.apply_data({"path": "nope", "props": []}),
		"level loader accepted a non-array path")
	_expect(not LevelData.apply_data({"path": [[0, 0]], "props": []}),
		"level loader accepted a one-node path")
	_expect(LevelData.apply_data({
		"path": [[0, 0], [0, -60], ["x", 3]],
		"props": [{"kind": "bogus", "x": 0, "z": 0}, {"kind": "barrel", "x": 4, "z": -8}],
	}), "level loader rejected a level with one bad node")
	_expect(LevelData.custom_path.size() == 2, "level loader kept a malformed node")
	_expect(LevelData.props.size() == 1, "level loader kept an unknown prop kind")

	# Props dropped in the editor must actually appear in the drive act.
	var drive_script: GDScript = load("res://scripts/modes/drive.gd")
	_expect(drive_script != null, "drive act script does not load")
	if drive_script != null:
		var probe := Node3D.new()
		probe.set_script(drive_script)
		probe._build_editor_props()
		_expect(probe.get_child_count() == 1, "drive act does not spawn editor props")
		probe.free()

	LevelData.custom_path = saved_path
	LevelData.props = saved_props
	Loc.set_language(saved_lang)


## The results screen offers the next act after a clear (the three acts form a
## run) and the retry button after a failure, never the next act.
func _check_results_screen() -> void:
	var script: GDScript = load("res://scripts/ui/menu.gd")
	_expect(script != null, "menu script does not load")
	if script == null:
		return
	var menu: Control = script.new()
	GameState.show_results_on_load = true
	GameState.last_act_success = true
	GameState.mode = GameState.Mode.TPS
	add_child(menu)
	var next := menu.find_child("NextActButton", true, false) as Button
	_expect(next != null, "results screen has no next-act button after a clear")
	if next:
		_expect(next.text == Loc.t("ACTE SUIVANT"),
			"next-act button is not translated")
	menu.queue_free()

	var failed: Control = script.new()
	GameState.show_results_on_load = true
	GameState.last_act_success = false
	add_child(failed)
	_expect(failed.find_child("NextActButton", true, false) == null,
		"failed results screen offers the next act")
	_expect(failed.find_child("RetryButton", true, false) != null,
		"results screen has no retry button")
	failed.queue_free()
	GameState.last_act_success = true

	# The driving act fires no shots: its results screen must not print an
	# "Accuracy" line, while a shooting act must keep it.
	var saved_lang: String = Options.language
	Loc.set_language("en")
	Score.reset()
	var drive_menu: Control = script.new()
	GameState.show_results_on_load = true
	GameState.last_act_success = true
	GameState.mode = GameState.Mode.DRIVE
	add_child(drive_menu)
	_expect(not _labels_contain(drive_menu, "Accuracy:"),
		"results screen shows accuracy with no shots fired")
	drive_menu.queue_free()

	Score.register_shot(true)
	var tps_menu: Control = script.new()
	GameState.show_results_on_load = true
	GameState.mode = GameState.Mode.TPS
	add_child(tps_menu)
	_expect(_labels_contain(tps_menu, "Accuracy:"),
		"results screen hides accuracy when shots were fired")
	tps_menu.queue_free()
	Score.reset()
	Loc.set_language(saved_lang)


## Shot feedback: tracers and impact sparks appear, self-free, and ignore
## zero-length shots (muzzle already past the impact point).
func _check_vfx() -> void:
	var root := Node3D.new()
	add_child(root)
	Vfx.tracer(root, Vector3.ZERO, Vector3(0, 0, -12))
	_expect(root.get_child_count() == 1, "Vfx.tracer spawned nothing")
	Vfx.spark(root, Vector3(0, 0, -12), Vector3.UP)
	Vfx.dust(root, Vector3(0, 0, -12), Vector3.UP)
	Vfx.smoke(root, Vector3(0, 0, -12))
	Vfx.impact_mark(root, Vector3(0, 0, -12), Vector3.UP)
	_expect(root.get_child_count() == 5, "Vfx did not spawn all effects")
	# The impact mark is a quad aligned to the surface normal, never a Decal
	# (which showed as a black square and is unsupported on compatibility).
	var mark := root.get_child(4)
	_expect(mark is MeshInstance3D and mark.mesh is QuadMesh,
		"impact mark is not a quad mesh")
	if mark is MeshInstance3D:
		_expect(mark.global_basis.z.dot(Vector3.UP) > 0.99,
			"impact mark is not aligned to the surface normal")
	_expect(not (mark is Decal), "impact mark still uses a Decal")
	Vfx.tracer(root, Vector3.ZERO, Vector3(0, 0, -0.1))
	_expect(root.get_child_count() == 5, "Vfx.tracer drew a zero-length shot")
	# Fast effects (tracer, spark, dust) free themselves within ~0.5 s.
	await get_tree().create_timer(0.7).timeout
	await get_tree().process_frame
	_expect(root.get_child_count() <= 2, "fast Vfx nodes did not free themselves")
	root.queue_free()


## Weather wiring uses a static handler with bound arguments (no lambda), so a
## preset change must still reach the HUD.
func _check_director() -> void:
	var stage := Node3D.new()
	add_child(stage)
	var hud := Hud.new()
	add_child(hud)
	hud.build("VERIFY", "check", "clavier", "manette")
	var weather := Director.spawn_weather(stage, stage, hud)
	_expect(weather != null, "Director.spawn_weather returned null")
	if weather:
		var before := weather.preset
		hud.set_extra("")
		weather.cycle()
		_expect(weather.preset != before, "Weather.cycle did not change the preset")
		_expect(hud.extra_text() != "", "weather change did not reach the HUD")
		weather.queue_free()
	hud.queue_free()
	stage.queue_free()


func _check_score() -> void:
	Score.equipment_recovered = 5
	Score.comm_restored = 2
	Score.takedowns = 4
	Score.reset()
	_expect(Score.equipment_recovered == 0, "Score.reset leaves equipment_recovered")
	_expect(Score.comm_restored == 0, "Score.reset leaves comm_restored")
	_expect(Score.takedowns == 0, "Score.reset leaves takedowns")
	_expect(Score.rank() != "", "Score.rank returned empty")

	# No shots fired (the driving act): no accuracy to report, and no free
	# 1000-point accuracy bonus either.
	_expect(Score.accuracy_ratio() == 0.0,
		"accuracy_ratio should be 0 with no shots")
	var no_shots := Score.total()
	Score.register_shot(true)
	Score.register_shot(false)
	var with_shots := Score.total()
	_expect(with_shots > no_shots, "firing shots should score above the empty run")
	Score.reset()


func _check_challenges() -> void:
	var saved_challenge: String = Progress.selected_challenge
	var saved_acts: Array = Progress.cleared_acts

	Progress.selected_challenge = "accuracy"
	Progress.begin()
	var accuracy := Progress.evaluate()
	_expect(not accuracy["success"], "accuracy challenge should fail with no shots")

	Progress.selected_challenge = "none"
	Progress.begin()
	var free_run := Progress.evaluate()
	_expect(free_run["success"], "free run should always succeed")

	Progress.selected_challenge = "explorer"
	Score.reset()
	Progress.begin()
	var explorer := Progress.evaluate()
	_expect(not explorer["success"], "explorer challenge should fail without a route")
	Score.alternate_paths = 1
	Progress.begin()
	explorer = Progress.evaluate()
	_expect(explorer["success"], "explorer challenge should pass with a route")

	# An act that fails outright (act 3 out of time) must not report a passed
	# challenge, even when the condition looks satisfied.
	Progress.begin()
	Progress.fail("temps écoulé")
	var aborted := Progress.evaluate()
	_expect(not aborted["success"], "a failed run should fail its challenge")
	_expect(aborted["reason"] == "temps écoulé", "failed run reason was not kept")

	# "No damage" has to be reachable in every act: the rail act fails it on a
	# civilian hit and the driving act on a ram (neither used to call fail()).
	Progress.selected_challenge = "no_damage"
	Progress.begin()
	Progress.fail("percuté")
	var rammed := Progress.evaluate()
	_expect(not rammed["success"], "no-damage challenge should fail after a ram")
	_expect(rammed["reason"] == "percuté", "no-damage reason was not kept")
	Score.reset()

	Progress.cleared_acts = [0, 1, 2]
	_expect(Progress.all_acts_cleared(), "all_acts_cleared should be true with 3 acts")
	_expect(Progress.CHALLENGES.size() >= 4, "challenge list is too short")

	Progress.selected_challenge = saved_challenge
	Progress.cleared_acts = saved_acts


## Dying in act 1 used to call the same `_finish()` as a successful extraction,
## so a dead player cleared the act and posted a score. `_finish(false)` must
## report a failed act and leave the cleared list untouched.
func _check_death_is_failure() -> void:
	var saved_acts: Array = Progress.cleared_acts.duplicate()
	var saved_challenge: String = Progress.selected_challenge
	var saved_results: bool = GameState.show_results_on_load
	var script: GDScript = load("res://scripts/modes/tps.gd")
	_expect(script != null, "tps act script does not load")
	if script != null:
		var probe := Node3D.new()
		probe.set_script(script)
		Progress.selected_challenge = "none"
		Progress.begin()
		probe._finish(false)
		_expect(not GameState.last_act_success,
			"dying in act 1 reported a successful act")
		_expect(Progress.cleared_acts == saved_acts,
			"dying in act 1 cleared the act anyway")
		probe.free()
	Progress.selected_challenge = saved_challenge
	Progress.cleared_acts = saved_acts
	GameState.last_act_success = true
	GameState.show_results_on_load = saved_results


## The rival cars used to be built but never updated (`_update_chasers` had no
## caller), so the Act 3 chase was inert. Prove the physics loop drives them.
func _check_drive_chasers() -> void:
	var script: GDScript = load("res://scripts/modes/drive.gd")
	_expect(script != null, "drive act script does not load")
	if script == null:
		return
	var source := FileAccess.get_file_as_string("res://scripts/modes/drive.gd")
	_expect(source.count("_update_chasers(") >= 2,
		"drive physics loop never updates the rival cars")
	# Physics bodies need a world: a plain host node in the tree gives the
	# probe valid global transforms without running the drive act's `_ready`.
	var host := Node3D.new()
	add_child(host)
	var car := VehicleBody3D.new()
	car.mass = 900.0
	host.add_child(car)
	var rival := VehicleBody3D.new()
	rival.mass = 850.0
	rival.position = Vector3(0, 1, -30)
	host.add_child(rival)
	var probe := Node3D.new()
	probe.set_script(script)
	probe._car = car
	probe._chasers.append({"body": rival, "wrecked": false, "cooldown": 0.0})
	probe._update_chasers(0.016)
	_expect(rival.engine_force > 0.0, "rival car gets no throttle")
	_expect(absf(rival.steering) > 0.0, "rival car does not steer toward the player")
	probe.free()
	host.free()


func _check_equipment() -> void:
	var saved_equip: int = Progress.equipment_unlocked
	var saved_acts: Array = Progress.cleared_acts
	var saved_unlocked: bool = Progress.ng_plus_unlocked
	var saved_game_ng: bool = GameState.ng_plus

	Progress.equipment_unlocked = 0
	_expect(not Progress.has_equipment(1, 1), "equipment bit should start clear")
	Progress.equipment_unlocked = 1 << (1 * Progress.EQUIP_SLOTS + 1)
	_expect(Progress.has_equipment(1, 1), "equipment bit should be set")
	_expect(not Progress.has_equipment(1, 0), "neighbouring equipment bit leaked")
	# The equipment index must match GameState.Mode (RAIL = 1, DRIVE = 2):
	# the perks used to be swapped between acts 2 and 3.
	_expect(Progress.equipment_description(GameState.Mode.TPS, 0) != "",
		"TPS equipment description empty")
	_expect(Progress.equipment_description(GameState.Mode.RAIL, 0) == "Deux projectiles en jeu",
		"rail equipment description is not the rail perk")
	_expect(Progress.equipment_description(GameState.Mode.DRIVE, 0) == "Adhérence routière +15 %",
		"drive equipment description is not the drive perk")
	_expect(GameState.info(GameState.Mode.RAIL)["short"] == "Rail",
		"rail act short name is wrong")
	_expect(GameState.info(GameState.Mode.DRIVE)["short"] == "Conduite",
		"drive act short name is wrong")

	# Clearing an act earns slot 1 even without a challenge; slot 2 is the NG+
	# reward. Both used to be unreachable (slot 2 had no unlock path at all).
	Progress.cleared_acts = []
	Progress.equipment_unlocked = 0
	GameState.ng_plus = false
	Progress.mark_act_cleared(GameState.Mode.RAIL)
	_expect(Progress.cleared_acts.has(GameState.Mode.RAIL), "act clear was not recorded")
	_expect(Progress.has_equipment(GameState.Mode.RAIL, 0),
		"act clear did not unlock the first equipment slot")
	_expect(not Progress.has_equipment(GameState.Mode.RAIL, 1),
		"second equipment slot unlocked without New Game+")
	GameState.ng_plus = true
	Progress.mark_act_cleared(GameState.Mode.DRIVE)
	_expect(Progress.has_equipment(GameState.Mode.DRIVE, 1),
		"New Game+ act clear did not unlock the second equipment slot")
	GameState.ng_plus = saved_game_ng
	Progress.equipment_unlocked = saved_equip
	Progress.cleared_acts = saved_acts
	Progress.ng_plus_unlocked = saved_unlocked
	Progress.save_to_disk()


## Keyboard rebinding: the stock bindings use physical keycodes, so reading only
## `keycode` displayed "-" for every default and "reset" cleared the overrides
## without putting the stock keys back.
func _check_keybinds() -> void:
	var saved: Dictionary = Options.keybinds.duplicate()
	var script: GDScript = load("res://scripts/ui/options_menu.gd")
	_expect(script != null, "options menu script does not load")
	var menu: PanelContainer = null
	if script != null:
		menu = script.new()
		add_child(menu)

	Options.rebind_key("shoot", KEY_X)
	_expect(_first_key("shoot") == KEY_X,
		"rebind did not put the new key in the InputMap")
	if menu:
		_expect(menu._key_name("shoot") == OS.get_keycode_string(KEY_X),
			"options screen does not show the rebound key")

	# Reset must actually put the stock physical key back, not just forget the
	# override (the InputMap used to keep the test binding forever).
	Options.reset_keybinds()
	_expect(_first_key("shoot") == KEY_SPACE,
		"reset did not restore the default shoot binding")
	_expect(_first_key("reload") == KEY_F,
		"reset did not restore the default reload binding")
	if menu:
		# A stock binding must render its key, not the "-" placeholder.
		_expect(menu._key_name("reload") == OS.get_keycode_string(KEY_F),
			"options screen shows no key for a default binding")
		menu.queue_free()

	# Put the stock bindings back first, then replay the player's overrides, so a
	# test rebind cannot leak into the InputMap when no override was saved.
	Options.reset_keybinds()
	Options.keybinds = saved
	Options.apply_keybinds()
	Options.save_to_disk()


## First keyboard code bound to an action (physical first, like the defaults).
func _first_key(action: String) -> int:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
	return 0

