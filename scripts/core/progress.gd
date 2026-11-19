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
## Armed challenge that does not apply to the current act (see `begin()`).
var _skipped := ""
## Play time of the current run, in seconds. It is accumulated per frame
## instead of read off the wall clock: a pause or a mid-run replay froze the
## game, but the timed challenge kept losing seconds.
var _elapsed := 0.0
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


## Counts play time only: `_process` is skipped while the tree is paused (pause
## menu, mid-run replay), which the wall clock did not.
func _process(delta: float) -> void:
	if _active == "none" or get_tree().paused:
		return
	_elapsed += delta


func load_from_disk() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	ng_plus_unlocked = _read_bool(cfg, "progress", "ng_plus_unlocked", ng_plus_unlocked)
	ng_plus_enabled = _read_bool(cfg, "progress", "ng_plus_enabled", ng_plus_enabled)
	var challenge: Variant = cfg.get_value("progress", "selected_challenge", selected_challenge)
	selected_challenge = challenge if challenge is String and _has_challenge(challenge) else "none"
	cleared_acts = _sanitize_acts(cfg.get_value("progress", "cleared_acts", cleared_acts))
	equipment_unlocked = _read_int(cfg, "progress", "equipment_unlocked",
		equipment_unlocked, 0, (1 << (3 * EQUIP_SLOTS)) - 1)
	best_score = _sanitize_dict(cfg.get_value("progress", "best_score", best_score), true)
	best_rank = _sanitize_dict(cfg.get_value("progress", "best_rank", best_rank), false)
	_reconcile_equipment()


## `progress.cfg` can be edited by hand (or left half-written): never trust the
## stored types, or a bad value would crash a typed assignment on launch.
func _read_bool(cfg: ConfigFile, section: String, key: String, fallback: bool) -> bool:
	var v: Variant = cfg.get_value(section, key, fallback)
	return v if v is bool else fallback


func _read_int(cfg: ConfigFile, section: String, key: String, fallback: int,
		lo: int, hi: int) -> int:
	var v: Variant = cfg.get_value(section, key, fallback)
	if v is int or v is float:
		return clampi(int(v), lo, hi)
	return fallback


func _has_challenge(id: String) -> bool:
	for c in CHALLENGES:
		if c["id"] == id:
			return true
	return false


## Keeps only mode indices 0..2, each once.
func _sanitize_acts(v: Variant) -> Array:
	var out: Array = []
	if not v is Array:
		return out
	for a in v:
		if not (a is int or a is float):
			continue
		var mode := int(a)
		if mode >= 0 and mode < 3 and not out.has(mode):
			out.append(mode)
	return out


## Keeps only entries keyed "0".."2" with the expected value type (int score,
## String rank).
func _sanitize_dict(v: Variant, ints: bool) -> Dictionary:
	var out := {}
	if not v is Dictionary:
		return out
	for k in v:
		if not (k is String and k.is_valid_int()):
			continue
		var mode := int(k)
		if mode < 0 or mode >= 3:
			continue
		var value: Variant = v[k]
		if ints and (value is int or value is float):
			out[k] = int(value)
		elif not ints and value is String:
			out[k] = value
	return out


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


func _challenge_name(id: String) -> String:
	for c in CHALLENGES:
		if c["id"] == id:
			return c["name"]
	return CHALLENGES[0]["name"]


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


## Arms the selected challenge for a fresh run. A challenge that needs a shot
## (accuracy) cannot be judged in the driving act, so it is skipped there
## instead of failing for a reason the player cannot avoid.
func begin() -> void:
	_skipped = "" if challenge_applies(GameState.mode) else selected_challenge
	_active = "none" if _skipped != "" else selected_challenge
	_elapsed = 0.0
	_failed = false
	_fail_reason = ""
	# A run that never reaches `record_run` (act 3 out of time) must not keep
	# showing the previous run's "new record" banner on the results screen.
	last_record = false
	last_reason = ""


## True when the armed challenge can be judged in `mode`. "Tireur d'élite"
## needs shots, and the driving act fires none.
func challenge_applies(mode: int) -> bool:
	return not (selected_challenge == "accuracy" and mode == GameState.Mode.DRIVE)


## True when the armed challenge was skipped for this run (see `begin()`).
func is_skipped() -> bool:
	return _skipped != ""


func is_active() -> bool:
	return _active != "none"


func elapsed() -> float:
	return _elapsed


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


## Fails the armed challenge only when it is `id`. Damage in the acts must not
## sink an unrelated goal: a rival ram used to fail "Tireur d'élite" even at
## 100 % accuracy, and a civilian hit failed "Explorateur" on a route run.
func fail_for(id: String, reason: String) -> void:
	if _active != id or _failed:
		return
	_failed = true
	_fail_reason = reason
	challenge_failed.emit(reason)


## Evaluates the armed challenge at the end of a run.
func evaluate() -> Dictionary:
	# A skipped challenge has no verdict: report it as such instead of a free
	# pass or an unavoidable failure.
	if _skipped != "":
		last_name = _challenge_name(_skipped)
		last_success = true
		last_reason = ""
		return {"success": true, "skipped": true, "name": last_name, "reason": ""}
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
