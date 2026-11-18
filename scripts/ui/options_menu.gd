extends PanelContainer
## Options screen: gameplay, controls, accessibility and audio. Every setting
## is saved to user://options.cfg. Navigable with mouse, keyboard or gamepad.

signal closed

var _rows: VBoxContainer
var _capturing_action := ""
var _capture_button: Button = null
var _key_buttons: Dictionary = {}


func _ready() -> void:
	_build()


## Rebuilds the whole panel so a language change applies to every label.
func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_key_buttons.clear()
	_capturing_action = ""
	_capture_button = null
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.12, 0.17, 0.97)
	add_theme_stylebox_override("panel", bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	margin.add_child(outer)

	var title := Label.new()
	title.text = Loc.t("OPTIONS")
	title.add_theme_font_size_override("font_size", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(title)

	# The settings list is taller than a 900 px window, so it scrolls; RETOUR
	# stays outside the scroll and is always reachable.
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.custom_minimum_size = Vector2(620, 0)
	center.add_child(column)

	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 8)
	column.add_child(_rows)

	var language := Button.new()
	language.text = Loc.t("Langue : %s") % Loc.t(Loc.language_name())
	language.custom_minimum_size = Vector2(0, 36)
	language.pressed.connect(_cycle_language)
	_rows.add_child(language)

	_section("JEU")
	_slider("Difficulté (0 facile → 2 difficile)", 0, 2, 1, Options.difficulty,
		func(v): Options.difficulty = int(v))
	_slider("Assistance de visée", 0, 2, 1, Options.aim_assist,
		func(v): Options.aim_assist = int(v))

	_section("MANETTE")
	_slider("Sensibilité sticks", 0.2, 3.0, 0.05, Options.gamepad_sensitivity,
		func(v): Options.gamepad_sensitivity = v)
	_slider("Zone morte", 0.0, 0.6, 0.02, Options.gamepad_deadzone,
		func(v): Options.gamepad_deadzone = v)
	_slider("Vibration", 0.0, 1.0, 0.05, Options.gamepad_vibration,
		func(v): Options.gamepad_vibration = v)
	var pad_status := Label.new()
	pad_status.text = Loc.t("Manette détectée : %s") % Loc.t("oui" if GameState.has_gamepad() else "non")
	pad_status.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	_rows.add_child(pad_status)

	_section("SOURIS ET ÉCRAN")
	_slider("Sensibilité souris", 0.2, 3.0, 0.05, Options.mouse_sensitivity,
		func(v): Options.mouse_sensitivity = v)
	_slider("Taille du réticule", 0.5, 2.0, 0.05, Options.crosshair_scale,
		func(v): Options.crosshair_scale = v)
	_slider("Secousses caméra", 0.0, 1.5, 0.05, Options.screen_shake,
		func(v): Options.screen_shake = v)
	_slider("Flou de mouvement", 0.0, 1.0, 0.05, Options.motion_blur,
		func(v): Options.motion_blur = v)
	_slider("Effet post-FX (vignette + grain)", 0.0, 1.0, 0.05, Options.post_fx,
		func(v): Options.post_fx = v)
	_check("Inverser l'axe vertical", Options.invert_y, func(v): Options.invert_y = v)
	_check("Sous-titres", Options.subtitles, func(v): Options.subtitles = v)

	_section("MISE EN SCÈNE")
	_slider("Météo (0 clair, 1 pluie, 2 orage, 3 brouillard)", 0, 3, 1, Options.weather,
			func(v): Options.weather = int(v))
	_check("Météo dynamique", Options.weather_dynamic, func(v): Options.weather_dynamic = v)
	_check("Ralenti (replay)", Options.replay_enabled, func(v): Options.replay_enabled = v)

	_section("CONTRÔLES (clavier)")
	var key_actions := [
		{"action": "move_forward", "label": "Avancer"},
		{"action": "move_back", "label": "Reculer"},
		{"action": "move_left", "label": "Gauche"},
		{"action": "move_right", "label": "Droite"},
		{"action": "shoot", "label": "Tirer"},
		{"action": "jump", "label": "Sauter"},
		{"action": "cover", "label": "Couvert"},
		{"action": "interact", "label": "Interagir"},
		{"action": "pause", "label": "Pause"},
		{"action": "weather", "label": "Météo"},
		{"action": "replay", "label": "Ralenti"},
	]
	for entry in key_actions:
		var action: String = entry["action"]
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = Loc.t(entry["label"])
		lbl.custom_minimum_size = Vector2(320, 0)
		row.add_child(lbl)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(180, 0)
		btn.text = _key_name(action)
		btn.pressed.connect(func(): _start_capture(action, btn))
		row.add_child(btn)
		_key_buttons[action] = btn
		_rows.add_child(row)
	var reset := Button.new()
	reset.text = Loc.t("Réinitialiser les touches")
	reset.custom_minimum_size = Vector2(0, 36)
	reset.pressed.connect(_reset_keys)
	_rows.add_child(reset)

	_section("AUDIO")
	_slider("Volume général", 0.0, 1.0, 0.05, Options.master_volume,
		func(v): Options.master_volume = v)
	_slider("Musique", 0.0, 1.0, 0.05, Options.music_volume,
		func(v): Options.music_volume = v)
	_slider("Effets", 0.0, 1.0, 0.05, Options.sfx_volume,
		func(v): Options.sfx_volume = v)

	var close := Button.new()
	close.text = Loc.t("RETOUR")
	close.custom_minimum_size = Vector2(0, 44)
	close.pressed.connect(_close)
	outer.add_child(close)
	close.grab_focus()


func _section(text: String) -> void:
	var sep := HSeparator.new()
	_rows.add_child(sep)
	var label := Label.new()
	label.text = Loc.t(text)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 0.92, 0.6))
	_rows.add_child(label)


