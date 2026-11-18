extends Node
## Autoload: tiny FR/EN localisation layer.
##
## The French string is the key, so a missing entry falls back to the original
## text instead of showing a raw identifier. Dynamic strings ("Zone %d — %d
## hostiles") are translated by pattern, which lets the modes keep formatting
## their own text and still be localised.
##
## The language lives in `Options.language` so it is persisted with the rest of
## the settings; `set_language()` updates it, saves, and emits `changed`.

signal changed

const LANGS: Array = ["fr", "en"]
const NAMES := {"fr": "Français", "en": "English"}

## Exact French -> English entries (UI chrome and static gameplay lines).
const EN := {
	# ---------------------------------------------------------------- menu
	"Trois actes. Trois façons de jouer. — Hommage au jeu d'action 90s":
		"Three acts. Three ways to play. — A tribute to 90s action games",
	"Manette : D-pad/stick naviguer • A valider • B retour":
		"Gamepad: D-pad/stick navigate • A confirm • B back",
	"Clavier : flèches naviguer • Entrée valider":
		"Keyboard: arrows navigate • Enter confirm",
	"ÉDITEUR DE NIVEAU (acte 3)": "LEVEL EDITOR (act 3)",
	"ÉDITEUR DE NIVEAU": "LEVEL EDITOR",
	"Outil : nœuds": "Tool: nodes",
	"Outil : props": "Tool: props",
	"Type de prop →": "Prop type →",
	"Nouveau": "New",
	"Charger": "Load",
	"Enregistrer": "Save",
	"Ajouter un nœud": "Add node",
	"Supprimer le dernier": "Delete last",
	"Tester l'acte 3": "Test act 3",
	"nœuds du circuit": "track nodes",
	"props (%s)": "props (%s)",
	"OPTIONS": "OPTIONS",
	"activée": "on",
	"désactivée": "off",
	"Nouvelle partie+ : terminez les trois actes":
		"New Game+: clear all three acts",
	"débloqué": "unlocked",
	"verrouillé": "locked",
	"Conduite": "Driving",
	"RÉSULTATS": "RESULTS",
	"ACTE RÉUSSI": "ACT PASSED",
	"ACTE ÉCHOUÉ": "ACT FAILED",
	"touché": "hit",
	"trop lent": "too slow",
	"aucun tir": "no shots fired",
	"précision insuffisante": "accuracy too low",
	"aucun itinéraire alternatif": "no alternate route",
	"temps écoulé": "time ran out",
	"  •  NOUVEAU RECORD !": "  •  NEW RECORD!",
	"réussi": "passed",
	"échoué": "failed",
	"  •  Nouvelle partie+ débloquée": "  •  New Game+ unlocked",
	"REJOUER L'ACTE": "REPLAY ACT",
	"ACTE SUIVANT": "NEXT ACT",
	"FERMER LES RÉSULTATS": "CLOSE RESULTS",

	# ----------------------------------------------------------------- pause
	"PAUSE": "PAUSE",
	"REPRENDRE": "RESUME",
	"RECOMMENCER": "RESTART",
	"MENU PRINCIPAL": "MAIN MENU",
	"QUITTER LE JEU": "QUIT GAME",

	# ------------------------------------------------------------ mode info
	"ACTE 1 — TOUR": "ACT 1 — TOWER",
	"Infiltration et action à la troisième personne":
		"Third-person stealth and action",
	"ACTE 2 — AÉROPORT": "ACT 2 — AIRPORT",
	"Rail shooter : viser vite, épargner les civils":
		"Rail shooter: aim fast, spare the civilians",
	"ACTE 3 — VILLE": "ACT 3 — CITY",
	"Conduite arcade : poursuivre et foncer":
		"Arcade driving: chase and dash",

	# ------------------------------------------------------------ challenges
	"Partie libre": "Free run",
	"Sans contrainte": "No restrictions",
	"Sans dégâts": "No damage",
	"Terminer sans être touché": "Finish without being hit",
	"Contre-la-montre": "Time attack",
	"Terminer en moins de 4 min": "Finish in under 4 min",
	"Tireur d'élite": "Sharpshooter",
	"Précision d'au moins 90 %": "At least 90% accuracy",
	"Explorateur": "Explorer",
	"Emprunter un itinéraire alternatif": "Take an alternate route",

	# ------------------------------------------------------------ equipment
	"Déplacement 20 % plus rapide": "20% faster movement",
	"Détection ennemie réduite de 30 %": "Enemy detection reduced by 30%",
	"Adhérence routière +15 %": "Road grip +15%",
	"Boost prolongé de 40 %": "Boost lasts 40% longer",
	"Deux projectiles en jeu": "Two projectiles in flight",
	"Assistance de visée 40 %": "40% aim assist",

	# -------------------------------------------------------------- options
	"JEU": "GAME",
	"Difficulté (0 facile → 2 difficile)": "Difficulty (0 easy → 2 hard)",
	"Assistance de visée": "Aim assist",
	"MANETTE": "GAMEPAD",
	"Sensibilité sticks": "Stick sensitivity",
	"Zone morte": "Dead zone",
	"Vibration": "Vibration",
	"oui": "yes",
	"non": "no",
	"SOURIS ET ÉCRAN": "MOUSE AND SCREEN",
	"Sensibilité souris": "Mouse sensitivity",
	"Taille du réticule": "Reticle size",
	"Secousses caméra": "Camera shake",
	"Flou de mouvement": "Motion blur",
	"Effet post-FX (vignette + grain)": "Post-FX (vignette + grain)",
	"Inverser l'axe vertical": "Invert vertical axis",
	"Sous-titres": "Subtitles",
	"MISE EN SCÈNE": "STAGING",
	"Météo (0 clair, 1 pluie, 2 orage, 3 brouillard)":
		"Weather (0 clear, 1 rain, 2 storm, 3 fog)",
	"Météo dynamique": "Dynamic weather",
	"Ralenti (replay)": "Slow motion (replay)",
	"CONTRÔLES (clavier)": "CONTROLS (keyboard)",
	"Avancer": "Forward",
	"Reculer": "Back",
	"Gauche": "Left",
	"Droite": "Right",
	"Tirer": "Shoot",
	"Sauter": "Jump",
	"Couvert": "Cover",
	"Interagir": "Interact",
	"Pause": "Pause",
	"Météo": "Weather",
	"Ralenti": "Slow motion",
	"RALENTI": "SLOW MOTION",
	"● RALENTI — R pour passer": "● SLOW MOTION — R to skip",
	"Réinitialiser les touches": "Reset key bindings",
	"AUDIO": "AUDIO",
	"Volume général": "Master volume",
	"Musique": "Music",
	"Effets": "Effects",
	"RETOUR": "BACK",
	"Appuyez sur une touche...": "Press a key...",
	"Français": "French",

	# ------------------------------------------------------------ HUD / acts
	"Objectif : sécuriser les trois zones":
		"Objective: secure the three zones",
	"Objectif : sécuriser les trois zones, puis rejoindre l'extraction":
		"Objective: secure the three zones, then reach extraction",
	"ZQSD bouger • Souris viser • Clic/Space tirer • Ctrl couvert • F recharger • C météo • R replay":
		"WASD move • Mouse aim • Click/Space fire • Ctrl cover • F reload • C weather • R replay",
	"Stick G bouger • Stick D viser • X/LT tirer • B couvert • LB recharger • Y météo • Back replay":
		"L stick move • R stick aim • X/LT fire • B cover • LB reload • Y weather • Back replay",
	"Objectif : couvrir l'évacuation": "Objective: cover the evacuation",
	"Objectif : couvrir l'évacuation, épargner les civils":
		"Objective: cover the evacuation, spare the civilians",
	"Souris viser • Clic/Space tirer • Rouge = menaces • C météo • R replay":
		"Mouse aim • Click/Space fire • Red = threats • C weather • R replay",
	"Stick D viser • X/RT tirer • Rouge = menaces • Y météo • Back replay":
		"R stick aim • X/RT fire • Red = threats • Y weather • Back replay",
	"Objectif : franchir les portes avant la fin du chrono":
		"Objective: clear the gates before time runs out",
	"ZQSD conduire • Espace frein à main • Maj boost • C météo • R replay":
		"WASD drive • Space handbrake • Shift boost • C weather • R replay",
	"Stick G conduire • B frein à main • RT boost • Y météo • Back replay":
		"L stick drive • B handbrake • RT boost • Y weather • Back replay",
	"ZQSD / WASD : se deplacer": "WASD / ZQSD: move",
	"Souris : viser    Clic gauche : tirer": "Mouse: aim    Left click: fire",
	"Maj : sprinter    F : recharger": "Shift: sprint    F: reload",
	"C : meteo    R : replay    Echap : menu": "C: weather    R: replay    Esc: menu",

	# ------------------------------------------------------------ act 1 text
	"CIVIL PERDU — la zone a été abandonnée":
		"CIVILIAN LOST — the area was abandoned",
	"SENTINELLE NEUTRALISEE": "SENTINEL NEUTRALISED",
	"SENTINELLE : CHARGE": "SENTINEL: CHARGING",
	"SENTINELLE LOURDE": "HEAVY SENTINEL",
	"SENTINELLE LOURDE - survivez et neutralisez-la":
		"HEAVY SENTINEL - survive and neutralise it",
	"ALARME — tous les ennemis sont maintenant en alerte":
		"ALARM — all enemies are now alert",
	"SIRÈNE active — renforts imminents":
		"SIREN active — reinforcements imminent",
	"COUPURE DE COURANT — visibilité réduite":
		"POWER CUT — reduced visibility",
	"ASCENSEUR BLOQUÉ — passage coupé": "ELEVATOR BLOCKED — route cut",
	"FUMÉE — visibilité réduite": "SMOKE — reduced visibility",
	"EFFONDREMENT — planquez-vous !": "COLLAPSE — take cover!",
	"EMBUSCADE — hostiles sur le flanc !": "AMBUSH — hostiles on the flank!",
	"RECHARGEMENT...": "RELOADING...",
	"CHARGE IMMINENTE": "CHARGE IMMINENT",
	"Zones sécurisées — rejoignez le point d'extraction (balise verte)":
		"Zones secured — reach the extraction point (green beacon)",
	"EXTRACTION OUVERTE": "EXTRACTION OPEN",
	"ITINÉRAIRE ALTERNATIF — coursive ouest — bonus":
		"ALTERNATE ROUTE — west catwalk — bonus",
	"ITINÉRAIRE ALTERNATIF — coursive est — bonus":
		"ALTERNATE ROUTE — east catwalk — bonus",
	"ITINÉRAIRE ALTERNATIF — bonus": "ALTERNATE ROUTE — bonus",

	# ------------------------------------------------------------ act 2/3 text
	"MATÉRIEL RÉCUPÉRÉ": "EQUIPMENT RECOVERED",
	"COMMUNICATIONS RÉTABLIES": "COMMUNICATIONS RESTORED",
	"RACCOURCI — itinéraire alternatif": "SHORTCUT — alternate route",
	"PRÊT": "READY",
	"Ralenti — R ou RETOUR pour passer":
		"Slow motion — R or BACK to skip",
	" (adhérence réduite)": " (reduced grip)",

	# ---------------------------------------------------------------- weather
	"Clair": "Clear",
	"Pluie": "Rain",
	"Orage": "Storm",
	"Brouillard": "Fog",
}

