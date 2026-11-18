extends Control
## Level editor: lays out the drive act's track and props on a plan view.
##
## The centreline is a list of nodes you drag; props are dropped on the
## grid. Everything is saved to user://level.json through the LevelData
## autoload, and the drive act builds the custom track when one exists.

signal closed

const MARGIN := 40.0
const NODE_RADIUS := 9.0

var _tool := "node"      # "node" or "prop"
var _kind := 0
var _drag := -1
var _status: Label
var _scale := 0.4
var _origin := Vector2(80, 80)
## Short confirmation shown above the status line after a save/load/new.
var _notice := ""
var _notice_left := 0.0


func _process(delta: float) -> void:
	if _notice_left <= 0.0:
		return
	_notice_left -= delta
	if _notice_left <= 0.0:
		_notice = ""
		_refresh()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)
	if LevelData.load_level() == false:
		LevelData.new_level()
	_build_ui()
	_refresh()


## The plan view must not re-fit while a node is being dragged: recomputing the
## projection every frame moved the whole map under the cursor (the node no
## longer followed the mouse). `_draw()` only draws with the stored transform.
func _on_resized() -> void:
	_fit()
	queue_redraw()


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	panel.custom_minimum_size = Vector2(250, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.17, 0.92)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	var title := Label.new()
	title.text = Loc.t("ÉDITEUR DE NIVEAU")
	title.add_theme_font_size_override("font_size", 20)
	col.add_child(title)
	_status = Label.new()
	_status.add_theme_color_override("font_color", Color(0.75, 0.82, 0.95))
	_status.custom_minimum_size = Vector2(230, 0)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status)
	_button(col, "Outil : nœuds", func(): _set_tool("node"))
	_button(col, "Outil : props", func(): _set_tool("prop"))
	_button(col, "Type de prop →", _cycle_kind)
	_button(col, "Nouveau", _new)
	_button(col, "Charger", _load)
	_button(col, "Enregistrer", _save)
	_button(col, "Ajouter un nœud", _append_node)
	_button(col, "Supprimer le dernier", _pop_node)
	_button(col, "Tester l'acte 3", _test)
	_button(col, "Retour", func(): closed.emit(); queue_free())
	_refresh()


func _button(parent: Node, text: String, action: Callable) -> void:
	var b := Button.new()
	b.text = Loc.t(text)
	b.custom_minimum_size = Vector2(0, 32)
	b.pressed.connect(action)
	parent.add_child(b)


func _set_tool(tool: String) -> void:
	_tool = tool
	_refresh()


func _cycle_kind() -> void:
	_kind = (_kind + 1) % LevelData.PROP_KINDS.size()
	_refresh()


## Brief confirmation above the status line; `_process()` clears it.
func _announce(key: String) -> void:
	_notice = key
	_notice_left = 2.5
	_refresh()


func _new() -> void:
	LevelData.new_level()
	_announce("Nouveau niveau")


func _load() -> void:
	_announce("Niveau chargé" if LevelData.load_level() else "Aucun niveau enregistré")


func _save() -> void:
	_announce("Niveau enregistré" if LevelData.save_level() else "Échec de l'enregistrement")


func _append_node() -> void:
	var path: Array = LevelData.custom_path
	var last: Vector2 = path[-1] if not path.is_empty() else Vector2(0, 12)
	path.append(last + Vector2(0, -60))
	_refresh()


func _pop_node() -> void:
	if LevelData.custom_path.size() > 2:
		LevelData.custom_path.pop_back()
	_refresh()


func _test() -> void:
	LevelData.save_level()
	# Same launch path as the menu: without the mode, a fresh score and an armed
	# challenge, the act's results screen would report the previous run.
	GameState.mode = GameState.Mode.DRIVE
	GameState.last_act_success = true
	GameState.last_act_reason = ""
	GameState.show_results_on_load = false
	Score.reset()
	Progress.begin()
	Audio.stop_music()
	get_tree().change_scene_to_file("res://scenes/modes/drive.tscn")


