class_name Destructible
extends StaticBody3D
## Breakable scenery. Barrels explode and deal area damage (chain-reacting with
## other barrels); crates just break apart. Anything that can take a hit joins
## the "destructible" group and exposes `take_damage()`.

enum Kind { BARREL, CRATE }

signal destroyed(pos: Vector3, was_explosive: bool)

const BARREL_RADIUS := 5.5
const BARREL_DAMAGE := 60

var kind: int = Kind.CRATE
var health := 2
var blast_radius := BARREL_RADIUS
var blast_damage := BARREL_DAMAGE
var _exploded := false


static func make(kind: int, pos: Vector3) -> Destructible:
	var d := Destructible.new()
	d.kind = kind
	d.position = pos
	d.health = 4 if kind == Kind.BARREL else 2
	d.add_to_group("destructible")
	d._build()
	return d


func _build() -> void:
	# The modelled props keep their authored materials; primitives stand in when
	# the model files are missing. Collision is derived from the prop's real
	# bounds so a CC0 barrel and its fallback share one hitbox.
	var model_name := "barrel" if kind == Kind.BARREL else "crate"
	var fallback: Mesh
	var fallback_material: Material
	if kind == Kind.BARREL:
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.3
		cyl.bottom_radius = 0.3
		cyl.height = 0.95
		fallback = cyl
		fallback_material = EnvBuilder.material(EnvBuilder.MAT_ACCENT)
	else:
		var box := BoxMesh.new()
		box.size = Vector3(1.2, 0.45, 0.8)
		fallback = box
		fallback_material = EnvBuilder.material(EnvBuilder.MAT_METAL, 0.6)
	var body := EnvBuilder.prop_native(model_name, fallback, fallback_material)
	add_child(body)

	var bounds := EnvBuilder.prop_bounds(body)
	if bounds.size == Vector3.ZERO:
		bounds = AABB(Vector3(-0.3, 0.0, -0.3), Vector3(0.6, 0.95, 0.6))
	# Generated fallbacks are centred: lift them so their base touches y = 0.
	var lift := maxf(-bounds.position.y, 0.0)
	body.position.y = lift

	var cs := CollisionShape3D.new()
	if kind == Kind.BARREL:
		var cyl_shape := CylinderShape3D.new()
		cyl_shape.radius = maxf(bounds.size.x, bounds.size.z) * 0.5
		cyl_shape.height = maxf(bounds.size.y, 0.05)
		cs.shape = cyl_shape
	else:
		var box_shape := BoxShape3D.new()
		box_shape.size = bounds.size
		cs.shape = box_shape
	cs.position.y = lift + bounds.position.y + bounds.size.y * 0.5
	add_child(cs)


func take_damage(amount: int) -> void:
	if _exploded:
		return
	health -= amount
	if health <= 0:
		_break()


func _break() -> void:
	if _exploded:
		return
	_exploded = true
	var pos := global_position
	if kind == Kind.BARREL:
		_explode(pos)
	destroyed.emit(pos, kind == Kind.BARREL)
	queue_free()


## Area damage, also triggering other barrels caught in the blast.
func _explode(pos: Vector3) -> void:
	Audio.explosion()
	Options.rumble(0.9, 0.5, 0.35)
	Score.register_damage(0)
	for e in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(e) and e.has_method("take_damage"):
			if e.global_position.distance_to(pos) < blast_radius:
				e.take_damage(blast_damage)
	for d in get_tree().get_nodes_in_group("destructible"):
		if d != self and is_instance_valid(d) and d is Destructible and d.kind == Kind.BARREL:
			if d.global_position.distance_to(pos) < blast_radius:
				d.call_deferred("take_damage", blast_damage)
	for p in get_tree().get_nodes_in_group("player"):
		if is_instance_valid(p) and p.has_method("take_damage"):
			var dist: float = (p as Node3D).global_position.distance_to(pos)
			if dist < blast_radius:
				p.take_damage(int(35 * (1.0 - dist / blast_radius)))
	_spawn_flash(pos)


func _spawn_flash(pos: Vector3) -> void:
	var flash := OmniLight3D.new()
	flash.position = pos + Vector3(0, 1, 0)
	flash.light_color = Color(1.0, 0.6, 0.2)
	flash.light_energy = 8.0
	flash.omni_range = blast_radius
	get_parent().add_child(flash)
	var tween := flash.create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 0.35)
	tween.tween_callback(flash.queue_free)
