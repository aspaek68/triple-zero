# AGENTS.md — notes pour les agents

Projet Godot 4.7.2 (GDScript) : remake hommage « trois jeux en un » (TPS, rail
shooter, conduite arcade). IP originale, pas de contenu sous licence.

## Build / test (headless, sans GPU)

Godot est dans `/tmp/Godot_v4.7.2-stable_linux.x86_64` (binaire Linux). Il peut
disparaître entre les sessions : le retélécharger au besoin
(`https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip`,
extraire avec `python3 -c "import zipfile; zipfile.ZipFile('godot.zip').extractall('.')"`).
Pas de GPU ni de display : le rendu offscreen (`get_viewport().get_texture()`) ne
fonctionne pas, donc la validation se fait en headless.

```bash
# Import (régénère .godot/, enregistre les class_name)
/tmp/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --import

# Lancer un mode (1 = TPS, 2 = rail, 3 = conduite) ; le jeu se ferme seul
/tmp/Godot_v4.7.2-stable_linux.x86_64 --headless --path . -- --mode=1

# Vérification fonctionnelle (personnages, arme, PBR, environnement, modes)
/tmp/Godot_v4.7.2-stable_linux.x86_64 --headless --path . res://scenes/_verify.tscn
# attendu : "VERIFY RESULT: OK"
```

Viser **0 ERROR / 0 WARNING** dans les logs pour chaque mode.

## Pièges connus

- **Cache d'import `.godot/`** : ignoré par Git. Sans lui, `load()` sur un asset
  importé (`.png`, `.wav`) logue une erreur. Les chargeurs utilisent donc un
  décodage runtime (`Image.load_from_file`, `AudioStreamWAV.load_from_file`)
  quand `.godot/imported/` est absent — voir `EnvBuilder.load_texture()` et
  `Audio._load_wav()`. Les `LANCER_*.bat` lancent `--import` avant le jeu.
- **`class_name`** : les identifiants (EnvBuilder, Character, Weapon, Hud…) ne se
  résolvent qu'après un `--import` (ils sont dans
  `.godot/global_script_class_cache.cfg`). Toujours importer avant de lancer.
