class_name EnvBuilder
extends RefCounted
## Builds a bright, daytime world: procedural sky, sun with shadows, aerial
## fog, AgX tonemapping and bloom. Advanced effects (SSAO/SSIL, SSR, volumetric
## fog) are enabled only when the renderer supports them, so the GL
## Compatibility fallback keeps working.

# Day palette: blue sky, warm sun, hazy horizon.
const SKY_TOP := Color(0.24, 0.48, 0.86)
const SKY_HORIZON := Color(0.74, 0.83, 0.94)
const GROUND_HORIZON := Color(0.63, 0.65, 0.6)
const GROUND_BOTTOM := Color(0.32, 0.35, 0.33)
const SUN_COLOR := Color(1.0, 0.96, 0.88)
const FOG_COLOR := Color(0.72, 0.8, 0.9)

# Material palette for the blockout.
const MAT_GROUND := Color(0.42, 0.45, 0.42)
const MAT_ROAD := Color(0.28, 0.29, 0.31)
const MAT_WALL_A := Color(0.86, 0.82, 0.74)
const MAT_WALL_B := Color(0.78, 0.7, 0.62)
const MAT_WALL_C := Color(0.7, 0.74, 0.78)
const MAT_METAL := Color(0.55, 0.58, 0.62)
const MAT_ACCENT := Color(0.85, 0.35, 0.3)
const MAT_GLASS := Color(0.5, 0.68, 0.82)
const MAT_WATER := Color(0.16, 0.38, 0.5)

# Optional CC0 panorama sky (Poly Haven). When the file is present it replaces
# the procedural sky; `sun.json` (written by tools/hdri_sun.py) records where the
# HDRI's own sun sits, so the panorama can be rotated to match the sun light.
const HDRI_DIR := "res://assets/hdri"
const HDRI_NAMES := ["sky.hdr", "sky.exr"]
const HDRI_ENERGY := 0.65
const SUN_YAW := -35.0

# Textures are looked up in the CC0 pack first, then in the generated set.
const TEXTURE_DIRS := ["res://assets/textures_cc0", "res://assets/textures"]
# World-space tile size (metres per texture repeat) per surface.
const TEXTURE_SCALE := {
	"concrete": 0.4,
	"asphalt": 0.4,
	"metal": 0.6,
	"brick": 0.5,
	"ground": 0.3,
}


## Adds sky, sun, environment and a soft fill light under `parent`.
static func setup_world(parent: Node, sun_degrees: float = -48.0) -> void:
	parent.add_child(_build_environment())
	parent.add_child(_build_sun(sun_degrees))
	parent.add_child(_build_reflection_probe())


static func _build_reflection_probe() -> ReflectionProbe:
	var probe := ReflectionProbe.new()
	probe.name = "ReflectionProbe"
	probe.size = Vector3(120, 60, 120)
	probe.position = Vector3(0, 8, -30)
	probe.update_mode = ReflectionProbe.UPDATE_ONCE
	probe.intensity = 1.0
	probe.max_distance = 80.0
	probe.mesh_lod_threshold = 0.5
	return probe


static func _build_environment() -> WorldEnvironment:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"

	var sky := Sky.new()
	var pano := _build_panorama_sky()
	if pano:
		sky.sky_material = pano
		sky.process_mode = Sky.PROCESS_MODE_AUTOMATIC
		sky.radiance_size = Sky.RADIANCE_SIZE_256
	else:
		var sky_mat := ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = SKY_TOP
		sky_mat.sky_horizon_color = SKY_HORIZON
		sky_mat.sky_curve = 0.15
		sky_mat.ground_horizon_color = GROUND_HORIZON
		sky_mat.ground_bottom_color = GROUND_BOTTOM
		sky_mat.ground_curve = 0.02
		sky_mat.sun_angle_max = 12.0
		sky_mat.sun_curve = 0.08
		sky_mat.use_debanding = true
		sky.sky_material = sky_mat
		sky.process_mode = Sky.PROCESS_MODE_REALTIME

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.55
	env.ambient_light_energy = 0.65
	if pano:
		# Spin the panorama so its baked sun shares the light's azimuth.
		env.sky_rotation = Vector3(0, _hdri_yaw_offset(), 0)

	# Cinematic tonemapping (AgX keeps highlights and skin tones natural) plus
	# a light colour grade.
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_white = 3.0
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.12
	env.adjustment_saturation = 1.15

	# Bloom: strong enough to sell the muzzle flashes and neon, blended in HDR.
	env.glow_enabled = true
	env.glow_intensity = 0.45
	env.glow_strength = 0.9
	env.glow_bloom = 0.05
	env.glow_hdr_threshold = 1.1
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN

	# Aerial perspective: hazes distant geometry without darkening the scene.
	env.fog_enabled = true
	env.fog_light_color = FOG_COLOR
	env.fog_light_energy = 0.85
	env.fog_density = 0.0008
	env.fog_aerial_perspective = 0.4
	env.fog_sky_affect = 0.3
	env.fog_height = 20.0
	env.fog_height_density = 0.0015

	_apply_advanced_lighting(env)

	world_env.environment = env
	return world_env


