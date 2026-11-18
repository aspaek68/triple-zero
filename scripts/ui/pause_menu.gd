class_name PauseMenu
extends CanvasLayer
## In-game pause overlay shared by the three acts. It owns the pause state, so
## a mode only has to call `open()` when its pause action fires. The overlay
## runs with PROCESS_MODE_ALWAYS, which keeps its buttons alive while the rest
## of the tree is frozen, and lives on its own canvas layer above the HUD (a
## plain Control under the 3D root would draw underneath it). Resume, options,
## restart, main menu and quit all work with mouse, keyboard and gamepad.

var _open := false
var _root: Control
var _box: PanelContainer
var _panel: VBoxContainer
var _options: Node = null
var _options_closing := false
var _saved_mouse := Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func is_open() -> bool:
	return _open


## Freezes the act and shows the overlay. Records the mouse mode so closing
## restores exactly what the act was using (captured in the shooters, visible
## in the driving act).
func open() -> void:
	if _open or _options != null:
		return
	_open = true
	_saved_mouse = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	_box.visible = true
	get_tree().paused = true
	_focus_first()


## Unfreezes the act and hides the overlay.
func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	_box.visible = false
	get_tree().paused = false
	Input.mouse_mode = _saved_mouse


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_options = null
	# `_options_closing` is deliberately not touched here: `_on_options_closed`
	# sets it *before* rebuilding the panel, and clearing it in `_build()` would
	# let the same Escape press close the pause menu too.

	_root = Control.new()
	_root.name = "PauseRoot"
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.05, 0.72)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	_root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_box = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.14, 0.97)
	style.border_color = Color(0.35, 0.45, 0.6, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 44
	style.content_margin_right = 44
	style.content_margin_top = 26
	style.content_margin_bottom = 26
	_box.add_theme_stylebox_override("panel", style)
	center.add_child(_box)

	_panel = VBoxContainer.new()
	_panel.add_theme_constant_override("separation", 10)
	_panel.custom_minimum_size = Vector2(340, 0)
	_box.add_child(_panel)

	var title := Label.new()
	title.text = Loc.t("PAUSE")
	title.add_theme_font_size_override("font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	_button("REPRENDRE", close, true)
	_button("OPTIONS", _open_options)
	_button("RECOMMENCER", _restart)
	_button("MENU PRINCIPAL", _to_menu)
	_button("QUITTER LE JEU", _quit_game)


func _button(text: String, callback: Callable, focus := false) -> Button:
	var b := Button.new()
	b.text = Loc.t(text)
	b.custom_minimum_size = Vector2(0, 44)
	b.pressed.connect(callback)
	_panel.add_child(b)
	if focus:
		b.set_meta("pause_default_focus", true)
	return b


func _focus_first() -> void:
	for child in _panel.get_children():
		if child is Button and child.has_meta("pause_default_focus"):
			child.grab_focus()
			return
	for child in _panel.get_children():
		if child is Button:
			child.grab_focus()
			return


func _open_options() -> void:
	if _options != null:
		return
	var script: GDScript = load("res://scripts/ui/options_menu.gd")
	_options = script.new()
	# The tree is paused: the options screen must ignore the freeze too.
	_options.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_options)
	_options.connect("closed", _on_options_closed)
	_box.visible = false


func _on_options_closed() -> void:
	_options = null
	_options_closing = true
	# Rebuild so a language change made in the options applies to this panel.
	_build()
	_box.visible = true
	visible = _open
	_focus_first()
	# Clear the guard once the current input event has finished propagating, so
	# the same Escape press does not also close the pause menu.
	call_deferred("_clear_options_closing")


func _clear_options_closing() -> void:
	_options_closing = false


func _restart() -> void:
	_resume_before_scene_change()
	GameState.last_act_success = true
	Score.reset()
	Progress.begin()
	GameState.show_results_on_load = false
	get_tree().reload_current_scene()


func _to_menu() -> void:
	_resume_before_scene_change()
	GameState.show_results_on_load = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _quit_game() -> void:
	_resume_before_scene_change()
	get_tree().quit()


func _resume_before_scene_change() -> void:
	_open = false
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Audio.stop_music()
	Options.stop_rumble()


func _unhandled_input(event: InputEvent) -> void:
	if not _open or _options != null or _options_closing:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