- **Lambdas et durée de vie** : une lambda GDScript capture ses variables ; si
  l'objet capturé est libéré avant l'appel (minuterie de 8 s, acteur mort),
  Godot logue `Lambda capture at index 0 was freed`. Préférer une **méthode
  liée** (`callable.bind(...)`, la connexion tombe avec l'objet), un tween créé
  par le nœud (`node.create_tween()`) ou `timer.timeout.connect(obj.method)`.
- **Renderer** : le projet est en `gl_compatibility` (pas de SSAO/SSR/SSIL ni
  brouillard volumétrique). `EnvBuilder._apply_advanced_lighting()` teste
  `RenderingServer.get_current_rendering_method()` (et non le réglage projet,
  car `LANCER_QUALITE_HAUTE.bat` force `forward_plus` en ligne de commande).
- **Indentation** : tous les `.gd` utilisent des tabulations. Les patchs Python
  par chaîne exacte sont plus sûrs que des éditeurs qui convertissent en
  espaces : Godot refuse un fichier qui mélange espaces et tabulations. Après
  toute édition scriptée, `grep -nP '^ +\t|\t+ '` pour repérer les mélanges.

## Assets

Générés par `tools/gen_assets.py` (Python pur, déterministe) :
`assets/textures/*.png` (+ `*_normal.png`, `*_rough.png`, `*_ao.png`) et
`assets/audio/*.wav`. Le jeu fonctionne avec ou sans ces fichiers (repli couleur
unie / audio procédural).

**Pack CC0** : `assets/textures_cc0/` contient cinq sets ambientCG (CC0 1.0)
en 1K PNG (béton, asphalte, métal, brique, sol). `EnvBuilder._resolve_texture()`
cherche d'abord `textures_cc0/` puis `textures/`, avec `.png` puis `.jpg` ;
les scans CC0 ne sont pas teintés par la palette (`albedo_color = blanc`).
Régénérer avec `powershell -ExecutionPolicy Bypass -File
tools/fetch_cc0_textures.ps1` (provenance dans `textures_cc0/LICENSE.txt`).

**Ciel HDRI** : `assets/hdri/sky.hdr` (Poly Haven, CC0 1.0, Radiance 1K).
`tools/fetch_cc0_hdri.ps1` le télécharge et lance `tools/hdri_sun.py`, qui
décode le RGBE, trouve le pixel le plus lumineux et écrit `sun.json`
(`azimuth_deg`, `elevation_deg`, `has_sun`). `EnvBuilder` le charge en
`PanoramaSkyMaterial` et tourne le ciel de `SUN_YAW - azimut` (constante
`SUN_YAW`, partagée avec `_build_sun()`) pour que le soleil de l'image coïncide
avec le `DirectionalLight3D`. Sans fichier **ou sans cache d'import** (`.hdr`
ne se charge que par l'import) : `_build_panorama_sky()` renvoie `null` et le
ciel procédural reprend la main, sans erreur.

**Props CC0** : `assets/models_cc0/<nom>/<nom>.gltf` (Poly Haven, CC0 1.0,
glTF 1K + textures JPG) pour `barrel`, `crate`, `streetlamp`, `barrier`,
`dumpster`, `planter`. Régénérer avec `tools/fetch_cc0_models.ps1` (l'API
imbrique l'entrée 1K : `files.gltf."1k".gltf.{url,include}`).
`EnvBuilder.load_model_scene()` charge la scène entière (les modèles
multi-parties survivent), élague les variantes inutiles (`MODEL_DROP` : `_b`
pour la caisse, `_rust` pour la poubelle), puis la normalise : échelle =
`MODEL_SIZE[nom] / plus grande dimension`, centre X/Z, base à `y = 0`.
`prop_bounds(node)` donne l'AABB local (hitbox de `Destructible`, alignement au
sol des replis centrés via `_sit_on_floor`). Ordre de repli :
`models_cc0/` → `models/*.glb` → primitive.

## Structure

- `scripts/core/` — autoloads : `game_state.gd`, `options.gd`, `score.gd`,
  `progress.gd` (NG+ + défis), `audio.gd` (bus + réverb + ducking), `loc.gd`
  (FR/EN : `Loc.t("texte français")`).
- `tools/` — `gen_assets.py` (textures PNG + WAV), `gen_meshes.py` (props glTF),
  `fetch_cc0_textures.ps1` (pack CC0 ambientCG), `fetch_cc0_hdri.ps1` +
  `hdri_sun.py` (ciel CC0 + position du soleil), `fetch_cc0_models.ps1` (props
  CC0 Poly Haven). Les générateurs sont en Python pur et déterministes ;
  relancez-les après un changement.
- `assets/models/*.glb` — props glTF générés, chargés par `EnvBuilder.load_model()`
- `assets/models_cc0/<nom>/` — props CC0 Poly Haven, chargés par
  `EnvBuilder.load_model_scene()` (scène entière, normalisée)
- `assets/hdri/` — `sky.hdr` + `sun.json` + `LICENSE.txt`
- `scripts/env/` — `env_builder.gd` (monde + matériaux PBR), `character.gd`
  (humanoïde skinné : `Skeleton3D` + maillage riggé + `AnimationPlayer`),
  `weapon.gd` (fusil), `destructible.gd`, `enemy.gd`, `vfx.gd` (tracer +
  étincelle de tir).
- `scripts/modes/` — `tps.gd`, `rail.gd`, `drive.gd`. `drive.gd` construit la
  ville (`_build_city()` : immeubles texturés + bandes de fenêtres émissives,
  néons, panneaux), et des **voitures rivales** (`_build_chasers()` :
  `VehicleBody3D` qui pivotent vers le joueur ; au contact elles ralentissent le
  joueur, au boost elles explosent via `Score.register_kill()`).
- `scripts/ui/` — `menu.gd`, `hud.gd`, `options_menu.gd`, `pause_menu.gd`,
  `cinematic.gd`
  (cinématique d'intro partagée : fondu, bandes, caméra qui survole). Chaque
  acte appelle `Cinematic.play()` puis lance la musique sur le signal
  `finished` ; `is_done()` sert à verrouiller l'entrée pendant la lecture. En
  headless (pas de fenêtre, pas d'input) elle s'auto-termine en 0,2 s.
- **Pause et résultats** : `PauseMenu` (`scripts/ui/pause_menu.gd`,
  `class_name`, `extends CanvasLayer`) est créé par chaque acte après le HUD et
  ouvert par l'action `pause`. Il passe en `PROCESS_MODE_ALWAYS`, met
  `get_tree().paused = true`, mémorise le mode souris et le restaure à la
  fermeture. Boutons : reprendre, options (écran d'options en
  `PROCESS_MODE_ALWAYS`), recommencer (`reload_current_scene()` +
  `Score.reset()` + `Progress.begin()`), menu principal, quitter. Il vit sur la
  **couche 10** : un simple `Control` sous la racine 3D dessinerait *sous* le
  HUD (`Hud` est un `CanvasLayer` de couche 1) et sous la cinématique (couche
  4). L'écran de résultats du menu principal annonce acte réussi/échoué
  (`GameState.last_act_success`, positionné par chaque `_finish()`), le détail
  du défi avec sa raison d'échec (`Progress.last_reason`) et propose
  **REJOUER L'ACTE** (`GameState.mode`) ou **FERMER LES RÉSULTATS**. Menu et
  options défilent (`ScrollContainer` + `follow_focus`) pour rester utilisables
  sur une fenêtre de 900 px.
- **NG+** : `Progress.ng_plus_enabled` est persisté dans `user://progress.cfg`
  et recopié dans `GameState.ng_plus` par `Progress._ready()` (autoload chargé
  après `GameState`). Le bouton du menu passe par `Progress.set_ng_plus()`, qui
  refuse l'activation tant que les trois actes ne sont pas terminés.
- **Viseur** : `Hud` possède un `Reticle` interne (Control dessiné, en espace
  écran) partagé par les deux modes de tir. `set_reticle_visible()` l'affiche à
  la fin de l'intro ; par défaut il **suit le centre du viewport** (Acte 1), et
  `set_reticle_position()` le fixe sur le curseur (Acte 2). `reticle_kick()`
  écarte la croix au tir, `reticle_hit()` flashe le marqueur de touche,
  `set_reticle_hot()` la teinte en orange sur une cible. En Acte 1 le tir est un
  **hitscan depuis la caméra** (`_resolve_shot()`, RID du joueur exclu) avec
  l'aide à la visée en cône (`Options.aim_tolerance()`, contrôle de ligne de
  vue) : le projectile ne part plus du torse, donc il tombe sur la croix. En
  Acte 2 la visée reste en espace écran (`_aim` + `_screen_distance`).
  **Retour de tir** : `Vfx` (`scripts/env/vfx.gd`, `class_name Vfx`) dessine un
  tracer fin du canon (`Weapon.muzzle()`) au point d'impact et une étincelle
  orientée par la normale. `_resolve_shot()` renvoie désormais un dictionnaire
  `{hit, point, normal, surface}` ; `_fire()` s'en sert pour le tracer/la
  étincelle avant `Score.register_shot(shot["hit"])`. Les deux effets sont
  *unshaded*, sans ombre, se fondent et `queue_free` en ~0,15 s (tweens liés au
  nœud, donc pas de fuite). Un tir dans le vide garde le tracer vers un point
  lointain, sans étincelle. La **marque d'impact** (et le sang au sol) est un
  `QuadMesh` à dégradé radial dont le `+Z` suit la normale de la surface, avec
  un tween **lié au nœud** qui l'efface en 8 s : ce n'est **pas** un `Decal`
  (le décalque se projetait en carré noir à cause de son axe local `-Y`, et il
  n'existe pas en `gl_compatibility`).
  `Director.start_replay()` masque le viseur pendant le ralenti et le restaure
  à la fin (utile aussi en Acte 3, où il n'était jamais affiché).
- `scenes/` — `main.tscn` (menu), `_verify.tscn` (contrôle fonctionnel).

## Assets générés

- Textures : `python3 tools/gen_assets.py --size 1024` écrit albédo + normale +
  rugosité + occlusion (1024 px) dans `assets/textures/`. En 1024 la génération
  prend ~10 min (Python pur, bruit fbm par pixel) : c'est normal. `--only <nom>`
  régénère une seule famille.
- Maillages de repli : `python3 tools/gen_meshes.py` écrit des `.glb` glTF 2.0
  dans `assets/models/`. Il **ne remplace pas** les fichiers existants (donc pas
  les modèles artistiques de `gen_models.py`) sans `--force`. L'exportateur est fait maison (`json` + `struct`) : gardez
  `ARRAY_BONES`/`ARRAY_WEIGHTS` hors sujet ici, mais rappelez-vous que les
  **indices** doivent référencer des sommets (pas des floats) et que chaque quad
  doit être triangulé explicitement (`base, base+1, base+2` puis `base, base+2,
  base+3`) — une bande de triangles ne convient pas à Godot.
- Chargement : `EnvBuilder.load_model()` passe par `ResourceLoader` quand le
  cache d'import existe, sinon par `GLTFDocument.append_from_file()` au runtime,
  ce qui évite toute erreur sur un clone frais. Repli sur une primitive si le
  fichier manque.
- Audio : `AudioStreamRandomizer` pour varier chaque tir, bus `Music`/`SFX`
  (réverbération sur SFX, EQ sur Music), `duck()` baisse la musique sous les
  explosions. Les voix sont plafonnées (`MAX_VOICES`). En **headless** le
  driver audio est `Dummy` : `Audio` construit les bus mais ne joue rien
  (`_silent`), sinon les playbacks restent référencés par l'`AudioServer` au
  `--quit-after` et Godot logue un faux « ObjectDB instances were leaked ».


## Personnages (skinning procédural)

`Character` construit à l'exécution un `Skeleton3D` (root/hips/spine/chest/head,
bras et jambes en 3 os) et un `ArrayMesh` skinné : chaque boîte de membre est
pondérée à 100 % sur un os (skinning rigide). Points d'API à respecter :

- `ARRAY_BONES` doit contenir **4 indices par sommet** et `ARRAY_WEIGHTS`
  4 poids (sinon `add_surface_from_arrays` échoue) ;
- les pistes d'animation d'os utilisent `Animation.TYPE_ROTATION_3D` avec le
  chemin `NodePath(":nom_os")` (relatif au `Skeleton3D`), insérées via
  `rotation_track_insert_key` ;
- le `AnimationPlayer` est **enfant du `Skeleton3D`** ; on joue les clips par nom
  avec fondu (`play(nom, blend)`) et on règle `speed_scale` pour la cadence ;
- le fusil est attaché à un `BoneAttachment3D` sur l'os `hand_r` ;
- matériau du corps : `vertex_color_use_as_albedo = true` (une couleur par partie),
  le flash de dégât passe par l'émission.
- **variantes** : `Character.make(clothes, accent, heavy, variant)` accepte
  `rifleman` (défaut), `heavy`, `scout`, `elite`, `civilian`. Chaque variante
  ajoute sa silhouette : casque, visière émissive (`BoneAttachment3D` sur `head`),
  gilet, plaques d'épaule, genouillères, sac. `Enemy._pick_variant()` choisit la
  variante (les lourds sont toujours `heavy`, la NG+ peut sortir des `elite`).
- **micro-détail** : `tools/gen_assets.py --only fabric` génère
  `fabric.png` + `_normal` + `_rough` + `_ao` (motif tissé) ; `character.gd`
  l'applique en albédo/normale légère si le fichier existe.

## Météo, replay, éditeur (P16)

- **Météo** : `class_name Weather extends Node3D` (`scripts/env/weather.gd`). Un
  mode le crée via `Director.spawn_weather(mode, focus, hud)` ; il cherche le
  `WorldEnvironment` et le `Sun` **chez son parent** (pas sous lui-même), d'où
  le `get_parent()` dans `_find_environment()`/`_find_sun()`. `set_preset(i, t)`
  glisse vers le preset en `t` secondes ; `wetness()` (0..1) sert à réduire
  l'adhérence (`drive._apply_grip()` règle `wheel_friction_slip`). Presets :
  0 clair, 1 pluie, 2 orage, 3 brouillard. `changed` met à jour le HUD.
  Le ciel peut être **procédural** ou **HDRI** : `_find_sky_material()` renvoie
  `Material` (Godot 4 n'a **pas** de type `SkyMaterial`), puis `_procedural` /
  `_pano` sont des casts. Sur HDRI la météo ne repeint pas le panorama :
  `sky_energy` règle `energy_multiplier` et `sky_affect` laisse le brouillard
  teinter le fond. `_capture()` relit l'état courant pour une transition douce.
- **Replay** : `class_name Replay extends Node` (`scripts/core/replay.gd`). Le
  mode appelle `track(node, couleur, taille)` pour chaque acteur, puis
  `sample()` à chaque `_physics_process`. Le buffer garde `MAX_FRAMES`
  transforms (pas de nœuds) ; `_columns` retient la plus large ligne vue pour
  que des acteurs ajoutés en cours de partie aient leur fantôme. `play(parent)`
  construit fantômes + caméra + bandes noires, puis `finished`. `process_mode =
  PROCESS_MODE_ALWAYS` car la lecture tourne pendant que l'arbre est **en pause**
  (`Director.start_replay` met `get_tree().paused = true` et le relâche à la
  fin). Un acteur en cours de partie peut disparaître : on garde sa dernière
  transform valide dans `_last`. La légende du ralenti passe par `Loc.t()`
  (`● RALENTI — R pour passer`, ou `RALENTI` si les sous-titres sont coupés).
- **Director** (`scripts/core/director.gd`, `extends Object`) : câblage commun
  aux trois actes — `spawn_weather`, `spawn_replay`, `start_replay`,
  `cycle_weather`. Les modes ne font que décrire quoi filmer et où est la
  caméra.
- **Éditeur** : `scripts/ui/level_editor.gd` (`extends Control`, vue de dessus)
  édite `LevelData` (autoload `scripts/core/level_data.gd`, fichier
  `user://level.json`). `LevelData._ready()` charge le niveau au démarrage ;
  `active_path(default)` renvoie le tracé perso s'il existe (>= 2 nœuds), sinon
  celui du mode. `drive.gd` lit `_path = LevelData.active_path(PATH)` et pose
  les props enregistrés. Le bouton du menu charge le script via `load()` et
  l'ajoute en enfant (pas de `.tscn`). Ses libellés et sa ligne d'état passent
  par `Loc.t()` ; **Tester l'acte 3** rejoue le chemin de lancement du menu
  (`GameState.mode`, `Score.reset()`, `Progress.begin()`, `Audio.stop_music()`)
  avant de charger la scène, sinon l'écran de résultats afficherait la partie
  précédente.
- **Entrées** : actions `weather` (C / Y) et `replay` (R / Back) déclarées dans
  `game_state.gd` (`_ensure_input_actions`). Options `weather`,
  `weather_dynamic`, `replay_enabled` dans `options.gd`, exposées dans
  `options_menu.gd` (section « MISE EN SCÈNE »).

## Localisation (FR/EN)

- `Loc` (`scripts/core/loc.gd`) est un autoload placé **après** `Options` ; la
  langue vit dans `Options.language` (`"fr"` / `"en"`), donc elle est sauvée
  avec `user://options.cfg`. `Loc.set_language()` / `Loc.cycle()` persistent et
  émettent `changed`.
- Le **français sert de clé** : `Loc.t("OPTIONS")` renvoie la traduction EN ou,
  si l'entrée manque, le texte d'origine. Jamais d'identifiant brut à l'écran.
- Deux tables : `EN` pour les chaînes fixes, `EN_TEMPLATES` pour les chaînes
  dynamiques (`%d`, `%s`, `%3d`, `%4.1f`, `%%`). `t()` accepte donc les deux
  usages : `Loc.t("MUNITIONS %d / %d") % [a, b]` (gabarit) et
  `Loc.t("Zone 2 - 5 hostiles")` (texte déjà formaté, reconnu par motif).
- `Hud.set_title/set_objective/set_status/set_extra/set_boss_health` passent
  déjà par `Loc.t()` : les modes continuent d'écrire leurs chaînes françaises.
  Les valeurs imbriquées dans un `%s` (nom de défi, météo, `PRÊT`) sont
  traduites **à la source** (`Loc.t(label)`) avant le formatage. Le HUD garde
  les entrées brutes et se reconnecte à `Loc.changed` : `retranslate()`
  réapplique titre, objectif, statut, munitions, secondaires et barre de boss
  quand on change de langue en pleine partie (pause → options → langue).
- Le menu et l'écran d'options traduisent au moment de construire leurs
  libellés ; l'option « Langue » reconstruit tout le panneau (`_build()`), le
  menu est reconstruit à la fermeture (`closed` → `_build`) et le menu pause
  aussi (`_on_options_closed` → `_build()`), pour que ses boutons suivent la
  nouvelle langue.