func _refresh() -> void:
	var kind: String = LevelData.PROP_KINDS[_kind]
	var tool := Loc.t("nœuds du circuit") if _tool == "node" else Loc.t("props (%s)") % kind
	if _status:
		var text := Loc.t("%d nœuds • %d props\nOutil : %s\nClic : ajouter/déplacer • Clic droit : supprimer") % [
			LevelData.custom_path.size(), LevelData.props.size(), tool]
		if _notice != "":
			text = Loc.t(_notice) + "\n" + text
		_status.text = text
	_fit()
	queue_redraw()


func _draw() -> void:
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, Color(0.08, 0.10, 0.14), true)
	# Grid lines every 60 world units, for a sense of scale.
	for gx in range(-240, 300, 60):
		var top := _w2s(Vector2(gx, 60))
		var bottom := _w2s(Vector2(gx, -800))
		draw_line(top, bottom, Color(0.16, 0.19, 0.24), 1.0)
	for gz in range(60, -820, -60):
		var left := _w2s(Vector2(-240, gz))
		var right := _w2s(Vector2(300, gz))
		draw_line(left, right, Color(0.16, 0.19, 0.24), 1.0)
	# The track: segments then nodes.
	var path: Array = LevelData.custom_path
	for i in path.size() - 1:
		draw_line(_w2s(path[i]), _w2s(path[i + 1]), Color(0.35, 0.55, 0.9), 3.0)
	for i in path.size():
		var p := _w2s(path[i])
		var col := Color(0.95, 0.85, 0.3) if i > 0 else Color(0.3, 0.9, 0.5)
		draw_circle(p, NODE_RADIUS, col)
	# Props.
	for prop in LevelData.props:
		var p := _w2s(Vector2(prop["x"], prop["z"]))
		draw_rect(Rect2(p - Vector2(5, 5), Vector2(10, 10)), Color(0.9, 0.5, 0.25))


func _fit() -> void:
	var pts: Array = []
	for p in LevelData.custom_path:
		pts.append(p)
	for p in LevelData.props:
		pts.append(Vector2(p["x"], p["z"]))
	if pts.is_empty():
		return
	var lo: Vector2 = pts[0]
	var hi: Vector2 = pts[0]
	for p in pts:
		lo = lo.min(p)
		hi = hi.max(p)
	var span := (hi - lo)
	span.x = maxf(span.x, 1.0)
	span.y = maxf(span.y, 1.0)
	var usable := size - Vector2(MARGIN * 2.0, MARGIN * 2.0)
	_scale = minf(usable.x / span.x, usable.y / span.y)
	_scale = clampf(_scale, 0.05, 3.0)
	var centre := (lo + hi) * 0.5
	_origin = size * 0.5 - Vector2(centre.x, centre.y) * _scale


func _w2s(p: Vector2) -> Vector2:
	return _origin + Vector2(p.x, p.y) * _scale


func _s2w(s: Vector2) -> Vector2:
	return (s - _origin) / _scale


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_on_press(mb.position)
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if _tool == "prop":
				LevelData.remove_prop_near(_s2w(mb.position))
				_refresh()
		elif mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			if _drag >= 0:
				# Re-fit only once the drag is over, so the view stayed stable
				# while the node was following the cursor.
				_fit()
				queue_redraw()
			_drag = -1
	elif event is InputEventMouseMotion and _drag >= 0:
		var world := _s2w((event as InputEventMouseMotion).position)
		if _drag < LevelData.custom_path.size():
			LevelData.custom_path[_drag] = Vector2(roundf(world.x), roundf(world.y))
			queue_redraw()
	elif event.is_action_pressed("ui_cancel"):
		closed.emit()
		queue_free()


func _on_press(screen: Vector2) -> void:
	var world := _s2w(screen)
	for i in LevelData.custom_path.size():
		if _w2s(LevelData.custom_path[i]).distance_to(screen) <= NODE_RADIUS + 4.0:
			_drag = i
			return
	if _tool == "node":
		LevelData.custom_path.append(Vector2(roundf(world.x), roundf(world.y)))
	else:
		LevelData.add_prop(LevelData.PROP_KINDS[_kind], Vector2(roundf(world.x), roundf(world.y)))
	_refresh()
