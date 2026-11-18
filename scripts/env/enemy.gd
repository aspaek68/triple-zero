class_name Enemy
extends CharacterBody3D
## A hostile that can be shot and caught in explosions. Kept deliberately small:
## the mode owns the AI/behaviour, this owns health, the damage reaction and the
## death fall.

signal died(enemy: Enemy)

var hp := 3
var hp_max := 3
var heavy := false
var variant := "rifleman"
var boss := false
var cooldown := 2.0
## Flanking: which way this unit prefers to circle, and a phase so a squad
## does not move in lockstep.
var strafe := 1.0
var phase := 0.0
var _mesh: MeshInstance3D
var _character: Character
var _speed01 := 0.0
var _dying := false


static func make(pos: Vector3, is_heavy: bool, is_boss := false) -> Enemy:
	var e := Enemy.new()
	e.position = pos
	e.heavy = is_heavy
	e.hp = 6 if is_heavy else 3
	# New Game+: hostiles are tougher and react faster.
	if GameState.ng_plus:
		e.hp += 3 if is_heavy else 2
	e.cooldown = randf_range(1.0, 2.5)
	e.strafe = 1.0 if randf() < 0.5 else -1.0
	e.phase = randf() * TAU
	e.variant = _pick_variant(is_heavy)
	if is_boss:
		e.boss = true
		e.heavy = true
		e.variant = Character.VARIANT_ELITE
		e.hp = 34 + (16 if GameState.ng_plus else 0)
		e.cooldown = 1.2
		e.scale = Vector3.ONE * 1.35
	e.hp_max = e.hp
	e.add_to_group("enemy")
	e._build()
	return e


## Visual role: heavy units are always armoured, New Game+ can field elites and
## lighter scouts appear occasionally to break the silhouette up.
static func _pick_variant(is_heavy: bool) -> String:
	if is_heavy:
		return Character.VARIANT_HEAVY
	if GameState.ng_plus and randf() < 0.35:
		return Character.VARIANT_ELITE
	if randf() < 0.22:
		return Character.VARIANT_SCOUT
	return Character.VARIANT_RIFLEMAN


## Clothes/accent palette per role, so units read apart at a glance.
static func _variant_colors(kind: String) -> Array:
	match kind:
		"heavy":
			return [Color(0.30, 0.25, 0.22), Color(0.12, 0.13, 0.15)]
		"scout":
			return [Color(0.34, 0.40, 0.28), Color(0.16, 0.18, 0.16)]
		"elite":
			return [Color(0.18, 0.20, 0.24), Color(0.45, 0.12, 0.12)]
		_:
			return [Color(0.42, 0.28, 0.24), Color(0.20, 0.22, 0.24)]


func _build() -> void:
	var radius := 0.55 if heavy else 0.4
	var height := 2.3 if heavy else 1.8
	var colors := _variant_colors(variant)
	_character = Character.make(colors[0], colors[1], heavy, variant)
	add_child(_character)
	# Head height reference for hitscan/aiming.
	_mesh = MeshInstance3D.new()
	_mesh.position.y = height - 0.2
	var marker := SphereMesh.new()
	marker.radius = 0.01
	marker.height = 0.02
	_mesh.mesh = marker
	_mesh.visible = false
	add_child(_mesh)
	# A weapon in hand, so hostiles read as armed.
	var weapon := Weapon.make()
	weapon.position = Vector3(0, 0, 0)
	_character.weapon_mount().add_child(weapon)

	var cs := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	cs.shape = shape
	cs.position.y = height * 0.5
	add_child(cs)


func _process(delta: float) -> void:
	if _character and not _dying:
		_character.aim(0.0)
		_character.animate_walk(delta, _speed01)


func take_damage(amount: int) -> void:
	if _dying:
		return
	hp -= amount
	if hp <= 0:
		die()
	else:
		_flash()
		# Play the stagger clip too: the flash alone read as a visual glitch.
		if _character:
			_character.hit_react()


func _flash() -> void:
	if _character:
		_character.flash()


func die() -> void:
	if _dying:
		return
	_dying = true
	remove_from_group("enemy")
	# Stop blocking shots: the ragdoll parts take over the visual, the capsule
	# would otherwise stay standing in the world.
	collision_layer = 0
	collision_mask = 0
	if _character:
		_character.die()
	died.emit(self)
	# Let the fall and the ragdoll settle before the body disappears.
	get_tree().create_timer(2.4).timeout.connect(queue_free)
