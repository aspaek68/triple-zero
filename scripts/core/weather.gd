class_name Weather
extends Node3D
## Dynamic weather: swaps the sky, fog, sun and rain over time.
##
## Add it under a mode's root, then call `set_preset()` (or `cycle()`). It
## eases every value over a second or two so a change reads as the sky
## turning rather than a hard cut, and it can fire lightning strikes and
## thunder when the storm rolls in. A camera target lets the rain follow the
## player so the volume never runs out.

signal changed(name: String)

enum Preset { CLEAR, RAIN, STORM, FOG }

## Per-preset look: sky colours, fog, sun, rain amount and storm odds. With the
## optional CC0 panorama sky, `sky_energy` scales the HDRI and `sky_affect` lets
## fog tint it; `sky_top`/`sky_horizon` still drive the procedural fallback.
## `sky_energy` for CLEAR mirrors `EnvBuilder.HDRI_ENERGY`.
const PRESETS := {
	Preset.CLEAR: {
		"name": "Clair",
		"sky_top": Color(0.27, 0.42, 0.68),
		"sky_horizon": Color(0.66, 0.75, 0.82),
		"fog": Color(0.68, 0.76, 0.86),
		"fog_density": 0.0016,
		"sun_energy": 1.25,
		"ambient": 1.1,
		"rain": 0.0,
		"wet": 0.0,
		"storm": false,
		"sky_energy": 0.65,
		"sky_affect": 0.3,
	},
	Preset.RAIN: {
		"name": "Pluie",
		"sky_top": Color(0.20, 0.24, 0.30),
		"sky_horizon": Color(0.42, 0.46, 0.52),
		"fog": Color(0.45, 0.50, 0.57),
		"fog_density": 0.006,
		"sun_energy": 0.55,
		"ambient": 0.75,
		"rain": 0.55,
		"wet": 0.55,
		"storm": false,
		"sky_energy": 0.42,
		"sky_affect": 0.9,
	},
	Preset.STORM: {
		"name": "Orage",
		"sky_top": Color(0.08, 0.10, 0.15),
		"sky_horizon": Color(0.20, 0.22, 0.28),
		"fog": Color(0.24, 0.26, 0.32),
		"fog_density": 0.010,
		"sun_energy": 0.28,
		"ambient": 0.5,
		"rain": 1.0,
		"wet": 1.0,
		"storm": true,
		"sky_energy": 0.26,
		"sky_affect": 1.0,
	},
	Preset.FOG: {
		"name": "Brouillard",
		"sky_top": Color(0.58, 0.60, 0.63),
		"sky_horizon": Color(0.74, 0.75, 0.77),
		"fog": Color(0.78, 0.79, 0.82),
		"fog_density": 0.028,
		"sun_energy": 0.5,
		"ambient": 0.95,
		"rain": 0.0,
		"wet": 0.15,
		"storm": false,
		"sky_energy": 0.5,
		"sky_affect": 1.0,
	},
}

const ORDER := [Preset.CLEAR, Preset.RAIN, Preset.STORM, Preset.FOG]

var preset: int = Preset.CLEAR
var intensity := 1.0
var follow: Node3D

var _env: Environment
var _sky_mat: Material
var _procedural: ProceduralSkyMaterial
var _pano: PanoramaSkyMaterial
var _sun: DirectionalLight3D
var _rain: GPUParticles3D
var _blend := 1.0
## Duration of the current transition, in seconds (`set_preset()` used to accept
## one and always ease over 1.5 s).
var _blend_time := 1.5
var _from: Dictionary = {}
var _to: Dictionary = {}
var _flash := 0.0
var _strike_in := 6.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 20260101
	_env = _find_environment()
	_sky_mat = _find_sky_material()
	_procedural = _sky_mat as ProceduralSkyMaterial
	_pano = _sky_mat as PanoramaSkyMaterial
	_sun = _find_sun()
	_rain = _build_rain()
	add_child(_rain)
	_from = PRESETS[preset]
	_to = _from
	_blend = 1.0
	_apply(1.0)


## Switches to a preset, easing from the current look. Pass a duration of 0
## to snap immediately.
func set_preset(p: int, duration := 1.5) -> void:
	preset = clampi(p, 0, ORDER.size() - 1)
	_from = _capture()
	_to = PRESETS[preset]
	_blend_time = maxf(duration, 0.001)
	_blend = 0.0 if duration > 0.0 else 1.0
	changed.emit(PRESETS[preset]["name"])


## Steps to the next preset in the cycle.
func cycle() -> void:
	var idx: int = ORDER.find(preset)
	set_preset(ORDER[(idx + 1) % ORDER.size()])


func name() -> String:
	return PRESETS[preset]["name"]


func wetness() -> float:
	return float(_to.get("wet", 0.0)) * intensity


func _process(delta: float) -> void:
	if _blend < 1.0:
		_blend = minf(_blend + delta / _blend_time, 1.0)
		_apply(smoothstep(0.0, 1.0, _blend))
	if _rain and follow:
		_rain.global_position = follow.global_position + Vector3(0, 12, 0)
	_update_lightning(delta)


