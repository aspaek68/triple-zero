extends Node
## Autoload: current mode, shared input actions, and device detection.
## Input actions are declared in code (keyboard + mouse + gamepad), so the
## project needs no .tscn input map and works out of the box on a controller.

enum Mode { TPS, RAIL, DRIVE }

## Emitted when the active input device changes (keyboard <-> gamepad),
## so HUDs can swap their button prompts.
signal device_changed(device: String)

const MODE_INFO: Dictionary = {
	Mode.TPS: {
		"name": "ACTE 1 — TOUR",
		"short": "TPS",
		"blurb": "Infiltration et action à la troisième personne",
		"scene": "res://scenes/modes/tps.tscn",
	},
	Mode.RAIL: {
		"name": "ACTE 2 — AÉROPORT",
		"short": "Rail",
		"blurb": "Rail shooter : viser vite, épargner les civils",
		"scene": "res://scenes/modes/rail.tscn",
	},
	Mode.DRIVE: {
		"name": "ACTE 3 — VILLE",
		"short": "Conduite",
		"blurb": "Conduite arcade : poursuivre et foncer",
		"scene": "res://scenes/modes/drive.tscn",
	},
}

var mode: Mode = Mode.TPS
var show_results_on_load := false
## Whether the last finished act was actually cleared (act 3 can run out of
## time), so the results screen can say so instead of showing a bare score.
var last_act_success := true
## Why the last act failed (empty on success), shown on the results screen.
var last_act_reason := ""
var cli_consumed := false
## New Game+: tougher hostiles, tighter resources. Toggled from the menu once
## the player has finished all three acts.
var ng_plus := false
## Last device the player used, so the HUD can show the right button prompts.
var last_device := "keyboard"


func _ready() -> void:
	_ensure_input_actions()
	Options.load_from_disk()
	Input.joy_connection_changed.connect(_on_joy_changed)


func info(m: int) -> Dictionary:
	return MODE_INFO.get(m, MODE_INFO[Mode.TPS])


func has_gamepad() -> bool:
	return not Input.get_connected_joypads().is_empty()


func _on_joy_changed(_device: int, connected: bool) -> void:
	if connected:
		_set_device("gamepad")


func _set_device(device: String) -> void:
	if device == last_device:
		return
	last_device = device
	device_changed.emit(device)


## Reads `--mode=N` / `--mission=N` passed after `--` on the command line.
func parse_cli() -> void:
	for arg in OS.get_cmdline_user_args():
		var value := ""
		if arg.begins_with("--mode="):
			value = arg.get_slice("=", 1)
		elif arg.begins_with("--mission="):
			value = arg.get_slice("=", 1)
		if value.is_valid_int():
			mode = clampi(int(value) - 1, 0, 2) as Mode


## Tracks which device is active by watching incoming events.
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		_set_device("gamepad")
	elif event is InputEventJoypadMotion:
		if absf(event.axis_value) >= 0.3:
			_set_device("gamepad")
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		_set_device("keyboard")


