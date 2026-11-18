class_name Hud
extends CanvasLayer
## Shared in-game HUD: objective banner, controls hint, live score line and
## an optional damage/status line. Control hints follow the active device.
##
## It also owns the aiming reticle: a small drawn crosshair that follows the
## viewport centre (TPS) or the mouse/pad cursor (rail shooter), kicks out on
## every shot, turns warm over a valid target and flashes a hit marker.

## Drawn crosshair. Lives in screen space so both 3D modes can share it.
class Reticle extends Control:
	var aim := Vector2.ZERO
	## When true the crosshair sticks to the viewport centre (TPS).
	var follow_center := true
	## Extra gap pushed out by recoil, decays back to zero.
	var spread := 0.0
	## Hit-marker timer (0..1).
	var flash := 0.0
	## Warm tint while a target is under the crosshair (0..1).
	var hot := 0.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		anchor_left = 0.0
		anchor_top = 0.0
		anchor_right = 1.0
		anchor_bottom = 1.0
		offset_left = 0.0
		offset_top = 0.0
		offset_right = 0.0
		offset_bottom = 0.0
		visible = false

	func _process(delta: float) -> void:
		if not visible:
			return
		if follow_center:
			aim = get_viewport_rect().size * 0.5
		flash = maxf(flash - delta * 3.2, 0.0)
		hot = maxf(hot - delta * 6.0, 0.0)
		spread = lerpf(spread, 0.0, clampf(delta * 10.0, 0.0, 1.0))
		queue_redraw()

	func _draw() -> void:
		var s: float = Options.crosshair_scale
		var gap := (7.0 + spread) * s
		var tick := 7.0 * s
		var col := Color(1, 1, 1, 0.92).lerp(Color(1.0, 0.55, 0.25), clampf(hot, 0.0, 1.0))
		var shadow := Color(0, 0, 0, 0.5)
		for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
			draw_line(aim + d * (gap + 1.5), aim + d * (gap + tick + 1.5), shadow, 3.2 * s)
			draw_line(aim + d * gap, aim + d * (gap + tick), col, 1.7 * s)
		draw_circle(aim, 1.7 * s, shadow)
		draw_circle(aim, 1.2 * s, col)
		if flash > 0.0:
			var mark := Color(1.0, 0.85, 0.3, clampf(flash, 0.0, 1.0))
			for d in [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
				var n: Vector2 = d.normalized()
				draw_line(aim + n * (10.0 * s), aim + n * (16.0 * s), mark, 2.4 * s)

var _reticle: Reticle
var _post_fx: ColorRect
var _motion_blur: ColorRect
var _title: Label
var _objective: Label
var _controls: Label
var _status: Label
var _score: Label
var _extra: Label
var _secondary: Label
var _ammo_label: Label
var _boss_root: Control
var _boss_label: Label
var _boss_bar: ProgressBar
var _refresh_accum := 0.0


func build(title: String, objective: String, keyboard_hint: String, gamepad_hint := "") -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 18)
	root.add_theme_constant_override("margin_top", 14)
	root.add_theme_constant_override("margin_right", 18)
	add_child(root)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	root.add_child(column)

	_title = _label(24, Color(1, 1, 1))
	column.add_child(_title)

	_objective = _label(16, Color(1, 0.92, 0.6))
	column.add_child(_objective)

	_controls = _label(14, Color(0.85, 0.9, 1.0))
	_controls.text = Loc.t(keyboard_hint)
	_controls.set_meta("keyboard", Loc.t(keyboard_hint))
	_controls.set_meta("gamepad", Loc.t(gamepad_hint if not gamepad_hint.is_empty() else keyboard_hint))
	column.add_child(_controls)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 0)
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	_status = _label(18, Color(1, 1, 1))
	column.add_child(_status)

	_extra = _label(14, Color(0.8, 0.85, 0.95))
	column.add_child(_extra)

	_secondary = _label(14, Color(0.75, 0.9, 1.0))
	column.add_child(_secondary)

	_score = _label(15, Color(0.7, 1.0, 0.75))
	column.add_child(_score)

	_title.text = Loc.t(title)
	_objective.text = Loc.t(objective)
	_build_reticle()
	_build_post_fx()
	_build_motion_blur()
	Score.changed.connect(_refresh)
	GameState.device_changed.connect(_refresh)
	_refresh()