## Dynamic templates (French key -> English template). `%d`, `%s`, `%3d`,
## `%4.1f` and `%%` are supported; the values are carried over unchanged.
const EN_TEMPLATES := {
	"Défi : %s — %s": "Challenge: %s — %s",
	"%d nœuds • %d props\nOutil : %s\nClic : ajouter/déplacer • Clic droit : supprimer":
		"%d nodes • %d props\nTool: %s\nClick: add/move • Right click: delete",
	"Actes terminés : %d / 3": "Acts cleared: %d / 3",
	"NOUVELLE PARTIE+ : %s": "NEW GAME+ : %s",
	"Équipement %s : %s — %s": "Equipment %s: %s — %s",
	"Débloqué en terminant l'acte — 2e emplacement en Nouvelle Partie+":
		"Unlocked by clearing the act — 2nd slot in New Game+",
	"Score total : %d\nPrécision : %d%%\nCivils sauvés : %d   perdus : %d\nMatériel récupéré : %d   comms rétablies : %d\nItinéraires alternatifs : %d\nRang : %s":
		"Total score: %d\nAccuracy: %d%%\nCivilians saved: %d   lost: %d\nEquipment recovered: %d   comms restored: %d\nAlternate routes: %d\nRank: %s",
	"Meilleur : %d (%s)%s": "Best: %d (%s)%s",
	"Défi « %s » : %s%s": "Challenge \"%s\": %s%s",
	"Actes terminés : %d / 3%s\nChoisissez un acte pour rejouer":
		"Acts cleared: %d / 3%s\nChoose an act to replay",
	"Manette détectée : %s": "Gamepad detected: %s",
	"Langue : %s": "Language: %s",
	"MUNITIONS %d / %d": "AMMO %d / %d",
	"Secondaires : %s": "Secondary: %s",
	"%d civil(s) retrouvé(s)": "%d civilian(s) found",
	"%d équipement(s) récupéré(s)": "%d equipment recovered",
	"%d comm(s) rétabli(s)": "%d comms restored",
	"Score %d • Précision %d%% • Rang %s%s": "Score %d • Accuracy %d%% • Rank %s%s",
	" • Défi : %s": " • Challenge: %s",
	" (%d s)": " (%d s)",
	"Météo : %s%s": "Weather: %s%s",
	"CIVIL SECOURU — %d/3": "CIVILIAN RESCUED — %d/3",
	"Zone %d — %d hostiles": "Zone %d — %d hostiles",
	"RENFORTS — %d hostiles supplémentaires":
		"REINFORCEMENTS — %d extra hostiles",
	"INTÉGRITÉ %d%%": "INTEGRITY %d%%",
	"Secteur %s — protégez les civils": "Sector %s — protect the civilians",
	"Secteur RUE — protégez les civils": "Sector STREET — protect the civilians",
	"Secteur HALL — protégez les civils": "Sector HALL — protect the civilians",
	"Secteur PISTE — protégez les civils": "Sector RUNWAY — protect the civilians",
	"Vitesse %3d km/h • Porte %d/%d • Temps %4.1fs • Boost %s • Poursuivants %d":
		"Speed %3d km/h • Gate %d/%d • Time %4.1fs • Boost %s • Pursuers %d",
}

