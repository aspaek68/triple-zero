extends Control
## Main menu: pick one of the three acts, open options, or view results.
## Fully navigable with a gamepad (D-pad/stick + A) or keyboard.

var _showing_results := false
var _results: VBoxContainer


func _ready() -> void:
	GameState.parse_cli()
	if not GameState.cli_consumed and OS.get_cmdline_user_args().size() > 0:
		GameState.cli_consumed = true
		_launch.call_deferred(GameState.mode)
		return
	if GameState.show_results_on_load:
		GameState.show_results_on_load = false
		_showing_results = true
	_build()


func _build() -> void:
	for c in get_children():
		c.queue_free()

	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.11, 0.16)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# A scroll container keeps every entry reachable on small windows and after
	# the results panel is added; focus follows the gamepad and scrolls to it.
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	column.custom_minimum_size = Vector2(560, 0)
	center.add_child(column)

	var title := Label.new()
	title.text = "TRIPLE ZERO"
	title.add_theme_font_size_override("font_size", 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = Loc.t("Trois actes. Trois façons de jouer. — Hommage au jeu d'action 90s")
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)

	var pad_hint := Label.new()
	pad_hint.text = Loc.t("Manette : D-pad/stick naviguer • A valider • B retour") if GameState.has_gamepad() else Loc.t("Clavier : flèches naviguer • Entrée valider")
	pad_hint.add_theme_font_size_override("font_size", 13)
	pad_hint.add_theme_color_override("font_color", Color(0.55, 0.62, 0.75))
	pad_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(pad_hint)

	if _showing_results:
		column.add_child(_results_panel())

	column.add_child(HSeparator.new())

	for m in [GameState.Mode.TPS, GameState.Mode.RAIL, GameState.Mode.DRIVE]:
		var info: Dictionary = GameState.info(m)
		column.add_child(_mode_button(info["name"], info["blurb"], m))

	column.add_child(_modifier_row())

	var editor := Button.new()
	editor.text = Loc.t("ÉDITEUR DE NIVEAU (acte 3)")
	editor.custom_minimum_size = Vector2(0, 48)
	editor.pressed.connect(_open_editor)
	column.add_child(editor)

	var options := Button.new()
	options.text = Loc.t("OPTIONS")
	options.custom_minimum_size = Vector2(0, 48)
	options.pressed.connect(_open_options)
	column.add_child(options)

	var quit := Button.new()
	quit.text = Loc.t("QUITTER LE JEU")
	quit.custom_minimum_size = Vector2(0, 44)
	quit.pressed.connect(_quit_game)
	column.add_child(quit)

	# Give the first button focus so the gamepad can drive the menu right away;
	# after a run, the retry button is the most likely next action.
	var focus_target: Button = null
	if _showing_results:
		focus_target = column.find_child("NextActButton", true, false) as Button
		if focus_target == null:
			focus_target = column.find_child("RetryButton", true, false) as Button
	if focus_target == null:
		for child in column.get_children():
			if child is Button:
				focus_target = child
				break
	if focus_target:
		focus_target.grab_focus()


