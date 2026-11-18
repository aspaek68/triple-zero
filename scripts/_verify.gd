extends Node
## Headless functional check: autoloads, actors, HUD, scoring and the
## replayable-challenge / equipment systems. Prints "VERIFY RESULT: OK" and
## exits 0, or lists every failure and exits 1.

var _failures: Array = []


func _ready() -> void:
	_check_autoloads()
	_check_localisation()
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
	_check_equipment()

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
	_expect(Loc.t("MUNITIONS %d / %d") % [12, 30] == "AMMO 12 / 30",
		"EN ammo template not translated")
	_expect(Loc.t("Zone 2 - 5 hostiles") == "Zone 2 - 5 hostiles",
		"EN dynamic template not matched")
	_expect(Loc.t("INTÉGRITÉ 75%") == "INTEGRITY 75%",
		"EN percent template not matched")
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


func _check_actors() -> void:
	var character := Character.make(Color(0.3, 0.4, 0.3), Color(0.1, 0.1, 0.12))
	_expect(character != null, "Character.make returned null")
	if character:
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
		enemy.free()


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
	Loc.set_language(saved_lang)
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
	var script: GDScript = load("res://scripts/ui/level_editor.gd")
	_expect(script != null, "level editor script does not load")
	if script == null:
		return
	var editor: Control = script.new()
	add_child(editor)
	var titled := false
	for node in editor.find_children("*", "Label", true, false):
		if (node as Label).text == Loc.t("ÉDITEUR DE NIVEAU"):
			titled = true
	_expect(titled, "level editor title missing or untranslated")
	_expect(editor._status != null and editor._status.text != "",
		"level editor status line is empty")
	editor.queue_free()


## The results screen offers the next act after a clear (the three acts form a
## run) and the retry button after a failure, never the next act.
func _check_results_screen() -> void:
	var script: GDScript = load("res://scripts/ui/menu.gd")
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
	Score.reset()

	Progress.cleared_acts = [0, 1, 2]
	_expect(Progress.all_acts_cleared(), "all_acts_cleared should be true with 3 acts")
	_expect(Progress.CHALLENGES.size() >= 4, "challenge list is too short")

	Progress.selected_challenge = saved_challenge
	Progress.cleared_acts = saved_acts


func _check_equipment() -> void:
	var saved_equip: int = Progress.equipment_unlocked

	Progress.equipment_unlocked = 0
	_expect(not Progress.has_equipment(1, 1), "equipment bit should start clear")
	Progress.equipment_unlocked = 1 << (1 * Progress.EQUIP_SLOTS + 1)
	_expect(Progress.has_equipment(1, 1), "equipment bit should be set")
	_expect(not Progress.has_equipment(1, 0), "neighbouring equipment bit leaked")
	_expect(Progress.equipment_description(0, 0) != "", "TPS equipment description empty")
	_expect(Progress.equipment_description(1, 1) != "", "drive equipment description empty")
	_expect(Progress.equipment_description(2, 1) != "", "rail equipment description empty")

	Progress.equipment_unlocked = saved_equip
