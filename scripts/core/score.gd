extends Node
## Autoload: run scoring. Rewards precision, speed, exploration and protecting
## civilians, and derives an S/A/B/C rank shown on the results screen.

signal changed

var shots_fired := 0
var shots_hit := 0
var headshots := 0
var civilians_saved := 0
var civilians_lost := 0
var alternate_paths := 0
var equipment_recovered := 0
var comm_restored := 0
var takedowns := 0
var time_bonus := 0
var damage_taken := 0


func reset() -> void:
	shots_fired = 0
	shots_hit = 0
	headshots = 0
	civilians_saved = 0
	civilians_lost = 0
	alternate_paths = 0
	equipment_recovered = 0
	comm_restored = 0
	takedowns = 0
	time_bonus = 0
	damage_taken = 0
	changed.emit()


func register_shot(hit: bool, head := false) -> void:
	shots_fired += 1
	if hit:
		shots_hit += 1
		if head:
			headshots += 1
	changed.emit()


## Records a wrecked enemy vehicle (drive act) or a similar takedown.
func register_kill() -> void:
	takedowns += 1
	changed.emit()


func register_alternate_path() -> void:
	alternate_paths += 1
	changed.emit()


func register_civilian(saved: bool) -> void:
	if saved:
		civilians_saved += 1
	else:
		civilians_lost += 1
	changed.emit()


## Records equipment recovered (e.g., weapons, gear lost by enemies).
func register_equipment_recovered() -> void:
	equipment_recovered += 1
	changed.emit()


## Records communication nodes restored (antennas, radio relays).
func register_comm_restored() -> void:
	comm_restored += 1
	changed.emit()


func register_damage(amount: int) -> void:
	damage_taken += amount
	changed.emit()


func accuracy_ratio() -> float:
	if shots_fired == 0:
		return 0.0
	return clampf(float(shots_hit) / float(shots_fired), 0.0, 1.0)


func total() -> int:
	var base := shots_hit * 100 + headshots * 150
	base += alternate_paths * 500
	base += civilians_saved * 200 - civilians_lost * 400
	base += equipment_recovered * 250
	base += comm_restored * 350
	base += takedowns * 150
	base += time_bonus
	# Only a shooting act earns the accuracy bonus; the driving act would
	# otherwise start with a free 1000 points for "missing nothing".
	if shots_fired > 0:
		base += int(accuracy_ratio() * 1000.0)
	base -= damage_taken * 50
	if damage_taken == 0:
		base = int(base * 1.5)
	return maxi(base, 0)


func rank() -> String:
	var score := total()
	if score >= 8000:
		return "S"
	elif score >= 5000:
		return "A"
	elif score >= 2500:
		return "B"
	return "C"