## Challenge picker, equipment unlocks and the New Game+ toggle.
func _modifier_row() -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var challenge := Button.new()
	challenge.name = "ChallengeButton"
	var c: Dictionary = Progress.challenge()
	challenge.text = Loc.t("Défi : %s — %s") % [Loc.t(c["name"]), Loc.t(c["desc"])]
	challenge.custom_minimum_size = Vector2(0, 40)
	challenge.pressed.connect(_cycle_challenge)
	row.add_child(challenge)

	if Progress.selected_challenge == "accuracy":
		# Warn before the run: the driving act fires no shot, so this challenge
		# is skipped there (shown as "not applicable" on the results screen).
		var note := Label.new()
		note.text = Loc.t("Tireur d'élite : actes 1 et 2 uniquement (l'acte 3 ne tire pas)")
		note.add_theme_font_size_override("font_size", 12)
		note.add_theme_color_override("font_color", Color(0.78, 0.72, 0.5))
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(note)

	var acts := Label.new()
	acts.text = Loc.t("Actes terminés : %d / 3") % Progress.cleared_acts.size()
	acts.add_theme_font_size_override("font_size", 13)
	acts.add_theme_color_override("font_color", Color(0.55, 0.62, 0.75))
	acts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(acts)

	# The editor's track is what act 3 will drive: say so, otherwise the player
	# has no way to tell a saved custom level is active.
	if LevelData.has_custom():
		var custom := Label.new()
		custom.text = Loc.t("Piste personnalisée active — acte 3")
		custom.add_theme_font_size_override("font_size", 13)
		custom.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
		custom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(custom)

	if Progress.ng_plus_unlocked:
		var ng := Button.new()
		ng.name = "NgPlusButton"
		ng.toggle_mode = true
		ng.button_pressed = GameState.ng_plus
		ng.text = Loc.t("NOUVELLE PARTIE+ : %s") % Loc.t("activée" if GameState.ng_plus else "désactivée")
		ng.custom_minimum_size = Vector2(0, 40)
		ng.toggled.connect(_toggle_ng_plus)
		row.add_child(ng)
	else:
		var locked := Label.new()
		locked.text = Loc.t("Nouvelle partie+ : terminez les trois actes")
		locked.add_theme_font_size_override("font_size", 13)
		locked.add_theme_color_override("font_color", Color(0.55, 0.62, 0.75))
		locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(locked)

	## Equipment status: clearing an act earns its first perk, the second one
	## is the New Game+ reward. Shown as read-only rows so progression stays
	## earned instead of being unlocked from the menu.
	var equip_row := VBoxContainer.new()
	equip_row.add_theme_constant_override("separation", 4)
	var names := [
		Loc.t(GameState.info(GameState.Mode.TPS)["short"]),
		Loc.t(GameState.info(GameState.Mode.RAIL)["short"]),
		Loc.t(GameState.info(GameState.Mode.DRIVE)["short"]),
	]
	for mode in 3:
		for slot in Progress.EQUIP_SLOTS:
			var state := Loc.t("débloqué") if Progress.has_equipment(mode, slot) else Loc.t("verrouillé")
			var lbl := Label.new()
			lbl.text = Loc.t("Équipement %s : %s — %s") % [
				"%s %d" % [names[mode], slot + 1], state,
				Loc.t(Progress.equipment_description(mode, slot))]
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color",
				Color(0.6, 0.85, 0.65) if Progress.has_equipment(mode, slot)
				else Color(0.55, 0.6, 0.7))
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			equip_row.add_child(lbl)
	row.add_child(equip_row)

	var unlock_hint := Label.new()
	unlock_hint.text = Loc.t("Débloqué en terminant l'acte — 2e emplacement en Nouvelle Partie+")
	unlock_hint.add_theme_font_size_override("font_size", 11)
	unlock_hint.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6))
	unlock_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(unlock_hint)

	return row


func _cycle_challenge() -> void:
	var ids: Array = []
	for entry in Progress.CHALLENGES:
		ids.append(entry["id"])
	var idx := ids.find(Progress.selected_challenge)
	Progress.select_challenge(ids[(idx + 1) % ids.size()])
	_build()


func _toggle_ng_plus(on: bool) -> void:
	Progress.set_ng_plus(on)
	_build()


func _mode_button(name: String, blurb: String, mode: int) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [Loc.t(name), Loc.t(blurb)]
	b.custom_minimum_size = Vector2(0, 64)
	b.alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.pressed.connect(func(): _launch(mode))
	return b