## Optional panorama sky from `assets/hdri/`. Returns null when the file is
## missing or not imported yet, in which case the procedural sky is used.
static func _build_panorama_sky() -> PanoramaSkyMaterial:
	var path := hdri_path()
	if path == "":
		return null
	var tex := load_hdri(path)
	if tex == null:
		return null
	var pano := PanoramaSkyMaterial.new()
	pano.panorama = tex
	pano.energy_multiplier = HDRI_ENERGY
	return pano


static func hdri_path() -> String:
	for file_name in HDRI_NAMES:
		var path: String = "%s/%s" % [HDRI_DIR, file_name]
		if FileAccess.file_exists(path):
			return path
	return ""


## `.hdr`/`.exr` only load through the import pipeline; on a fresh clone without
## `.godot/` we return null so the world falls back to the procedural sky
## instead of logging an error.
static func load_hdri(path: String) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		return null
	if not _is_imported(path):
		return null
	var res := ResourceLoader.load(path)
	return res as Texture2D


## Yaw (radians) that spins the panorama so its baked sun lines up with the
## directional light. `sun.json` is written by tools/hdri_sun.py.
static func _hdri_yaw_offset() -> float:
	var path: String = "%s/sun.json" % HDRI_DIR
	if not FileAccess.file_exists(path):
		return 0.0
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (data is Dictionary):
		return 0.0
	if not bool((data as Dictionary).get("has_sun", false)):
		return 0.0
	var azimuth := float((data as Dictionary).get("azimuth_deg", 0.0))
	return deg_to_rad(SUN_YAW - azimuth)


## Enables screen-space and volumetric effects only when the renderer actually
## supports them. We query the live rendering method rather than the project
## setting, because the Forward+ launcher overrides it on the command line.
static func _apply_advanced_lighting(env: Environment) -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		return

	# Contact shadows and ambient occlusion ground objects in the scene.
	env.ssao_enabled = true
	env.ssao_radius = 1.4
	env.ssao_intensity = 1.6
	env.ssao_power = 1.6
	env.ssao_detail = 0.6
	env.ssil_enabled = true
	env.ssil_intensity = 0.8

	# Real-time global illumination (SDFGI) for bounced light.
	env.sdfgi_enabled = true
	env.sdfgi_use_occlusion = true
	env.sdfgi_read_sky_light = true
	env.sdfgi_bounce_feedback = 0.7
	env.sdfgi_cascades = 4
	env.sdfgi_min_cell_size = 0.4
	env.sdfgi_energy = 1.0

	# Screen-space reflections for wet asphalt, glass and metal.
	env.ssr_enabled = true
	env.ssr_max_steps = 64
	env.ssr_fade_in = 0.15
	env.ssr_fade_out = 2.0

	# Soft volumetric fog for god rays and depth.
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.0025
	env.volumetric_fog_albedo = FOG_COLOR
	env.volumetric_fog_length = 120.0
	env.volumetric_fog_gi_inject = 0.3


static func _build_sun(degrees: float) -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(degrees, SUN_YAW, 0.0)
	sun.light_color = SUN_COLOR
	sun.light_energy = 1.4
	sun.light_angular_distance = 0.6
	sun.light_volumetric_fog_energy = 1.4
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 220.0
	sun.directional_shadow_blend_splits = true
	sun.shadow_blur = 1.4
	sun.directional_shadow_split_1 = 0.06
	sun.directional_shadow_split_2 = 0.18
	sun.directional_shadow_split_3 = 0.45
	sun.shadow_bias = 0.025
	sun.shadow_normal_bias = 1.0
	return sun


