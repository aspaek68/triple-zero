extends Node
## Autoload: accessibility and gameplay options, persisted to user://.

const PATH := "user://options.cfg"

enum AimAssist { NONE, LIGHT, STRONG }

var difficulty := 1          # 0 facile, 1 normal, 2 difficile
var aim_assist := AimAssist.LIGHT
var crosshair_scale := 1.0
var mouse_sensitivity := 1.0
var gamepad_sensitivity := 1.0
var gamepad_deadzone := 0.2
var gamepad_vibration := 0.7
var invert_y := false
var screen_shake := 1.0

var post_fx := 0.6
var motion_blur := 0.0
var subtitles := true
var weather := 0          # Weather.Preset: 0 clair, 1 pluie, 2 orage, 3 brouillard
var weather_dynamic := true
var replay_enabled := true
var master_volume := 0.9
var music_volume := 0.7
var sfx_volume := 0.9
## Interface language ("fr" or "en"), read by the Loc autoload.
var language := "fr"

## Per-action keyboard overrides (action name -> keycode int). Empty means
## "use the default binding declared by GameState".
var keybinds: Dictionary = {}
## Default keyboard events per action, captured before the first override is
## applied so `reset_keybinds()` can really restore them.
var _default_keys: Dictionary = {}


func load_from_disk() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		# First launch (no save yet): the defaults declared above still have to
		# reach the engine. Returning here left the stick deadzone at Godot's
		# 0.5 and the audio buses at full volume instead of the values set in
		# this file, until the player happened to open the options screen.
		_apply_deadzones()
		_apply_buses()
		apply_keybinds()
		return
	# `options.cfg` is hand-editable (and can be left half-written): every value
	# is validated, because a bad type would crash the typed assignment here and
	# take the whole game down at launch.
	difficulty = _read_int(cfg, "game", "difficulty", difficulty, 0, 2)
	aim_assist = _read_int(cfg, "game", "aim_assist", aim_assist, 0, 2)
	crosshair_scale = _read_float(cfg, "game", "crosshair_scale", crosshair_scale, 0.5, 2.0)
	mouse_sensitivity = _read_float(cfg, "game", "mouse_sensitivity", mouse_sensitivity, 0.2, 3.0)
	gamepad_sensitivity = _read_float(cfg, "game", "gamepad_sensitivity",
		gamepad_sensitivity, 0.2, 3.0)
	gamepad_deadzone = _read_float(cfg, "game", "gamepad_deadzone", gamepad_deadzone, 0.0, 0.6)
	gamepad_vibration = _read_float(cfg, "game", "gamepad_vibration",
		gamepad_vibration, 0.0, 1.0)
	invert_y = _read_bool(cfg, "game", "invert_y", invert_y)
	screen_shake = _read_float(cfg, "game", "screen_shake", screen_shake, 0.0, 1.5)
	motion_blur = _read_float(cfg, "game", "motion_blur", motion_blur, 0.0, 1.0)
	post_fx = _read_float(cfg, "game", "post_fx", post_fx, 0.0, 1.0)
	subtitles = _read_bool(cfg, "game", "subtitles", subtitles)
	weather = _read_int(cfg, "staging", "weather", weather, 0, 3)
	weather_dynamic = _read_bool(cfg, "staging", "weather_dynamic", weather_dynamic)
	replay_enabled = _read_bool(cfg, "staging", "replay_enabled", replay_enabled)
	master_volume = _read_float(cfg, "audio", "master", master_volume, 0.0, 1.0)
	music_volume = _read_float(cfg, "audio", "music", music_volume, 0.0, 1.0)
	sfx_volume = _read_float(cfg, "audio", "sfx", sfx_volume, 0.0, 1.0)
	var lang: Variant = cfg.get_value("ui", "language", language)
	# `Loc` is not loaded yet when this runs, so the codes are spelled out.
	language = lang if lang is String and lang in ["fr", "en"] else "fr"
	keybinds = _sanitize_keybinds(cfg.get_value("controls", "keybinds", keybinds))
	_apply_deadzones()
	_apply_buses()
	apply_keybinds()


func _read_int(cfg: ConfigFile, section: String, key: String, fallback: int,
		lo: int, hi: int) -> int:
	var v: Variant = cfg.get_value(section, key, fallback)
	if v is int or v is float:
		return clampi(int(v), lo, hi)
	return fallback


func _read_float(cfg: ConfigFile, section: String, key: String, fallback: float,
		lo: float, hi: float) -> float:
	var v: Variant = cfg.get_value(section, key, fallback)
	if v is int or v is float:
		return clampf(float(v), lo, hi)
	return fallback


