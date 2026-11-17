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
	var text := FileAccess.get_file_as_string(PATH)
	var data: Variant = JSON.parse_string(text)
	if not data is Dictionary:
		return false
	custom_path = []
	for p in data.get("path", []):
		custom_path.append(Vector2(p[0], p[1]))
	props = []
	for p in data.get("props", []):
		props.append({"kind": p.get("kind", "cone"), "x": p.get("x", 0.0), "z": p.get("z", 0.0)})
	return custom_path.size() >= 2