## Builds the shared aiming reticle (hidden until a mode asks for it).
func _build_reticle() -> void:
	_reticle = Reticle.new()
	_reticle.name = "Reticle"
	add_child(_reticle)


## Full-screen vignette + film grain overlay (post-FX). Drawn last, on top of
## everything, and driven by `Options.post_fx` (0 = off).
func _build_post_fx() -> void:
	var back_buffer := BackBufferCopy.new()
	back_buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(back_buffer)
	_post_fx = ColorRect.new()
	_post_fx.name = "PostFx"
	_post_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_post_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_post_fx.color = Color(1, 1, 1, 1)
	var shader := load("res://shaders/vignette_grain.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("intensity", Options.post_fx)
		mat.set_shader_parameter("vignette", 0.55)
		mat.set_shader_parameter("grain", 0.12)
		_post_fx.material = mat
	add_child(_post_fx)


## Simple screen-space motion blur overlay (radial), driven by Options.motion_blur.
func _build_motion_blur() -> void:
	var back_buffer := BackBufferCopy.new()
	back_buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(back_buffer)
	_motion_blur = ColorRect.new()
	_motion_blur.name = "MotionBlur"
	_motion_blur.set_anchors_preset(Control.PRESET_FULL_RECT)
	_motion_blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_motion_blur.color = Color(1, 1, 1, 1)
	var shader := load("res://shaders/motion_blur.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("intensity", Options.motion_blur)
		_motion_blur.material = mat
	add_child(_motion_blur)


func set_reticle_visible(on: bool) -> void:
	if _reticle == null:
		return
	_reticle.visible = on
	_reticle.hot = 0.0


func reticle_visible() -> bool:
	return _reticle != null and _reticle.visible


## Puts the reticle back at the viewport centre (Acte 1).
func set_reticle_center() -> void:
	if _reticle:
		_reticle.follow_center = true


## Pins the reticle to a screen position (rail shooter) instead of the centre.
func set_reticle_position(pos: Vector2) -> void:
	if _reticle == null:
		return
	_reticle.follow_center = false
	_reticle.aim = pos


func reticle_position() -> Vector2:
	if _reticle == null or _reticle.follow_center:
		return get_viewport().get_visible_rect().size * 0.5
	return _reticle.aim


## Pushes the crosshair apart for a frame or two after a shot.
func reticle_kick(amount := 1.0) -> void:
	if _reticle:
		_reticle.spread = maxf(_reticle.spread, 9.0 * amount)


## Hit marker: four diagonal ticks flash around the crosshair.
func reticle_hit() -> void:
	if _reticle:
		_reticle.flash = 1.0


## Warm tint while something shootable sits under the crosshair.
func set_reticle_hot(on: bool) -> void:
	if _reticle:
		_reticle.hot = 1.0 if on else 0.0


func set_title(text: String) -> void:
	if _title:
		_title.text = Loc.t(text)


func set_objective(text: String) -> void:
	if _objective:
		_objective.text = Loc.t(text)


func set_status(text: String) -> void:
	if _status:
		_status.text = Loc.t(text)


## A secondary line (weather, replay status) shown under the main status.
func set_extra(text: String) -> void:
	if _extra:
		_extra.text = Loc.t(text)


## Current secondary line (used by the headless checks).
func extra_text() -> String:
	return _extra.text if _extra else ""


## Bottom-right magazine counter, built on first use.
func set_ammo(current: int, maximum: int) -> void:
	if _ammo_label == null:
		_ammo_label = _label(20, Color(0.95, 0.95, 0.9))
		_ammo_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		_ammo_label.offset_left = -300.0
		_ammo_label.offset_top = -52.0
		_ammo_label.offset_right = -24.0
		_ammo_label.offset_bottom = -20.0
		_ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		add_child(_ammo_label)
	_ammo_label.text = Loc.t("MUNITIONS %d / %d") % [current, maximum]
	_ammo_label.add_theme_color_override("font_color",
		Color(0.95, 0.42, 0.36) if current == 0 else Color(0.95, 0.95, 0.9))


func set_secondary_objectives(civilians: int, equipment: int, comms: int) -> void:
	if not _secondary:
		return
	var parts: Array = []
	if civilians > 0:
		parts.append(Loc.t("%d civil(s) retrouvé(s)") % civilians)
	if equipment > 0:
		parts.append(Loc.t("%d équipement(s) récupéré(s)") % equipment)
	if comms > 0:
		parts.append(Loc.t("%d comm(s) rétabli(s)") % comms)
	var text := "" if parts.is_empty() else Loc.t("Secondaires : %s") % " • ".join(parts)
	if _secondary.text != text:
		_secondary.text = text


# ---------------------------------------------------------------- boss bar

## Top-centre boss bar, built on first use. `frac` is 0..1.
func set_boss_health(title: String, frac: float) -> void:
	if _boss_root == null:
		_build_boss_bar()
	if _boss_root == null:
		return
	_boss_root.visible = true
	if _boss_label:
		_boss_label.text = Loc.t(title)
	if _boss_bar:
		_boss_bar.value = clampf(frac, 0.0, 1.0)


func hide_boss() -> void:
	if _boss_root:
		_boss_root.visible = false


func _build_boss_bar() -> void:
	_boss_root = Control.new()
	_boss_root.name = "BossBar"
	_boss_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_boss_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_boss_root)

	var column := VBoxContainer.new()
	column.anchor_left = 0.5
	column.anchor_right = 0.5
	column.anchor_top = 0.0
	column.anchor_bottom = 0.0
	column.offset_left = -260.0
	column.offset_right = 260.0
	column.offset_top = 20.0
	column.offset_bottom = 72.0
	column.add_theme_constant_override("separation", 4)
	_boss_root.add_child(column)

	_boss_label = _label(19, Color(1.0, 0.72, 0.62))
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_boss_label)

	_boss_bar = ProgressBar.new()
	_boss_bar.custom_minimum_size = Vector2(520, 16)
	_boss_bar.show_percentage = false
	_boss_bar.max_value = 1.0
	_boss_bar.step = 0.0
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.03, 0.03, 0.75)
	bg.border_color = Color(0.9, 0.35, 0.25, 0.8)
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.78, 0.16, 0.12)
	fill.set_corner_radius_all(3)
	_boss_bar.add_theme_stylebox_override("background", bg)
	_boss_bar.add_theme_stylebox_override("fill", fill)
	column.add_child(_boss_bar)
	_boss_root.visible = false


