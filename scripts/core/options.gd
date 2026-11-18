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


func load_from_disk() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	difficulty = cfg.get_value("game", "difficulty", difficulty)
	aim_assist = cfg.get_value("game", "aim_assist", aim_assist)
	crosshair_scale = cfg.get_value("game", "crosshair_scale", crosshair_scale)
	mouse_sensitivity = cfg.get_value("game", "mouse_sensitivity", mouse_sensitivity)
	gamepad_sensitivity = cfg.get_value("game", "gamepad_sensitivity", gamepad_sensitivity)
	gamepad_deadzone = cfg.get_value("game", "gamepad_deadzone", gamepad_deadzone)
	gamepad_vibration = cfg.get_value("game", "gamepad_vibration", gamepad_vibration)
	invert_y = cfg.get_value("game", "invert_y", invert_y)
	screen_shake = cfg.get_value("game", "screen_shake", screen_shake)
	motion_blur = cfg.get_value("game", "motion_blur", motion_blur)
	post_fx = cfg.get_value("game", "post_fx", post_fx)
	subtitles = cfg.get_value("game", "subtitles", subtitles)
	master_volume = cfg.get_value("audio", "master", master_volume)
	music_volume = cfg.get_value("audio", "music", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
	language = cfg.get_value("ui", "language", language)
	keybinds = cfg.get_value("controls", "keybinds", keybinds)
	_apply_deadzones()
	_apply_buses()
	apply_keybinds()


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
	for action in keybinds:
		if not InputMap.has_action(action):
			continue
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				InputMap.action_erase_event(action, ev)
		var ev := InputEventKey.new()
		ev.keycode = int(keybinds[action])
		InputMap.action_add_event(action, ev)


## Rebinds an action to a new key and persists.
func rebind_key(action: String, keycode: int) -> void:
	keybinds[action] = keycode
	apply_keybinds()
	save_to_disk()


## Clears a saved override, restoring the default binding.
func reset_keybinds() -> void:
	keybinds.clear()
	save_to_disk()
func incoming_damage_scale() -> float:
	return [0.6, 1.0, 1.5][clampi(difficulty, 0, 2)]


## Aim tolerance in pixels used by the rail shooter, per assist level.
func aim_tolerance() -> float:
	return [0.0, 24.0, 56.0][clampi(aim_assist, 0, 2)]
