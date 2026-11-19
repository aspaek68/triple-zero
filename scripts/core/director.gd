class_name Director
extends Object
## Shared staging helpers for the three acts: it wires the dynamic weather and
## the replay highlight the same way everywhere, so the modes only describe
## what to film and where the camera is.


## Adds a Weather node under `mode`, follows `focus`, shows the current
## preset on the HUD, and eases to a random preset after a while when the
## dynamic option is on. Returns the weather node so the mode can cycle it.
static func spawn_weather(mode: Node3D, focus: Node3D, hud: Hud) -> Weather:
	var weather := Weather.new()
	weather.follow = focus
	weather.preset = clampi(Options.weather, 0, Weather.ORDER.size() - 1)
	mode.add_child(weather)
	weather.changed.connect(_on_weather_changed.bind(hud, weather))
	_show_weather(hud, weather.name(), weather.wetness())
	if Options.weather_dynamic:
		var timer := Timer.new()
		timer.wait_time = 45.0
		timer.autostart = true
		# A manual cycle (`cycle_weather`, the weather action) sets
		# `weather_dynamic` off, but this timer kept ticking and changed the sky
		# anyway. Check the option on every tick. The callable is owned by the
		# timer, not by the weather node, so guard the bound node too.
		timer.timeout.connect(_auto_weather.bind(weather))
		mode.add_child(timer)
	return weather


## One tick of the dynamic weather timer. It stops changing the sky as soon as
## the player takes manual control (`Options.weather_dynamic` false). The
## parameter stays untyped: a typed `Weather` would log a freed-instance error
## if a tick ever arrived after the node was freed.
static func _auto_weather(weather) -> void:
	if not Options.weather_dynamic or not is_instance_valid(weather):
		return
	weather.cycle()


## Signal handler for `Weather.changed`; `hud` and `weather` are bound at
## connect time, so the lambda-capture lifetime issue cannot happen here.
static func _on_weather_changed(_preset_name: String, hud: Hud, weather: Weather) -> void:
	if not is_instance_valid(weather) or not is_instance_valid(hud):
		return
	_show_weather(hud, weather.name(), weather.wetness())


static func _show_weather(hud: Hud, label: String, wet: float) -> void:
	if hud == null:
		return
	var grip := Loc.t(" (adhérence réduite)") if wet >= 0.5 else ""
	hud.set_extra(Loc.t("Météo : %s%s") % [Loc.t(label), grip])


## Adds a Replay recorder under `mode` and returns it. The mode registers
## actors with `track()` and calls `sample()` each physics frame.
static func spawn_replay(mode: Node) -> Replay:
	var replay := Replay.new()
	mode.add_child(replay)
	return replay


## Plays the highlight: it freezes the act, films the ghosts, then unfreezes
## and calls `on_done`. Returns false when there is nothing to show.
static func start_replay(mode: Node, replay: Replay, hud: Hud, on_done: Callable) -> bool:
	if not Options.replay_enabled or not replay.has_footage():
		return false
	var reticle_was_on: bool = hud != null and hud.reticle_visible()
	if hud:
		hud.set_extra("Ralenti — R ou RETOUR pour passer")
		hud.set_reticle_visible(false)
	replay.finished.connect(func():
		mode.get_tree().paused = false
		if hud:
			hud.set_extra("")
			hud.set_reticle_visible(reticle_was_on)
		if on_done.is_valid():
			on_done.call()
	)
	if not replay.play(mode):
		if hud:
			hud.set_extra("")
			hud.set_reticle_visible(reticle_was_on)
		return false
	mode.get_tree().paused = true
	return true


## Cycles the weather preset and persists the choice.
static func cycle_weather(weather: Weather) -> void:
	if weather == null:
		return
	weather.cycle()
	Options.weather = weather.preset
	Options.weather_dynamic = false
	Options.save_to_disk()
