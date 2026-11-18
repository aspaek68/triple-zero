extends Node
## Autoload: the custom level the editor produces (track centreline plus
## scattered props), persisted to user://level.json.
##
## The acts keep their built-in layouts; a mode asks for `active_path()`
## and gets the custom centreline only when one has been saved, so playing
## without ever opening the editor behaves exactly as before.

const PATH := "user://level.json"
const PROP_KINDS := ["barrel", "crate", "cone", "streetlamp", "dumpster", "planter", "barrier", "neon_sign", "road_sign"]

var custom_path: Array = []      # Array[Vector2] in (x, z)
var props: Array = []            # [{kind, x, z}]


func _ready() -> void:
	load_level()


## Returns the centreline to build: the custom one when saved, else the
## mode's own default.
func active_path(default_path: Array) -> Array:
	return custom_path if custom_path.size() >= 2 else default_path


func has_custom() -> bool:
	return custom_path.size() >= 2


func reset() -> void:
	custom_path = []
	props = []


## Starts a fresh track: a straight run of nodes, ready to be dragged.
func new_level() -> void:
	custom_path = []
	for i in 6:
		custom_path.append(Vector2(0, 12 - i * 60))
	props = []


func add_prop(kind: String, pos: Vector2) -> void:
	if not PROP_KINDS.has(kind):
		return
	props.append({"kind": kind, "x": pos.x, "z": pos.y})


func remove_prop_near(pos: Vector2, radius := 6.0) -> bool:
	for i in props.size():
		var p: Dictionary = props[i]
		if Vector2(p["x"], p["z"]).distance_to(pos) <= radius:
			props.remove_at(i)
			return true
	return false


func save_level() -> bool:
	var data := {"path": [], "props": props}
	for p in custom_path:
		data["path"].append([p.x, p.y])
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	return true


func load_level() -> bool:
	if not FileAccess.file_exists(PATH):
		return false
	return apply_data(JSON.parse_string(FileAccess.get_file_as_string(PATH)))


## Validates a parsed level and installs it. `user://level.json` can be edited
## by hand or left half-written, so every entry is type-checked instead of
## trusting the JSON shape (a bad entry used to crash the editor and the act).
func apply_data(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	var dict: Dictionary = data
	var raw_path: Variant = dict.get("path", [])
	var raw_props: Variant = dict.get("props", [])
	if not raw_path is Array or not raw_props is Array:
		return false
	var path: Array = []
	for p in raw_path:
		if not p is Array or (p as Array).size() < 2:
			continue
		var x: Variant = p[0]
		var z: Variant = p[1]
		if not _is_number(x) or not _is_number(z):
			continue
		path.append(Vector2(float(x), float(z)))
	if path.size() < 2:
		return false
	var loaded_props: Array = []
	for p in raw_props:
		if not p is Dictionary:
			continue
		var kind: Variant = p.get("kind", "cone")
		if not kind is String or not PROP_KINDS.has(kind):
			continue
		var x: Variant = p.get("x", 0.0)
		var z: Variant = p.get("z", 0.0)
		if not _is_number(x) or not _is_number(z):
			continue
		loaded_props.append({"kind": kind, "x": float(x), "z": float(z)})
	custom_path = path
	props = loaded_props
	return true


func _is_number(v: Variant) -> bool:
	return v is float or v is int
