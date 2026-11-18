class_name Replay
extends Node
## Records the last few seconds of action and plays it back as a slow-motion
## highlight. A mode calls `reset()` at start, `track()` for each actor it
## wants filmed, then `sample()` every physics frame. When the mode calls
## `play()`, the buffer is replayed as simple ghost boxes under a slowly
## orbiting camera with letterbox bars, and `finished` fires at the end.
##
## Recording is cheap (transforms only) and bounded: the buffer holds at most
## `MAX_FRAMES` snapshots, so memory stays flat over a long run.

signal finished

const MAX_FRAMES := 420      # ~7 s at 60 Hz
const SAMPLE_STEP := 2       # record every other physics frame
const SLOWMO := 0.35         # playback runs at 35 % speed

var _actors: Array = []       # [{node, color, size}]
var _frames: Array = []       # ring of [Transform3D, ...]
var _events: Array = []       # [{frame, kind, pos}]
var _columns := 0            # widest snapshot recorded so far
var _last: Array = []       # last valid transform per actor
var _tick := 0
var _playing := false
## Input is armed one idle frame after `play()`. The key press that starts the
## replay is still travelling through the input phases, and this node runs with
## PROCESS_MODE_ALWAYS (the act is paused): it used to receive that very event
## in `_unhandled_input` and skip the playback on its first frame.
var _input_armed := false
var _play_head := 0.0
var _ghosts: Array = []
var _camera: Camera3D
var _overlay: CanvasLayer
var _caption: Label


func _ready() -> void:
	# Playback runs while the act is frozen, so it must ignore the pause.
	process_mode = Node.PROCESS_MODE_ALWAYS


func reset() -> void:
	_actors.clear()
	_frames.clear()
	_events.clear()
	_last.clear()
	_columns = 0
	_tick = 0
	_playing = false


## Registers a node to film, with the colour of its ghost and a size hint.
func track(node: Node3D, color: Color, size := Vector3(1, 1.8, 1)) -> void:
	_actors.append({"node": node, "color": color, "size": size})


## Records one snapshot. Call from `_physics_process`; sampling is throttled
## internally so the buffer lasts a useful stretch of time.
func sample() -> void:
	if _playing or _actors.is_empty():
		return
	_tick += 1
	if _tick % SAMPLE_STEP != 0:
		return
	var row: Array = []
	for k in _actors.size():
		var actor: Dictionary = _actors[k]
		var node = actor["node"]
		if is_instance_valid(node):
			_last.resize(maxi(_last.size(), k + 1))
			_last[k] = (node as Node3D).global_transform
		row.append(_last[k] if k < _last.size() else Transform3D())
	_columns = maxi(_columns, row.size())
	_frames.append(row)
	if _frames.size() > MAX_FRAMES:
		_frames.pop_front()
		for e in _events:
			e["frame"] -= 1


## Marks a moment (shot, explosion, crash) so it can flash during playback.
func event(kind: String, pos: Vector3) -> void:
	if _playing:
		return
	_events.append({"frame": _frames.size(), "kind": kind, "pos": pos})
	while _events.size() > 64:
		_events.pop_front()


## True when there is enough footage to be worth playing.
func has_footage() -> bool:
	return _frames.size() > 24


## Plays the buffer back. Returns false (and emits nothing) when there is
## nothing recorded.
func play(parent: Node) -> bool:
	if _playing or not has_footage():
		return false
	_playing = true
	_input_armed = false
	set_process_unhandled_input(false)
	call_deferred("_arm_input")
	_play_head = 0.0
	_build_overlay(parent)
	_build_ghosts(parent)
	return true


func _arm_input() -> void:
	_input_armed = true
	if _playing:
		set_process_unhandled_input(true)


## Playback owns the screen while the act is frozen; let the player skip it.
func _unhandled_input(event: InputEvent) -> void:
	if not _playing or not _input_armed:
		return
	if event.is_action_pressed("replay") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()


func _process(delta: float) -> void:
	if not _playing:
		return
	_play_head += delta / (1.0 / 60.0) * SLOWMO
	var i := int(_play_head)
	if i >= _frames.size() - 1:
		_finish()
		return
	var t := _play_head - float(i)
	_pose(i, t)
	_strike_events(i)


func _pose(i: int, t: float) -> void:
	var a: Array = _frames[i]
	var b: Array = _frames[i + 1]
	for k in _ghosts.size():
		var ghost: MeshInstance3D = _ghosts[k]
		if k >= a.size() or k >= b.size():
			ghost.visible = false
			continue
		ghost.visible = true
		var ta: Transform3D = a[k]
		var tb: Transform3D = b[k]
		ghost.global_transform = ta.interpolate_with(tb, t)
	_update_camera()


func _update_camera() -> void:
	if _camera == null or _ghosts.is_empty():
		return
	var centre := Vector3.ZERO
	var n := 0
	for g in _ghosts:
		if (g as Node3D).visible:
			centre += (g as Node3D).global_position
			n += 1
	if n > 0:
		centre /= float(n)
	var ang := _play_head * 0.012
	var radius := 16.0
	_camera.global_position = centre + Vector3(sin(ang) * radius, 8.0, cos(ang) * radius)
	_camera.look_at(centre + Vector3(0, 1.0, 0), Vector3.UP)


func _strike_events(i: int) -> void:
	for e in _events:
		if e["frame"] == i and e["kind"] == "explosion":
			_flash(e["pos"])


func _build_ghosts(parent: Node) -> void:
	_ghosts.clear()
	for k in _columns:
		var a: Dictionary = _actors[k] if k < _actors.size() else _actors[0]
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = a["size"]
		mi.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(a["color"].r, a["color"].g, a["color"].b, 0.75)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = a["color"]
		mat.emission_energy_multiplier = 0.6
		mi.material_override = mat
		parent.add_child(mi)
		_ghosts.append(mi)
	_camera = Camera3D.new()
	_camera.fov = 66.0
	parent.add_child(_camera)
	_camera.make_current()


func _build_overlay(parent: Node) -> void:
	_overlay = CanvasLayer.new()
	_overlay.layer = 6
	parent.add_child(_overlay)
	for preset in [Control.PRESET_TOP_WIDE, Control.PRESET_BOTTOM_WIDE]:
		var bar := ColorRect.new()
		bar.color = Color(0, 0, 0, 0.85)
		bar.set_anchors_preset(preset)
		bar.custom_minimum_size = Vector2(0, 90)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_overlay.add_child(bar)
	_caption = Label.new()
	_caption.text = Loc.t("● RALENTI — R pour passer") if Options.subtitles else Loc.t("RALENTI")
	_caption.add_theme_font_size_override("font_size", 26)
	_caption.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3))
	_caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_caption.add_theme_constant_override("outline_size", 5)
	_caption.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_caption.position = Vector2(30, 26)
	_overlay.add_child(_caption)


func _flash(pos: Vector3) -> void:
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 1.5, 0)
	light.light_color = Color(1.0, 0.6, 0.2)
	light.light_energy = 8.0
	light.omni_range = 16.0
	add_child(light)
	var tw := light.create_tween()
	tw.tween_property(light, "light_energy", 0.0, 0.3)
	tw.tween_callback(light.queue_free)


func _finish() -> void:
	if not _playing:
		return
	_playing = false
	for g in _ghosts:
		(g as Node).queue_free()
	_ghosts.clear()
	if _camera:
		_camera.queue_free()
		_camera = null
	if _overlay:
		_overlay.queue_free()
		_overlay = null
	finished.emit()