func _process(delta: float) -> void:
	if not Progress.is_active():
		return
	_refresh_accum += delta
	if _refresh_accum >= 0.2:
		_refresh_accum = 0.0
		_refresh()
	if _post_fx and _post_fx.material:
		(_post_fx.material as ShaderMaterial).set_shader_parameter("intensity", Options.post_fx)
	if _motion_blur and _motion_blur.material:
		(_motion_blur.material as ShaderMaterial).set_shader_parameter("intensity", Options.motion_blur)


## Refreshes the dynamic HUD texts. `device_changed` emits the new device name,
## while `Score.changed` emits nothing, so the argument is optional.
func _refresh(_device: String = "") -> void:
	if _controls:
		var device: String = GameState.last_device
		_controls.text = _controls.get_meta("gamepad") if device == "gamepad" else _controls.get_meta("keyboard")
	if _score:
		var extra := ""
		if GameState.ng_plus:
			extra += " • NG+"
		if Progress.is_active():
			var ch: Dictionary = Progress.challenge()
			extra += Loc.t(" • Défi : %s") % Loc.t(ch["name"])
			if ch["id"] == "time":
				extra += Loc.t(" (%d s)") % int(maxf(Progress.time_left(), 0.0))
		_score.text = Loc.t("Score %d • Précision %d%% • Rang %s%s") % [
			Score.total(), int(Score.accuracy_ratio() * 100.0), Score.rank(), extra
		]


func _label(size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 4)
	return l