func _read_bool(cfg: ConfigFile, section: String, key: String, fallback: bool) -> bool:
	var v: Variant = cfg.get_value(section, key, fallback)
	return v if v is bool else fallback


## Keeps only real actions bound to a non-zero keycode: `apply_keybinds()` would
## otherwise feed a string into `int()` and crash the InputMap setup.
func _sanitize_keybinds(v: Variant) -> Dictionary:
	var out := {}
	if not v is Dictionary:
		return out
	for action in v:
		var code: Variant = v[action]
		if not action is String or not (code is int or code is float):
			continue
		var key := int(code)
		if key > 0:
			out[action] = key
	return out


func save_to_disk() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "difficulty", difficulty)
	cfg.set_value("game", "aim_assist", aim_assist)
	cfg.set_value("game", "crosshair_scale", crosshair_scale)
	cfg.set_value("game", "mouse_sensitivity", mouse_sensitivity)
	cfg.set_value("game", "gamepad_sensitivity", gamepad_sensitivity)
	cfg.set_value("game", "gamepad_deadzone", gamepad_deadzone)
	cfg.set_value("game", "gamepad_vibration", gamepad_vibration)
	cfg.set_value("game", "invert_y", invert_y)
	cfg.set_value("game", "screen_shake", screen_shake)
	cfg.set_value("game", "motion_blur", motion_blur)
	cfg.set_value("game", "post_fx", post_fx)
	cfg.set_value("game", "subtitles", subtitles)
	cfg.set_value("staging", "weather", weather)
	cfg.set_value("staging", "weather_dynamic", weather_dynamic)
	cfg.set_value("staging", "replay_enabled", replay_enabled)
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("ui", "language", language)
	cfg.set_value("controls", "keybinds", keybinds)
	cfg.save(PATH)
	_apply_deadzones()
	_apply_buses()
	apply_keybinds()


## Applies the deadzone to the stick actions declared by GameState.
func _apply_deadzones() -> void:
	for action in ["move_forward", "move_back", "move_left", "move_right",
			"look_left", "look_right", "look_up", "look_down"]:
		if InputMap.has_action(action):
			InputMap.action_set_deadzone(action, gamepad_deadzone)


func _apply_buses() -> void:
	var master := AudioServer.get_bus_index("Master")
	if master >= 0:
		AudioServer.set_bus_volume_db(master, linear_to_db(clampf(master_volume, 0.0001, 1.0)))
	for bus in ["Music", "SFX"]:
		var idx := AudioServer.get_bus_index(bus)
		if idx >= 0:
			var v := music_volume if bus == "Music" else sfx_volume
			AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(v, 0.0001, 1.0)))


## Rumble helper: ignores requests when vibration is disabled.
func rumble(weak: float, strong: float, duration := 0.18) -> void:
	if gamepad_vibration <= 0.0:
		return
	Input.start_joy_vibration(0, weak * gamepad_vibration, strong * gamepad_vibration, duration)


func stop_rumble() -> void:
	Input.stop_joy_vibration(0)


## Applies saved keyboard overrides onto the InputMap.
func apply_keybinds() -> void:
	if _default_keys.is_empty():
		_snapshot_default_keys()
	for action in keybinds:
		if not InputMap.has_action(action):
			continue
		_clear_key_events(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = int(keybinds[action])
		InputMap.action_add_event(action, ev)


## Remembers the stock keyboard events (GameState declared them before this
## autoload loads). Stored as physical keycodes, like the game's defaults.
func _snapshot_default_keys() -> void:
	for action in InputMap.get_actions():
		var keys: Array = []
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				var code: int = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
				if code != 0:
					keys.append(code)
		if not keys.is_empty():
			_default_keys[action] = keys


func _clear_key_events(action: StringName) -> void:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			InputMap.action_erase_event(action, ev)


## Rebinds an action to a new key and persists.
func rebind_key(action: String, keycode: int) -> void:
	keybinds[action] = keycode
	apply_keybinds()
	save_to_disk()


## Clears the saved overrides and puts the stock bindings back.
func reset_keybinds() -> void:
	keybinds.clear()
	for action in _default_keys:
		if not InputMap.has_action(action):
			continue
		_clear_key_events(action)
		for code in _default_keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = int(code)
			InputMap.action_add_event(action, ev)
	save_to_disk()


func incoming_damage_scale() -> float:
	return [0.6, 1.0, 1.5][clampi(difficulty, 0, 2)]


## Aim tolerance in pixels used by the rail shooter, per assist level.
func aim_tolerance() -> float:
	return [0.0, 24.0, 56.0][clampi(aim_assist, 0, 2)]