func _slider(label_text: String, lo: float, hi: float, step: float, value: float, setter: Callable) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = Loc.t(label_text)
	label.custom_minimum_size = Vector2(320, 0)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = lo
	slider.max_value = hi
	slider.step = step
	slider.value = value
	slider.custom_minimum_size = Vector2(240, 0)
	var readout := Label.new()
	readout.text = _format(slider.value)
	readout.custom_minimum_size = Vector2(56, 0)
	slider.value_changed.connect(func(v):
		readout.text = _format(v)
		setter.call(v)
		Options.save_to_disk())
	row.add_child(slider)
	row.add_child(readout)
	_rows.add_child(row)


func _check(label_text: String, value: bool, setter: Callable) -> void:
	var check := CheckButton.new()
	check.text = Loc.t(label_text)
	check.button_pressed = value
	check.toggled.connect(func(v):
		setter.call(v)
		Options.save_to_disk())
	_rows.add_child(check)


func _format(v: float) -> String:
	if absf(v - roundf(v)) < 0.001:
		return str(int(roundf(v)))
	return "%.2f" % v


func _key_name(action: String) -> String:
	var keycode := 0
	if Options.keybinds.has(action):
		keycode = int(Options.keybinds[action])
	else:
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				# The stock bindings use physical keycodes (layout independent);
				# reading only `keycode` made every default show "-".
				keycode = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
				break
	if keycode == 0:
		return "-"
	return OS.get_keycode_string(keycode)


func _start_capture(action: String, button: Button) -> void:
	_capturing_action = action
	_capture_button = button
	button.text = Loc.t("Appuyez sur une touche...")


func _reset_keys() -> void:
	Options.reset_keybinds()
	for action in _key_buttons:
		_key_buttons[action].text = _key_name(action)


func _input(event: InputEvent) -> void:
	if _capturing_action == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_capture_button.text = _key_name(_capturing_action)
		else:
			var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			Options.rebind_key(_capturing_action, code)
			_capture_button.text = OS.get_keycode_string(code)
		_capturing_action = ""
		_capture_button = null
		get_viewport().set_input_as_handled()


func _cycle_language() -> void:
	Loc.cycle()
	_build()


func _close() -> void:
	Options.save_to_disk()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