func _ensure_input_actions() -> void:
	# Movement / driving (stick left, D-pad, WASD, arrows).
	_axis_action("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_axis_action("move_back", JOY_AXIS_LEFT_Y, 1.0)
	_axis_action("move_left", JOY_AXIS_LEFT_X, -1.0)
	_axis_action("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_keys("move_forward", [KEY_W, KEY_UP])
	_add_keys("move_back", [KEY_S, KEY_DOWN])
	_add_keys("move_left", [KEY_A, KEY_LEFT])
	_add_keys("move_right", [KEY_D, KEY_RIGHT])
	_add_buttons("move_forward", [JOY_BUTTON_DPAD_UP])
	_add_buttons("move_back", [JOY_BUTTON_DPAD_DOWN])
	_add_buttons("move_left", [JOY_BUTTON_DPAD_LEFT])
	_add_buttons("move_right", [JOY_BUTTON_DPAD_RIGHT])

	# Camera / aiming (stick right; mouse handled in each mode).
	_axis_action("look_left", JOY_AXIS_RIGHT_X, -1.0)
	_axis_action("look_right", JOY_AXIS_RIGHT_X, 1.0)
	_axis_action("look_up", JOY_AXIS_RIGHT_Y, -1.0)
	_axis_action("look_down", JOY_AXIS_RIGHT_Y, 1.0)

	# Actions: fire, jump/interact, cover/handbrake, sprint/boost.
	_add_keys("shoot", [KEY_SPACE])
	_add_mouse("shoot", MOUSE_BUTTON_LEFT)
	_add_buttons("shoot", [JOY_BUTTON_X])
	_axis_action("shoot", JOY_AXIS_TRIGGER_RIGHT, 1.0)

	_add_keys("jump", [KEY_SPACE])
	_add_buttons("jump", [JOY_BUTTON_A])
	_add_keys("interact", [KEY_E])
	_add_buttons("interact", [JOY_BUTTON_A])

	_add_keys("cover", [KEY_CTRL])
	_add_buttons("cover", [JOY_BUTTON_B])
	_add_keys("handbrake", [KEY_SPACE])
	_add_buttons("handbrake", [JOY_BUTTON_B])

	_add_keys("sprint", [KEY_SHIFT])
	_add_buttons("sprint", [JOY_BUTTON_RIGHT_SHOULDER])
	_axis_action("sprint", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_add_keys("boost", [KEY_SHIFT])
	_add_buttons("boost", [JOY_BUTTON_RIGHT_SHOULDER])
	# The drive HUD says "RT boost": keep the binding on the right trigger so
	# the prompt is true. (Sprint uses the left trigger in the on-foot acts.)
	_axis_action("boost", JOY_AXIS_TRIGGER_RIGHT, 1.0)

	_add_keys("reload", [KEY_F])
	_add_buttons("reload", [JOY_BUTTON_LEFT_SHOULDER])

	_add_keys("pause", [KEY_ESCAPE])
	_add_buttons("pause", [JOY_BUTTON_START])

	# Cinematic extras: cycle the weather, replay the last action.
	_add_keys("weather", [KEY_C])
	_add_buttons("weather", [JOY_BUTTON_Y])
	_add_keys("replay", [KEY_R])
	_add_buttons("replay", [JOY_BUTTON_BACK])

	# Menu navigation (used by the menu and options screens).
	_add_keys("ui_accept", [KEY_ENTER, KEY_KP_ENTER])
	_add_buttons("ui_accept", [JOY_BUTTON_A])
	_add_keys("ui_cancel", [KEY_ESCAPE])
	_add_buttons("ui_cancel", [JOY_BUTTON_B])
	_add_buttons("ui_up", [JOY_BUTTON_DPAD_UP])
	_add_buttons("ui_down", [JOY_BUTTON_DPAD_DOWN])
	_add_buttons("ui_left", [JOY_BUTTON_DPAD_LEFT])
	_add_buttons("ui_right", [JOY_BUTTON_DPAD_RIGHT])
	_axis_action("ui_up", JOY_AXIS_LEFT_Y, -1.0)
	_axis_action("ui_down", JOY_AXIS_LEFT_Y, 1.0)
	_axis_action("ui_left", JOY_AXIS_LEFT_X, -1.0)
	_axis_action("ui_right", JOY_AXIS_LEFT_X, 1.0)


func _ensure(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)


func _add_keys(action: StringName, keys: Array) -> void:
	_ensure(action)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)


func _add_mouse(action: StringName, button: int) -> void:
	_ensure(action)
	var event := InputEventMouseButton.new()
	event.button_index = button
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)


func _add_buttons(action: StringName, buttons: Array) -> void:
	_ensure(action)
	for b in buttons:
		var event := InputEventJoypadButton.new()
		event.button_index = b
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)


func _axis_action(action: StringName, axis: int, value: float) -> void:
	_ensure(action)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