func _apply(t: float) -> void:
	var sky_top: Color = _from["sky_top"].lerp(_to["sky_top"], t)
	var sky_h: Color = _from["sky_horizon"].lerp(_to["sky_horizon"], t)
	var fog: Color = _from["fog"].lerp(_to["fog"], t)
	var density: float = lerpf(_from["fog_density"], _to["fog_density"], t) * intensity
	var sky_energy: float = lerpf(_from.get("sky_energy", 1.0), _to.get("sky_energy", 1.0), t)
	var sky_affect: float = lerpf(_from.get("sky_affect", 0.3), _to.get("sky_affect", 0.3), t)
	if _procedural:
		_procedural.sky_top_color = sky_top
		_procedural.sky_horizon_color = sky_h
		_procedural.ground_horizon_color = sky_h.darkened(0.15)
	elif _pano:
		# The HDRI carries its own colours: dim it for rain/storm and let the
		# fog tint the background instead of repainting the panorama.
		_pano.energy_multiplier = sky_energy * intensity
	if _env:
		_env.fog_light_color = fog
		_env.fog_density = density
		_env.fog_sky_affect = clampf(sky_affect, 0.0, 1.0)
		_env.ambient_light_energy = lerpf(_from["ambient"], _to["ambient"], t) * intensity
		if _env.volumetric_fog_enabled:
			_env.volumetric_fog_density = 0.012 + density * 6.0
	if _sun:
		_sun.light_energy = lerpf(_from["sun_energy"], _to["sun_energy"], t) * intensity
		_sun.light_color = Color(1.0, 1.0, 1.0).lerp(sky_top.lightened(0.35), 0.35)
	if _rain:
		_rain.amount_ratio = lerpf(_from["rain"], _to["rain"], t) * intensity


func _capture() -> Dictionary:
	var sky_top: Color = _procedural.sky_top_color if _procedural else PRESETS[preset]["sky_top"]
	var sky_h: Color = _procedural.sky_horizon_color if _procedural else PRESETS[preset]["sky_horizon"]
	var fog: Color = _env.fog_light_color if _env else PRESETS[preset]["fog"]
	var density: float = (_env.fog_density if _env else PRESETS[preset]["fog_density"]) / maxf(intensity, 0.001)
	var sun: float = (_sun.light_energy if _sun else PRESETS[preset]["sun_energy"]) / maxf(intensity, 0.001)
	var amb: float = (_env.ambient_light_energy if _env else PRESETS[preset]["ambient"]) / maxf(intensity, 0.001)
	var sky_energy: float = (_pano.energy_multiplier if _pano else PRESETS[preset]["sky_energy"]) / maxf(intensity, 0.001)
	var sky_affect: float = _env.fog_sky_affect if _env else PRESETS[preset]["sky_affect"]
	return {
		"name": PRESETS[preset]["name"],
		"sky_top": sky_top,
		"sky_horizon": sky_h,
		"fog": fog,
		"fog_density": density,
		"sun_energy": sun,
		"ambient": amb,
		"rain": _rain.amount_ratio if _rain else 0.0,
		"wet": PRESETS[preset]["wet"],
		"storm": PRESETS[preset]["storm"],
		"sky_energy": sky_energy,
		"sky_affect": sky_affect,
	}


func _update_lightning(delta: float) -> void:
	if _flash > 0.0 and _sun:
		_flash = maxf(_flash - delta * 6.0, 0.0)
		_sun.light_energy = float(_to["sun_energy"]) * intensity + _flash * 6.0
	if not _to.get("storm", false) or intensity <= 0.0:
		return
	_strike_in -= delta
	if _strike_in <= 0.0:
		_strike_in = _rng.randf_range(3.0, 9.0)
		_flash = 1.0
		Audio.thunder()
		Options.rumble(0.15, 0.1, 0.25)


func _build_rain() -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = 4000
	p.lifetime = 1.2
	p.visibility_aabb = AABB(Vector3(-40, -20, -40), Vector3(80, 40, 80))
	p.emitting = true
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(38, 2, 38)
	mat.direction = Vector3(0.15, -1, 0.05)
	mat.spread = 4.0
	mat.initial_velocity_min = 26.0
	mat.initial_velocity_max = 34.0
	mat.gravity = Vector3(0, -14, 0)
	mat.scale_min = 0.4
	mat.scale_max = 0.9
	p.process_material = mat
	var drop := QuadMesh.new()
	drop.size = Vector2(0.03, 0.7)
	var dm := StandardMaterial3D.new()
	dm.albedo_color = Color(0.75, 0.82, 0.92, 0.55)
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	dm.vertex_color_use_as_albedo = true
	drop.material = dm
	p.draw_pass_1 = drop
	p.amount_ratio = 0.0
	return p


func _find_environment() -> Environment:
	var root: Node = get_parent() if get_parent() else self
	var world := _find_node(root, "WorldEnvironment")
	return (world as WorldEnvironment).environment if world is WorldEnvironment else null


func _find_sky_material() -> Material:
	if _env and _env.sky:
		return _env.sky.sky_material
	return null


func _find_sun() -> DirectionalLight3D:
	var root: Node = get_parent() if get_parent() else self
	var sun := _find_node(root, "Sun")
	return sun as DirectionalLight3D


func _find_node(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
	for c in root.get_children():
		var found := _find_node(c, node_name)
		if found:
			return found
	return null