var _patterns: Array = []
var _cache: Dictionary = {}
var _cache_lang := ""


func _ready() -> void:
	for key in EN_TEMPLATES:
		_patterns.append([_compile(key), EN_TEMPLATES[key]])


## Current language code, read straight from the persisted options so the
## autoload order does not matter.
func current_language() -> String:
	var code: String = Options.language
	return code if NAMES.has(code) else "fr"


func set_language(code: String) -> void:
	var next := code if NAMES.has(code) else "fr"
	if next == current_language():
		return
	Options.language = next
	Options.save_to_disk()
	_cache.clear()
	_cache_lang = next
	changed.emit()


## Cycles FR -> EN -> FR, used by the options screen.
func cycle() -> void:
	set_language("en" if current_language() == "fr" else "fr")


## Language name in its own language ("Français" / "English").
func language_name() -> String:
	return NAMES.get(current_language(), "Français")


## Translates a French string. Unknown strings are returned untouched.
func t(text: String) -> String:
	if text.is_empty() or current_language() == "fr":
		return text
	if _cache_lang != current_language():
		_cache.clear()
		_cache_lang = current_language()
	if _cache.has(text):
		return _cache[text]
	var out: String = EN.get(text, "")
	if out.is_empty() and EN_TEMPLATES.has(text):
		# Callers may translate a template first, then apply `%` themselves.
		out = EN_TEMPLATES[text]
	if out.is_empty():
		out = _translate_template(text)
	if _cache.size() > 512:
		_cache.clear()
	_cache[text] = out
	return out