func _results_panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 6)

	var header := Label.new()
	header.text = Loc.t("RÉSULTATS")
	header.add_theme_font_size_override("font_size", 22)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(header)

	var outcome := Label.new()
	outcome.text = Loc.t("ACTE RÉUSSI" if GameState.last_act_success else "ACTE ÉCHOUÉ")
	outcome.add_theme_font_size_override("font_size", 18)
	outcome.add_theme_color_override("font_color",
		Color(0.5, 0.95, 0.6) if GameState.last_act_success else Color(1.0, 0.5, 0.45))
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(outcome)

	var lines := Label.new()
	if GameState.last_act_success:
		var rows: Array = [Loc.t("Score total : %d") % Score.total()]
		# The driving act has no shooting: showing "Accuracy: 0%" there would be
		# meaningless, so the line only appears when shots were actually fired.
		if Score.shots_fired > 0:
			rows.append(Loc.t("Précision : %d%%") % int(Score.accuracy_ratio() * 100.0))
		rows.append(Loc.t("Civils sauvés : %d   perdus : %d") % [
			Score.civilians_saved, Score.civilians_lost])
		rows.append(Loc.t("Matériel récupéré : %d   comms rétablies : %d") % [
			Score.equipment_recovered, Score.comm_restored])
		rows.append(Loc.t("Itinéraires alternatifs : %d") % Score.alternate_paths)
		rows.append(Loc.t("Rang : %s") % Score.rank())
		lines.text = "\n".join(rows)
	else:
		# A failed run posts no score and no rank; showing them contradicted
		# "ACTE ÉCHOUÉ". State the real reason instead.
		var reason: String = GameState.last_act_reason
		if reason == "":
			lines.text = Loc.t("Aucun score enregistré")
		else:
			lines.text = Loc.t("Aucun score enregistré — %s") % Loc.t(reason)
		lines.add_theme_color_override("font_color", Color(1.0, 0.72, 0.55))
	lines.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(lines)

	var best := Progress.best_for(GameState.mode)
	if GameState.last_act_success and best["score"] > 0:
		var best_label := Label.new()
		best_label.text = Loc.t("Meilleur : %d (%s)%s") % [best["score"], best["rank"],
			Loc.t("  •  NOUVEAU RECORD !") if Progress.last_record else ""]
		best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		best_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
		panel.add_child(best_label)

	# A free run has no challenge verdict; the other challenges add the reason
	# they failed, which the results screen used to hide.
	if Progress.selected_challenge != "none":
		var challenge := Label.new()
		if Progress.is_skipped():
			# The driving act fires no shots: "Tireur d'élite" has no verdict
			# there, so say it is not applicable instead of a fake pass/fail.
			challenge.text = Loc.t("Défi « %s » : non applicable (conduite)") % \
				Loc.t(Progress.last_name)
		else:
			var verdict := Loc.t("réussi") if Progress.last_success else Loc.t("échoué")
			var reason := "" if Progress.last_reason == "" else " — " + Loc.t(Progress.last_reason)
			challenge.text = Loc.t("Défi « %s » : %s%s") % [
				Loc.t(Progress.last_name), verdict, reason
			]
		challenge.add_theme_font_size_override("font_size", 15)
		challenge.add_theme_color_override("font_color", Color(0.75, 0.9, 1.0))
		challenge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(challenge)

	var acts := Label.new()
	var suffix := Loc.t("  •  Nouvelle partie+ débloquée") if Progress.ng_plus_unlocked else ""
	acts.text = Loc.t("Actes terminés : %d / 3%s\nChoisissez un acte pour rejouer") % [
		Progress.cleared_acts.size(), suffix
	]
	acts.add_theme_font_size_override("font_size", 13)
	acts.add_theme_color_override("font_color", Color(0.55, 0.62, 0.75))
	acts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(acts)

	# A cleared act offers the next one directly: the three acts form a run, so
	# the player should not have to close the results and pick it by hand.
	if GameState.last_act_success and GameState.mode < GameState.Mode.DRIVE:
		var next := Button.new()
		next.name = "NextActButton"
		next.text = Loc.t("ACTE SUIVANT")
		next.custom_minimum_size = Vector2(0, 44)
		next.pressed.connect(func(): _launch(int(GameState.mode) + 1))
		panel.add_child(next)

	var retry := Button.new()
	retry.name = "RetryButton"
	retry.text = Loc.t("REJOUER L'ACTE")
	retry.custom_minimum_size = Vector2(0, 44)
	retry.pressed.connect(func(): _launch(GameState.mode))
	panel.add_child(retry)

	var hide := Button.new()
	hide.text = Loc.t("FERMER LES RÉSULTATS")
	hide.custom_minimum_size = Vector2(0, 34)
	hide.pressed.connect(func():
		_showing_results = false
		_build())
	panel.add_child(hide)

	return panel


func _launch(mode: int) -> void:
	GameState.mode = mode as GameState.Mode
	GameState.last_act_success = true
	GameState.last_act_reason = ""
	Score.reset()
	Progress.begin()
	Audio.stop_music()
	get_tree().change_scene_to_file(GameState.info(mode)["scene"])


func _open_editor() -> void:
	var script: GDScript = load("res://scripts/ui/level_editor.gd")
	var editor: Node = script.new()
	editor.connect("closed", _build)
	add_child(editor)


func _open_options() -> void:
	var script: GDScript = load("res://scripts/ui/options_menu.gd")
	var menu: Node = script.new()
	menu.connect("closed", _build)
	add_child(menu)


func _quit_game() -> void:
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _showing_results:
		_showing_results = false
		_build()
