class_name Cinematic
extends CanvasLayer
## Short, skippable intro camera fly-through shown at the start of each act.
## Draws letterbox bars and a caption over a black-to-clear fade, flies a
## camera from `from` to `to` over `duration` seconds, then fades back out.
## Any input skips it. In a headless run there is no window and no input, so
## it auto-skips after a fraction of a second to keep automated checks fast.

signal finished

var _layer := ColorRect.new()
var _top := ColorRect.new()
var _bottom := ColorRect.new()
var _caption: Label
var _subtitle: Label
var _camera: Camera3D
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _look := Vector3.ZERO
var _duration := 3.0
var _elapsed := 0.0
var _skipped := false
var _done := false


func play(title: String, subtitle: String, from: Vector3, to: Vector3,
	look_at_target: Vector3, duration := 3.2) -> void:
	_from = from
	_to = to
	_look = look_at_target
	_duration = duration
	_build(title, subtitle)


func _build(title: String, subtitle: String) -> void:
	layer = 4
	_layer.color = Color(0, 0, 0, 0.0)
	_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_layer)
	
	_top.color = Color(0, 0, 0, 0.9)
	_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top.custom_minimum_size = Vector2(0, 90)
	_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_top)
	
	_bottom.color = Color(0, 0, 0, 0.9)
	_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom.custom_minimum_size = Vector2(0, 90)
	_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bottom)
	
	_caption = _label(34, Color(1, 0.95, 0.8))
	_caption.text = title
	_caption.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_caption.position = Vector2(0, 30)
	add_child(_caption)
	
	_subtitle = _label(18, Color(0.85, 0.9, 1.0))
	_subtitle.text = subtitle
	_subtitle.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_subtitle.position = Vector2(0, -60)
	add_child(_subtitle)
	
	_camera = Camera3D.new()
	_camera.fov = 62.0
	_camera.position = _from
	add_child(_camera)
	_camera.make_current()
	var auto := 0.2 if DisplayServer.get_name() == "headless" else _duration
	_duration = auto


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	var t := clampf(_elapsed / maxf(_duration, 0.001), 0.0, 1.0)
	# Fade in over the first fifth, hold, fade out over the last fifth.
	var fade := clampf(t / 0.2, 0.0, 1.0) * clampf((1.0 - t) / 0.2, 0.0, 1.0)
	_layer.color.a = 1.0 - fade
	var eased := 1.0 - pow(1.0 - t, 3.0)
	_camera.position = _from.lerp(_to, eased)
	_camera.look_at(_look, Vector3.UP)
	if _skipped or t >= 1.0:
		_finish()


## True once the cinematic has finished (or was skipped).
func is_done() -> bool:
	return _done


func _input(event: InputEvent) -> void:
	if _done:
		return
	if event.is_pressed() and not event.is_echo():
		_skipped = true


func _finish() -> void:
	if _done:
		return
	_done = true
	_layer.queue_free()
	_top.queue_free()
	_bottom.queue_free()
	_caption.queue_free()
	_subtitle.queue_free()
	_camera.queue_free()
	finished.emit()


func _label(size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 5)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