func _translate_template(text: String) -> String:
	for entry in _patterns:
		var rx: RegEx = entry[0]
		var m := rx.search(text)
		if m == null:
			continue
		var caps: Array = []
		for i in m.get_group_count():
			caps.append(m.get_string(i + 1))
		return _fill(entry[1], caps)
	return text


## Turns a French template into an anchored regular expression.
func _compile(template: String) -> RegEx:
	var out := "^"
	var i := 0
	while i < template.length():
		var ch := template[i]
		if ch != "%":
			out += _escape(ch)
			i += 1
			continue
		if i + 1 < template.length() and template[i + 1] == "%":
			out += "%"
			i += 2
			continue
		var j := i + 1
		while j < template.length() and "0123456789.+- #".contains(template[j]):
			j += 1
		var conv := template[j] if j < template.length() else "s"
		match conv:
			"d", "i":
				out += "(-?\\d+)"
			"f", "g":
				out += "(-?\\d+(?:[.,]\\d+)?)"
			_:
				out += "(.*)"
		i = j + 1
	out += "$"
	var rx := RegEx.new()
	rx.compile(out)
	return rx


## Fills an English template with the captured strings, keeping their type.
func _fill(template: String, caps: Array) -> String:
	var out := ""
	var values: Array = []
	var i := 0
	var ci := 0
	while i < template.length():
		var ch := template[i]
		if ch != "%":
			out += ch
			i += 1
			continue
		if i + 1 < template.length() and template[i + 1] == "%":
			# Keep the escape: the whole template is run through `%` below.
			out += "%%"
			i += 2
			continue
		var j := i + 1
		while j < template.length() and "0123456789.+- #".contains(template[j]):
			j += 1
		var conv := template[j] if j < template.length() else "s"
		var cap: String = String(caps[ci]) if ci < caps.size() else ""
		ci += 1
		out += "%" + template.substr(i + 1, j - i - 1) + conv
		match conv:
			"d", "i":
				values.append(int(cap))
			"f", "g":
				values.append(float(cap.replace(",", ".")))
			_:
				values.append(cap)
		i = j + 1
	return out % values


func _escape(ch: String) -> String:
	if "\\.^$|?*+()[]{}".contains(ch):
		return "\\" + ch
	return ch
