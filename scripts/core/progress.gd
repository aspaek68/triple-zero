extends Node
## Autoload: New Game+ unlock and the replayable challenge system.
## Persists what the player has unlocked and which challenge is armed.

signal changed
signal challenge_failed(reason: String)

const PATH := "user://progress.cfg"

## Replayable challenges (modifiers). "none" is a free run.
const CHALLENGES: Array = [
	{"id": "none", "name": "Partie libre", "desc": "Sans contrainte"},
	{"id": "no_damage", "name": "Sans dégâts", "desc": "Terminer sans être touché ni causer de dégâts"},
	{"id": "time", "name": "Contre-la-montre", "desc": "Terminer en moins de 4 min"},
	{"id": "accuracy", "name": "Tireur d'élite", "desc": "Précision d'au moins 90 %"},
	{"id": "explorer", "name": "Explorateur", "desc": "Emprunter un itinéraire alternatif"},
]

const TIME_LIMIT := 240.0
## Two equipment slots per act (0 = TPS, 1 = rail, 2 = drive, matching
## `GameState.Mode`).
const EQUIP_SLOTS := 2

var ng_plus_unlocked := false
## Whether the player left New Game+ switched on; remembered across launches.
var ng_plus_enabled := false
var selected_challenge := "none"
## Acts (mode indices) already completed; clearing all three unlocks NG+.
var cleared_acts: Array = []
## Unlocked equipment, one bit per (mode, slot): bit = mode * EQUIP_SLOTS + slot.
var equipment_unlocked := 0
## Best score and rank per act (mode index). Populated by `record_run`.
var best_score: Dictionary = {}
var best_rank: Dictionary = {}

var _active := "none"
var _started_at := 0
var _failed := false
var _fail_reason := ""
var last_success := false
var last_name := ""
var last_record := false
var last_reason := ""


func _ready() -> void:
	load_from_disk()
	if not ng_plus_unlocked:
		ng_plus_enabled = false
	GameState.ng_plus = ng_plus_enabled


func load_from_disk() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	ng_plus_unlocked = cfg.get_value("progress", "ng_plus_unlocked", ng_plus_unlocked)
	ng_plus_enabled = cfg.get_value("progress", "ng_plus_enabled", ng_plus_enabled)
	selected_challenge = cfg.get_value("progress", "selected_challenge", selected_challenge)
	cleared_acts = cfg.get_value("progress", "cleared_acts", cleared_acts)
	equipment_unlocked = cfg.get_value("progress", "equipment_unlocked", equipment_unlocked)
	best_score = cfg.get_value("progress", "best_score", best_score)
	best_rank = cfg.get_value("progress", "best_rank", best_rank)
	_reconcile_equipment()


## Older saves could mark an act cleared without unlocking its first equipment
## slot (the menu used to do it by hand). Repair that on load without writing.
func _reconcile_equipment() -> void:
	for mode in cleared_acts:
		equipment_unlocked |= _equip_bit(int(mode), 0)


func save_to_disk() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "ng_plus_unlocked", ng_plus_unlocked)
	cfg.set_value("progress", "ng_plus_enabled", ng_plus_enabled)
	cfg.set_value("progress", "selected_challenge", selected_challenge)
	cfg.set_value("progress", "cleared_acts", cleared_acts)
	cfg.set_value("progress", "equipment_unlocked", equipment_unlocked)
	cfg.set_value("progress", "best_score", best_score)
	cfg.set_value("progress", "best_rank", best_rank)
	cfg.save(PATH)


func challenge() -> Dictionary:
	for c in CHALLENGES:
		if c["id"] == selected_challenge:
			return c
	return CHALLENGES[0]


func select_challenge(id: String) -> void:
	selected_challenge = id
	save_to_disk()
	changed.emit()


## Records that an act was completed; unlocks NG+ once all three are done.
## Clearing an act also earns its first equipment slot, independently of the
## optional challenge; the second slot is the New Game+ reward.
func mark_act_cleared(mode: int) -> void:
	var first_time := not cleared_acts.has(mode)
	if first_time:
		cleared_acts.append(mode)
		save_to_disk()
		changed.emit()
	unlock_equipment(mode, 0)
	if GameState.ng_plus:
		unlock_equipment(mode, 1)
	if cleared_acts.size() >= 3:
		unlock_ng_plus()


