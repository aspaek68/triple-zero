extends Node
## Dev-only screenshot probe: loads one act, waits for the intro to finish and
## saves the rendered viewport to a PNG so the visuals can be reviewed without
## playing. Run windowed (not --headless), e.g.
##   godot --path . res://scenes/_shot.tscn -- --mode=1 --out=C:/tmp/shot1.png
## Diagnostic flags: --nofog --nopost --nosdfgi

var _nofog := false
var _nopost := false
var _nosdfgi := false


func _ready() -> void:
	var mode := 1
	var out := "user://shot.png"
	var wait_s := 6.0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--mode="):
			mode = int(arg.split("=")[1])
		elif arg.begins_with("--out="):
			out = arg.split("=", true, 1)[1]
		elif arg.begins_with("--wait="):
			wait_s = float(arg.split("=")[1])
		elif arg == "--nofog":
			_nofog = true
		elif arg == "--nopost":
			_nopost = true
		elif arg == "--nosdfgi":
			_nosdfgi = true
	var scenes := {
		1: "res://scenes/modes/tps.tscn",
		2: "res://scenes/modes/rail.tscn",
		3: "res://scenes/modes/drive.tscn",
	}
	var path: String = scenes.get(mode, scenes[1])
	var packed := load(path) as PackedScene
	if packed == null:
		print("SHOT: cannot load ", path)
		get_tree().quit(1)
		return
	add_child(packed.instantiate())
	await get_tree().process_frame
	await get_tree().process_frame
	_apply_debug_flags()
	await get_tree().create_timer(wait_s).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img == null:
		print("SHOT: no image")
		get_tree().quit(1)
		return
	var err := img.save_png(out)
	print("SHOT: ", out, " ", img.get_width(), "x", img.get_height(), " err=", err)
	get_tree().quit(0)


func _apply_debug_flags() -> void:
	if _nofog or _nosdfgi:
		var world := _find_world_environment(get_tree().root)
		if world and world.environment:
			var env := world.environment
			if _nofog:
				env.fog_enabled = false
				env.volumetric_fog_enabled = false
				print("SHOT: fog off")
			if _nosdfgi:
				env.sdfgi_enabled = false
				env.ssil_enabled = false
				print("SHOT: sdfgi off")
	if _nopost:
		var hidden := 0
		for node in get_tree().root.find_children("*", "ColorRect", true, false):
			if node.name in ["PostFx", "MotionBlur"]:
				node.visible = false
				hidden += 1
		print("SHOT: post-fx hidden=", hidden)


func _find_world_environment(node: Node) -> WorldEnvironment:
	if node is WorldEnvironment:
		return node as WorldEnvironment
	for child in node.get_children():
		var found := _find_world_environment(child)
		if found:
			return found
	return null