## Shared material factory: opaque surfaces with tuned roughness/metallic.
## If a texture file exists in `assets/textures/` it is applied (albedo plus
## normal and roughness maps when present); otherwise the material stays
## flat-coloured, so the game runs with or without assets.
static func material(color: Color, roughness: float = 0.85, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	var tex_name := _texture_name(color)
	var tex_path := _resolve_texture(tex_name)
	var tex := texture_for(color)
	if tex:
		mat.albedo_texture = tex
		# CC0 scans already carry their own colour; generated maps are tinted
		# by the palette, so only those keep the palette colour.
		if tex_path.begins_with("res://assets/textures_cc0/"):
			mat.albedo_color = Color(1, 1, 1)
		# World-space triplanar mapping keeps texel density constant on walls,
		# floors and props of any size instead of stretching one UV tile.
		mat.uv1_triplanar = true
		mat.uv1_world_triplanar = true
		mat.uv1_scale = Vector3.ONE * float(TEXTURE_SCALE.get(tex_name, 0.3))
		var normal := load_texture(normal_map_path(color))
		if normal:
			mat.normal_enabled = true
			mat.normal_texture = normal
			mat.normal_scale = 1.2
		var rough := load_texture(roughness_map_path(color))
		if rough:
			mat.roughness_texture = rough
		var ao := load_texture(ao_map_path(color))
		if ao:
			mat.ao_enabled = true
			mat.ao_texture = ao
			mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
			mat.ao_light_affect = 0.35
	var metal := load_texture(metallic_map_path(color))
	if metal:
		mat.metallic_texture = metal
		mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	# Clear coat on metal surfaces (car paint / wet metal look).
	if tex_name == "metal":
		mat.clearcoat_enabled = true
		mat.clearcoat = 0.5
		mat.clearcoat_roughness = 0.08
	return mat


## Finds `<base><suffix>.(png|jpg)` in the CC0 pack, then the generated set.
static func _resolve_texture(tex_name: String, suffix := "") -> String:
	if tex_name == "":
		return ""
	var key := tex_name + suffix
	if _path_cache.has(key):
		return _path_cache[key]
	var found := ""
	for dir in TEXTURE_DIRS:
		for ext in [".png", ".jpg"]:
			var path: String = "%s/%s%s%s" % [dir, tex_name, suffix, ext]
			if FileAccess.file_exists(path):
				found = path
				break
		if found != "":
			break
	_path_cache[key] = found
	return found


static func normal_map_path(color: Color) -> String:
	return _resolve_texture(_texture_name(color), "_normal")


static func roughness_map_path(color: Color) -> String:
	return _resolve_texture(_texture_name(color), "_rough")


static func ao_map_path(color: Color) -> String:
	return _resolve_texture(_texture_name(color), "_ao")


static func metallic_map_path(color: Color) -> String:
	return _resolve_texture(_texture_name(color), "_metal")


## Maps a palette colour to a texture file (by name), cached after first load.
static func texture_for(color: Color) -> Texture2D:
	var tex_name := _texture_name(color)
	if tex_name == "":
		return null
	if _texture_cache.has(tex_name):
		return _texture_cache[tex_name]
	var path := _resolve_texture(tex_name)
	var tex := load_texture(path) if path != "" else null
	_texture_cache[tex_name] = tex
	return tex


## Loads a texture without requiring the editor's import cache. If the file was
## imported we use the fast path; otherwise we decode the raw PNG at runtime,
## which keeps the game error-free on a fresh clone (no `.godot/` folder).
static func load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	if _is_imported(path):
		return load(path)
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		return null
	var img := Image.new()
	if img.load_png_from_buffer(bytes) != OK and img.load_jpg_from_buffer(bytes) != OK:
		return null
	return ImageTexture.create_from_image(img)


## True when the import cache entry for `path` is present on disk.
static func _is_imported(path: String) -> bool:
	var import_path := path + ".import"
	if not FileAccess.file_exists(import_path):
		return false
	var file := FileAccess.open(import_path, FileAccess.READ)
	if file == null:
		return false
	while not file.eof_reached():
		var line := file.get_line()
		if line.begins_with("path="):
			var remap := line.substr(5).strip_edges().trim_prefix("\"").trim_suffix("\"")
			return FileAccess.file_exists(remap)
	return false


static func _texture_name(color: Color) -> String:
	if color.is_equal_approx(MAT_GROUND):
		return "ground"
	if color.is_equal_approx(MAT_ROAD):
		return "asphalt"
	if color.is_equal_approx(MAT_METAL):
		return "metal"
	if color.is_equal_approx(MAT_WALL_B):
		return "brick"
	if color.is_equal_approx(MAT_WALL_A):
		return "concrete"
	return ""


## Loads a prop mesh (first surface only). Kept for callers that need a plain
## mesh; the world props use `load_model_scene()` so multi-part models survive.
static func load_model(model_name: String) -> ArrayMesh:
	if _model_cache.has(model_name):
		return _model_cache[model_name]
	var mesh: ArrayMesh = null
	var scene := load_model_scene(model_name)
	if scene != null:
		mesh = _first_mesh(scene)
		scene.free()
	_model_cache[model_name] = mesh
	return mesh


static func _first_mesh(node: Node) -> ArrayMesh:
	if node is MeshInstance3D and (node as MeshInstance3D).mesh is ArrayMesh:
		return (node as MeshInstance3D).mesh
	for c in node.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null


## Longest side (metres) each CC0 prop is scaled to, so authored assets drop
## into the blockout at the size the level was built around. Scaling by the
## longest side keeps flat props (ammo crates) from ballooning when their height
## is small.
const MODEL_SIZE := {
	"barrel": 0.95,
	"crate": 1.2,
	"streetlamp": 4.6,
	"barrier": 1.9,
	"dumpster": 1.25,
	"planter": 1.2,
}


## Loads a whole prop scene: the CC0 pack first (`assets/models_cc0/<name>/`),
## then the generated `assets/models/<name>.glb`. CC0 props are scaled to their
## target height and dropped on the floor (min y = 0, centred on x/z). Uses the
## import cache when present and parses the raw glTF otherwise, so a fresh clone
## stays error-free.
static func load_model_scene(model_name: String) -> Node3D:
	if _scene_cache.has(model_name):
		var cached: PackedScene = _scene_cache[model_name]
		var inst := cached.instantiate() as Node3D if cached != null else null
		if inst != null:
			_apply_lod(inst)
		return inst
	var cc0 := _cc0_model_path(model_name)
	var path := cc0 if cc0 != "" else "res://assets/models/%s.glb" % model_name
	var packed := _load_packed(path)
	_scene_cache[model_name] = packed
	if packed == null:
		return null
	var scene := packed.instantiate() as Node3D
	if scene == null:
		return null
	if cc0 != "":
		_prune_model(scene, model_name)
		_normalize_model(scene, model_name)
	_apply_lod(scene)
	return scene


static func _cc0_model_path(model_name: String) -> String:
	for ext in [".gltf", ".glb"]:
		var path: String = "res://assets/models_cc0/%s/%s%s" % [model_name, model_name, ext]
		if FileAccess.file_exists(path):
			return path
	return ""


static func _load_packed(path: String) -> PackedScene:
	if not FileAccess.file_exists(path):
		return null
	if _is_imported(path):
		var res := ResourceLoader.load(path)
		if res is PackedScene:
			return res
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file(path, state) != OK:
		return null
	var scene := doc.generate_scene(state)
	if scene == null:
		return null
	var packed := PackedScene.new()
	var err := packed.pack(scene)
	scene.free()
	return packed if err == OK else null


## Some CC0 scenes ship several variants side by side (two crates, a clean and a
## rusted bin). Drop the unused ones before measuring the AABB.
const MODEL_DROP := {
	"crate": ["_b"],
	"dumpster": ["_rust"],
}


static func _prune_model(scene: Node3D, model_name: String) -> void:
	var drops: Array = MODEL_DROP.get(model_name, [])
	if drops.is_empty():
		return
	var doomed: Array[Node] = []
	for child in scene.get_children():
		var child_name := String(child.name).to_lower()
		for token in drops:
			if child_name.contains(String(token)):
				doomed.append(child)
				break
	for node in doomed:
		scene.remove_child(node)
		node.free()


static func _normalize_model(scene: Node3D, model_name: String) -> void:
	var box := _scene_aabb(scene, Transform3D.IDENTITY)
	var longest := maxf(box.size.x, maxf(box.size.y, box.size.z))
	if longest <= 0.0001:
		return
	var scale_factor := 1.0
	var target := float(MODEL_SIZE.get(model_name, 0.0))
	if target > 0.0:
		scale_factor = target / longest
	scene.scale = Vector3.ONE * scale_factor
	var center := box.get_center()
	scene.position = Vector3(-center.x * scale_factor, -box.position.y * scale_factor,
		-center.z * scale_factor)


## Aggressive LOD bias + culling margins for runtime-loaded props.
static func _apply_lod(node: Node) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		mi.lod_bias = 0.6
		mi.extra_cull_margin = 0.5
	for child in node.get_children():
		_apply_lod(child)


static func _scene_aabb(node: Node3D, xform: Transform3D) -> AABB:
	var box := AABB()
	var has := false
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		box = xform * (node as MeshInstance3D).mesh.get_aabb()
		has = true
	for child in node.get_children():
		if child is Node3D:
			var child_box := _scene_aabb(child, xform * (child as Node3D).transform)
			if child_box.size != Vector3.ZERO:
				box = child_box if not has else box.merge(child_box)
				has = true
	return box if has else AABB()


## A prop mesh instance from a model, or `fallback` when the file is missing.
## The base of every model sits at y = 0, so place it on the floor. `material`
## overrides every surface, which is what you want when the prop should share
## the level's PBR texture.
static func prop(model_name: String, fallback: Mesh, material: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var scene := load_model_scene(model_name)
	if scene != null:
		mi.add_child(scene)
		_override_material(scene, material)
	else:
		mi.mesh = fallback
		mi.material_override = material
	return mi


static func _override_material(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child in node.get_children():
		_override_material(child, material)


## Like `prop`, but keeps the model's own materials (the authored look). The
## fallback material is only used when the model file is missing.
static func prop_native(model_name: String, fallback: Mesh, fallback_material: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var scene := load_model_scene(model_name)
	if scene != null:
		mi.add_child(scene)
	else:
		mi.mesh = fallback
		mi.material_override = fallback_material
	return mi


## Local-space bounds of a prop (`prop()` / `prop_native()` result or a scene
## from `load_model_scene()`). Empty when the node holds no mesh. Callers use it
## to size collision shapes and to detect props whose pivot is not at the base.
static func prop_bounds(node: Node3D) -> AABB:
	if node == null:
		return AABB()
	return _scene_aabb(node, Transform3D.IDENTITY)


## Generated fallbacks are centred meshes, so their pivot sits mid-height.
## Lift the instance when its bounds dip below the floor.
static func _sit_on_floor(mi: MeshInstance3D) -> void:
	var box := prop_bounds(mi)
	if box.size == Vector3.ZERO:
		return
	if box.position.y < -0.001:
		mi.position.y -= box.position.y


## Places a prop at a floor position (models have their base at y = 0).
static func prop_at(parent: Node3D, model: String, fallback: Mesh, material: Material,
		pos: Vector3, rot_y := 0.0) -> MeshInstance3D:
	var mi := prop(model, fallback, material)
	mi.position = pos
	mi.rotation.y = rot_y
	parent.add_child(mi)
	_sit_on_floor(mi)
	return mi


## Places a prop that keeps its authored materials.
static func prop_native_at(parent: Node3D, model: String, fallback: Mesh,
		fallback_material: Material, pos: Vector3, rot_y := 0.0) -> MeshInstance3D:
	var mi := prop_native(model, fallback, fallback_material)
	mi.position = pos
	mi.rotation.y = rot_y
	parent.add_child(mi)
	_sit_on_floor(mi)
	return mi


## Cheap stand-ins used when a model file is missing.
static func lamp_fallback() -> Mesh:
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.08
	cyl.bottom_radius = 0.08
	cyl.height = 4.5
	return cyl


static func cone_fallback() -> Mesh:
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.05
	cyl.bottom_radius = 0.22
	cyl.height = 0.6
	return cyl


static var _model_cache: Dictionary = {}
static var _scene_cache: Dictionary = {}
static var _texture_cache: Dictionary = {}
static var _path_cache: Dictionary = {}