func all_acts_cleared() -> bool:
	return cleared_acts.size() >= 3


func unlock_ng_plus() -> void:
	if ng_plus_unlocked:
		return
	ng_plus_unlocked = true
	save_to_disk()
	changed.emit()


## Switches New Game+ on or off and remembers the choice for the next launch.
func set_ng_plus(on: bool) -> void:
	ng_plus_enabled = on and ng_plus_unlocked
	GameState.ng_plus = ng_plus_enabled
	save_to_disk()
	changed.emit()


## Records a finished run's score/rank for an act and reports whether it is a
## new best. Returns true on a new record.
func record_run(mode: int, score: int, rank: String) -> bool:
	var key := str(mode)
	var previous: int = int(best_score.get(key, 0))
	var is_record := score > previous
	last_record = is_record
	if is_record:
		best_score[key] = score
		best_rank[key] = rank
		save_to_disk()
		changed.emit()
	return is_record


func best_for(mode: int) -> Dictionary:
	var key := str(mode)
	return {"score": int(best_score.get(key, 0)), "rank": String(best_rank.get(key, "-"))}


func _equip_bit(mode: int, slot: int) -> int:
	return 1 << (mode * EQUIP_SLOTS + slot)


func unlock_equipment(mode: int, slot: int) -> void:
	var bit := _equip_bit(mode, slot)
	if equipment_unlocked & bit:
		return
	equipment_unlocked |= bit
	save_to_disk()
	changed.emit()


func has_equipment(mode: int, slot: int) -> bool:
	return (equipment_unlocked & _equip_bit(mode, slot)) != 0


func equipment_description(mode: int, slot: int) -> String:
	if mode == GameState.Mode.TPS:
		if slot == 0:
			return "Déplacement 20 % plus rapide"
		return "Détection ennemie réduite de 30 %"
	if mode == GameState.Mode.RAIL:
		if slot == 0:
			return "Deux projectiles en jeu"
		return "Assistance de visée 40 %"
	if slot == 0:
		return "Adhérence routière +15 %"
	return "Boost prolongé de 40 %"


## Arms the selected challenge for a fresh run.
func begin() -> void:
	_active = selected_challenge
	_started_at = Time.get_ticks_msec()
	_failed = false
	_fail_reason = ""
	# A run that never reaches `record_run` (act 3 out of time) must not keep
	# showing the previous run's "new record" banner on the results screen.
	last_record = false
	last_reason = ""


func is_active() -> bool:
	return _active != "none"


func elapsed() -> float:
	return (Time.get_ticks_msec() - _started_at) / 1000.0


## Remaining seconds for the timed challenge (negative when over).
func time_left() -> float:
	return TIME_LIMIT - elapsed()


## Marks the armed challenge as failed (only the first reason is kept).
func fail(reason: String) -> void:
	if _active == "none" or _failed:
		return
	_failed = true
	_fail_reason = reason
	challenge_failed.emit(reason)


## Evaluates the armed challenge at the end of a run.
func evaluate() -> Dictionary:
	last_name = challenge()["name"]
	var success := true
	var reason := ""
	match _active:
		"no_damage":
			success = not _failed
			reason = _fail_reason if _failed else ""
		"time":
			if _failed:
				success = false
				reason = _fail_reason
			elif elapsed() > TIME_LIMIT:
				success = false
				reason = "trop lent"
		"accuracy":
			if _failed:
				success = false
				reason = _fail_reason
			elif Score.shots_fired == 0:
				success = false
				reason = "aucun tir"
			else:
				success = Score.accuracy_ratio() >= 0.9
				if not success:
					reason = "précision insuffisante"
		"explorer":
			if _failed:
				success = false
				reason = _fail_reason
			else:
				success = Score.alternate_paths > 0
				if not success:
					reason = "aucun itinéraire alternatif"
	last_success = success
	last_reason = reason
	return {"success": success, "name": last_name, "reason": reason}
