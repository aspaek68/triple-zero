# TRIPLE ZERO — Prototype

Prototype jouable en **Godot 4.7**, remake **hommage** à *Die Hard Trilogy* (PS1).
Trois actes, trois façons de jouer : **action/infiltration à la troisième
personne**, **rail shooter**, **conduite arcade**.

📄 Le document de conception complet est dans [`docs/GDD.md`](docs/GDD.md).

## Lancer

Au démarrage, un **menu** propose les trois actes (et les options). Pour aller
directement sur un acte, double-cliquez un des fichiers à la racine :

| Fichier | Acte | Genre |
|---|---|---|
| `LANCER_LE_JEU.bat` | Acte 1 — Tour | Action / infiltration (TPS) |
| `LANCER_MISSION_2.bat` | Acte 2 — Aéroport | Rail shooter |
| `LANCER_MISSION_3.bat` | Acte 3 — Ville | Conduite arcade |

Les `.bat` cherchent Godot 4.7.2 aux emplacements connus (dont
`C:\Users\guillaume\Desktop\programme\Godot_v4.7.2`). Pour surcharger :

```
set TRIPLE_ZERO_GODOT=C:\chemin\Godot_v4.7.2-stable_win64.exe
```

En ligne de commande directe :

```
Godot_v4.7.2-stable_win64.exe --path . --rendering-method gl_compatibility -- --mode=2
```

## Commandes

**Le jeu se joue entièrement à la manette** (Xbox/PlayStation, reconnue
automatiquement). Clavier/souris restent disponibles en parallèle ; le HUD
affiche les invites du périphérique que vous venez d'utiliser.

| Action | Manette | Clavier/souris |
|---|---|---|
| Se déplacer / conduire | **Stick gauche** ou croix | **ZQSD** / **flèches** |
| Viser / regarder la caméra | **Stick droit** | **Souris** |
| Tirer | **X** ou **gâchette droite (RT)** | **Clic gauche** / **Espace** |
| Courir / boost | **Gâchette gauche (LT)** ou **RB** | **Maj** |
| Sauter (Acte 1) | **A** | **Espace** |
| Se mettre à couvert (Acte 1) | **B** | **Ctrl** |
| Frein à main / déraper (Acte 3) | **B** | **Espace** |
| Météo (change le temps) | **Y** | **C** |
| Replay (ralenti) | **Back** | **R** |
| Pause (menu) | **Start** | **Échap** |
| Naviguer dans les menus | **Croix / stick gauche**, **A** valider, **B** retour | **Flèches**, **Entrée**, **Échap** |

Réglages manette dans les options : sensibilité des sticks, zone morte,
vibration. La manette vibre au tir, aux impacts et au boost.

Les **touches clavier sont remappables** dans les options (section « TOUCHES ») :
cliquez sur une action puis appuyez sur la nouvelle touche ; « Réinitialiser les
touches » remet les liaisons d'origine. Le remappage utilise le **code physique**
de la touche, donc les raccourcis restent à la même place sur un clavier AZERTY
ou QWERTY.

L'interface est **bilingue FR/EN** : le bouton « Langue », en tête des options,
bascule menus, HUD et messages des trois actes. Le choix est conservé dans
`user://options.cfg`.

### Viseur

Un **viseur** dessiné par le HUD (croix + point central) reste au centre de
l'écran en Acte 1 : le tir part exactement du centre de la caméra, donc il
tombe toujours là où vise la croix. En Acte 2 le viseur suit la souris / le
stick droit. Il s'écarte brièvement à chaque tir, passe en **orange** quand une
cible est alignée et affiche un **marqueur de touche** (quatre traits) sur un
impact réussi. L'aide à la visée (Options → accessibilité) élargit la tolérance
autour du viseur. Chaque tir dessine aussi une **balistique lumineuse** du
canon jusqu'au point d'impact, avec une **étincelle** brève là où le coup tombe
et une **marque d'impact** douce posée sur la surface
(`scripts/env/vfx.gd`, `Vfx.tracer()` / `Vfx.spark()` / `Vfx.impact_mark()`,
effets sans ombre qui se libèrent seuls). En Acte 3 (conduite) le viseur reste
masqué, et il disparaît pendant le ralenti (replay).

## Son

Le son est **généré par le jeu** (aucun fichier audio à fournir) : coups de feu,
impacts, confirmations, alarme « civil touché », souffle du boost, moteur et une
courte nappe musicale par acte. Trois bus d'audio (**Master / Musique / Effets**)
réglables depuis les options. Les vraies bandes-son pourront remplacer ces sons
procéduraux plus tard, sans changer le code.

## Les trois actes

1. **Acte 1 — Tour (TPS)** : caméra épaule, couverts (Ctrl), tir hitscan centré
   caméra avec viseur,
   ennemis à points de vie et **quatre silhouettes** (fusilier, éclaireur,
   lourd, élite), **deux coursives surélevées** (itinéraires alternatifs,
   bonus d'exploration), **trois civils à retrouver** avant d'abandonner leur
   zone, **barils explosifs** dans le décor, et des **situations qui
   dégénèrent** : effondrement du hangar puis embuscade.
2. **Acte 2 — Aéroport (rail shooter)** : la caméra avance sur un rail scripté ;
   le joueur ne contrôle que la visée. **Rouge = menaces** à abattre,
   **vert = civils** à épargner (pénalité sinon), **barils** qui nettoient un
   groupe d'hostiles d'un seul tir, **commutateurs verts** qui ouvrent une
   route alternative, **caisses de matériel** et **relais radio** à abattre,
   et bonus de score.
3. **Acte 3 — Ville (conduite arcade)** : circuit urbain à virages (12 nœuds),
   portes **chronométrées** qui prolongent le temps, **deux anneaux de
   raccourci** hors route, **caisses de matériel** et **relais radio** à
   récupérer en piste, trafic à éviter, **citernes explosives** qui sautent
   à l'impact, **voitures rivales** qui vous prennent en chasse (semez-les, ou
   **écrasez-les au boost**), frein à main et boost.

## Mise en scène

Chaque acte s'ouvre sur une **cinématique courte** : bandes noires, titre et
objectif, et une **caméra qui survole** le niveau avant de céder la main. Elle
se saute d'une touche (ou d'un clic) ; le rendu reste fluide car elle ne fait
que déplacer une caméra. Le HUD affiche le **compteur de poursuivants** à
l'Acte 3.

## Météo, replay et éditeur de niveau

La **météo dynamique** (`scripts/env/weather.gd`) est commune aux trois actes :
quatre presets (clair, pluie, orage, brouillard) changent le ciel, le brouillard,
le soleil et la pluie, avec une transition douce. **C** (ou **Y**) fait défiler
les presets ; en orage, des **éclairs** illuminent la scène et le **tonnerre**
gronde. À l'Acte 3, une route mouillée **réduit l'adhérence**, donc la voiture
dérape. L'option **météo dynamique** laisse le temps changer tout seul.

Le **replay** (`scripts/core/replay.gd`) filme en continu les acteurs (joueur,
ennemis, rivaux) et garde les dernières secondes. À tout moment (**R** ou
**Back**), ou à la fin d'un acte, il rejoue ce passage en **ralenti** : boîtes
fantômes à la place des acteurs, caméra orbitale, bandes noires et éclairs sur
les explosions. On peut le désactiver dans les options.

L'**éditeur de niveau** (menu principal → *ÉDITEUR DE NIVEAU (acte 3)*) affiche
une **vue de dessus** du circuit : on **déplace les nœuds** du tracé, on pose des
**props** (barils, barrières, panneaux…), puis on **enregistre** dans
`user://level.json`. Le bouton *Tester l'acte 3* lance la conduite sur le tracé
personnalisé ; sans niveau enregistré, l'acte 3 garde son circuit d'origine.
Les **props posés apparaissent réellement** dans l'acte (décor, sans collision :
la ligne de course reste praticable) et le panneau confirme chaque
enregistrement. Un `level.json` abîmé ou édité à la main est ignoré entrée par
entrée au lieu de planter l'éditeur ou l'acte.

## Destructibilité et situations dynamiques

Le décor est **destructible** : les **barils** explosent avec des **dégâts de
zone** (ils endommagent les ennemis, le joueur, et **réagissent en chaîne**
entre eux), les **caisses** se brisent. Les explosions déclenchent une lumière
brève, un son et une vibration manette. Trois **événements scriptés** rythment
l'Acte 1 (effondrement, embuscade) et l'Acte 3 (citernes à l'impact). L'Acte 3
ajoute des **voitures rivales** : elles vous percutent pour vous ralentir, et
une ruade au **boost** suffit à en envoyer une au tapis (+150 au score).

## Assets (textures et sons)

Deux niveaux : un **pack CC0** optionnel pour le décor, et des **placeholders
générés** pour tout le reste.

### Pack CC0 (recommandé)

`assets/textures_cc0/` contient cinq sets PBR **CC0 1.0** issus d'**ambientCG**
(béton, asphalte, métal, brique, sol), téléchargés en 1K et convertis en PNG
sans modifier les pixels : albédo + normale OpenGL + rugosité + occlusion.
`tools/fetch_cc0_textures.ps1` les retélécharge et les reconstruit à
l'identique ; `assets/textures_cc0/LICENSE.txt` garde la provenance.

```
powershell -ExecutionPolicy Bypass -File tools/fetch_cc0_textures.ps1
```

Le chargeur (`EnvBuilder`) préfère ce dossier, puis retombe sur
`assets/textures/`. Les scans CC0 gardent leurs couleurs d'origine ; les cartes
générées, elles, sont teintées par la palette.

### Ciel HDRI CC0

`assets/hdri/sky.hdr` est un ciel **CC0 1.0** de **Poly Haven**
(`kloofendal_43d_clear_puresky`, 1K Radiance). `EnvBuilder` le charge comme
`PanoramaSkyMaterial` et **tourne le panorama** pour que le soleil de l'image
tombe sur le `DirectionalLight3D` : une seule ombre, un seul soleil.

```
powershell -ExecutionPolicy Bypass -File tools/fetch_cc0_hdri.ps1
```

`tools/hdri_sun.py` (Python pur) lit les pixels RGBE, trouve le plus lumineux et
écrit `assets/hdri/sun.json` (azimut/élévation). Sans ce dossier — ou sans cache
d'import `.godot/` — le jeu retombe sur le ciel procédural, sans erreur. La
météo assombrit l'HDRI (`energy_multiplier`) et teinte le fond par le brouillard
au lieu de repeindre le panorama.

### Props CC0

`assets/models_cc0/` contient six props **CC0 1.0** de **Poly Haven** (glTF 1K,
textures JPG) : baril, caisse militaire, lampadaire, barrière béton, poubelle,
jardinière.

```
powershell -ExecutionPolicy Bypass -File tools/fetch_cc0_models.ps1
```

Chaque prop est normalisé à sa **plus grande dimension** (`MODEL_SIZE`), centré
en X/Z et posé au sol (`min y = 0`). Les scènes multi-variantes sont élaguées
(`MODEL_DROP` : la 2ᵉ caisse, la poubelle rouillée). `EnvBuilder` préfère ce
dossier, puis `assets/models/*.glb`, puis une primitive. La provenance est dans
`assets/models_cc0/LICENSE.txt`.

### Textures générées

`tools/gen_assets.py` (Python pur, sans dépendance, déterministe) produit les
placeholders et les détails :

- `assets/textures/*.png` — béton, asphalte, métal, brique, sol, signalétique,
  **tissu**. Chaque texture a ses cartes de **normales** (`*_normal.png`), de
  **rugosité** (`*_rough.png`) et d'**occlusion** (`*_ao.png`) pour un rendu
  PBR ; le décor utilise un mappage **triplanaire monde** pour éviter les
  étirements, et les personnages reçoivent le micro-détail tissu ;
- `assets/audio/*.wav` — tir, impact, explosion, accident, boost, alarme.

```
python3 tools/gen_assets.py --size 1024       # tout, en haute résolution
python3 tools/gen_assets.py --only fabric --size 1024
```

Le jeu **fonctionne avec ou sans** ces fichiers : s'ils sont absents, il retombe
sur les matériaux plats et l'audio procédural. De vrais assets peuvent donc
remplacer les fichiers **en place**, sans toucher au code.

> **Cache d'import** : les `.png` et `.wav` sont chargés même sans cache
> `.godot/` (décodage au runtime), donc un clone frais ne produit aucune erreur.
> Les lanceurs `LANCER_*.bat` lancent en plus un `--import` avant le jeu pour
> enregistrer les `class_name` et préparer les ressources.

## Score et rang

`Score` (autoload) récompense **précision**, **rapidité**, **exploration** et
**protection des civils** ; multiplicateur ×1.5 si aucun dégât subi. À la fin
d'un acte, un rang **S/A/B/C** s'affiche sur l'écran de résultats. L'Acte 3 ne
tire aucun coup : sa ligne de précision (et le bonus de 1000 points associé)
est donc masquée, et une voiture rivale qui vous percute compte comme un dégât
subi.

Les **défis rejouables** (partie libre, sans dégâts, contre-la-montre, tireur
d'élite, explorateur) se choisissent dans le menu. Le défi « Sans dégâts » est
réellement jouable dans les trois actes : il échoue si vous êtes touché
(Acte 1), si vous touchez un civil (Acte 2) ou si une voiture rivale vous
percute (Acte 3), et le HUD affiche alors **DÉFI ÉCHOUÉ** avec la raison.
Chaque acte terminé débloque son premier **équipement** (le second emplacement
est réservé à la Nouvelle Partie+) : ils changent l'approche sans augmenter la
puissance brute. Un acte compté comme réussi le reste même si le défi choisi
échoue ; le verdict du défi s'affiche séparément. **Mourir en Acte 1** (intégrité
à zéro) est un échec : l'acte n'est pas validé, aucun score n'est enregistré et
l'écran propose de le rejouer. Terminer les trois actes
débloque la **Nouvelle Partie+** (ennemis plus coriaces, ressources plus rares) ;
le choix est **mémorisé** d'une session à l'autre.

## Menu pause et résultats

**Échap** (ou **Start**) ouvre un vrai **menu pause** dans les trois actes :
*Reprendre*, *Options*, *Recommencer*, *Menu principal*, *Quitter le jeu*. La
simulation est gelée, la souris libérée puis restaurée, et tout se navigue à la
manette comme à la souris. Le menu pause passe au-dessus du HUD et de la
cinématique.

L'écran de résultats annonce **ACTE RÉUSSI / ACTE ÉCHOUÉ**, le score, la
précision, le rang, le meilleur score et le détail du défi (avec la **raison** de
l'échec : touché, trop lent, aucun tir, précision insuffisante, aucun itinéraire
alternatif, temps écoulé). Un acte **échoué** (intégrité à zéro en Acte 1, temps
écoulé en Acte 3) n'enregistre ni score ni rang : l'écran l'indique et donne la
raison. Il propose directement **ACTE SUIVANT** (après une réussite),
**REJOUER L'ACTE** ou **FERMER LES RÉSULTATS**. Menu principal et options
**défilent** pour rester utilisables sur toutes les tailles de fenêtre.

Une **piste personnalisée** enregistrée dans l'éditeur est signalée dans le
menu (« Piste personnalisée active — acte 3 ») pour que l'on sache quel tracé
l'Acte 3 va utiliser.

## Options et accessibilité

Menu **OPTIONS** (depuis le menu principal ou la pause), persisté dans
`user://options.cfg` :

- **langue** FR / EN (menus, HUD, messages des actes) ;
- difficulté (dégâts entrants), assistance de visée (tolérance de tir) ;
- taille du réticule, sensibilité souris, inversion d'axe vertical ;
- secousses caméra, flou de mouvement, sous-titres ;
- **mise en scène** : météo (clair / pluie / orage / brouillard), météo
  dynamique, et ralenti (replay) activé ou non.

## Structure

```
project.godot              # autoloads GameState / Options / Score, rendu GL
docs/GDD.md                # document de conception complet
scenes/
  main.tscn                # menu principal + écran de résultats
  modes/tps.tscn           # Acte 1
  modes/rail.tscn          # Acte 2
  modes/drive.tscn         # Acte 3
scripts/
  core/
    game_state.gd          # autoload : mode courant, actions d'entrée (clavier + manette)
    options.gd             # autoload : accessibilité, difficulté, manette, audio
    score.gd               # autoload : score, précision, rang
    progress.gd            # autoload : NG+ et défis rejouables (persistés)
    audio.gd               # autoload : bus, réverb, variation, ducking, musique adaptative
    level_data.gd          # autoload : niveau personnalisé de l'éditeur (user://level.json)
    replay.gd              # tampon de ralenti : filme les acteurs, rejoue en fantômes
    director.gd            # câblage commun météo + replay pour les trois actes
  env/
    env_builder.gd         # ciel, soleil, brouillard, tonemapping, matériaux PBR + chargement glTF
    character.gd           # humanoïde skinné (squelette + animations idle/walk/run/aim/mort)
    weapon.gd              # fusil en primitives (canon, chargeur, optique, recul)
    destructible.gd        # barils explosifs / caisses cassables
    enemy.gd               # hostile à points de vie, touchable par les explosions
    weather.gd             # météo dynamique : ciel, brouillard, soleil, pluie, éclairs
  modes/{tps,rail,drive}.gd
  ui/{menu,options_menu,pause_menu,hud}.gd
  ui/level_editor.gd       # éditeur de niveau de l'acte 3 (vue de dessus)
tools/
  gen_assets.py            # génère assets/textures/*.png et assets/audio/*.wav
  gen_meshes.py            # props glTF de repli (Python pur, sans dépendance)
  gen_models.py            # props artistiques via Blender (bpy) : bevel, lissage,
                           # plusieurs matériaux par objet
  fetch_cc0_textures.ps1   # pack PBR CC0 ambientCG -> assets/textures_cc0/
  fetch_cc0_hdri.ps1       # ciel CC0 Poly Haven -> assets/hdri/sky.hdr
  hdri_sun.py              # trouve le soleil de l'HDRI -> assets/hdri/sun.json
  fetch_cc0_models.ps1     # props CC0 Poly Haven -> assets/models_cc0/
assets/
  textures/                # albédo + normales + rugosité + occlusion (PBR), générés
  textures_cc0/            # cinq sets PBR CC0 ambientCG (1K PNG)
  hdri/                    # sky.hdr + sun.json + LICENSE.txt (CC0 Poly Haven)
  models/                  # props glTF : baril, caisse, cône, lampadaire, benne,
                           # jardinière, barrière, carrosserie de voiture
  models_cc0/              # six props CC0 Poly Haven (glTF 1K + textures)
  audio/                   # tir, impact, explosion, accident, boost, alarme (44,1 kHz)
```

## Rendu (graphismes de jour)

- **Ciel HDRI** CC0 (Poly Haven) aligné sur le soleil, avec repli sur un ciel
  **procédural** bleu ; **soleil** chaud à ombres 4 cascades (4096 px, flou doux) ;
- **Tonemapping AgX**, contraste/saturation, **bloom HDR** (accroche les flashes
  et les néons) ;
- **Brouillard atmosphérique** pour la profondeur ; **MSAA 3D ×4** ;
- **Matériaux PBR** : chaque texture a une carte de normales, de rugosité et
  d'occlusion ambiante, appliquées par `EnvBuilder.material()` ;
- **Props artistiques** : barils, caisses, lampadaires, barrières, poubelles et
  jardinières sont des maillages **glTF** — props **CC0** de Poly Haven quand
  `assets/models_cc0/` existe, sinon les props générés (`tools/gen_meshes.py`),
  sinon une primitive. `EnvBuilder.load_model_scene()` garde les modèles
  multi-parties intacts et les normalise à leur plus grande dimension ;
- **Audio mixé** : bus *Master → Music / SFX*, réverbération légère sur les SFX,
  variation de hauteur/volume par tir, polyphonie limitée et *ducking* de la
  musique sous les explosions ;
- **Musique adaptative** : quatre couches (batterie, basse, arpège, lead)
  synchronisées par un `AudioStreamSynchronized` ; `Audio.set_intensity()` fait
  entrer les couches au fil de l'action (hostiles, combo, vitesse) ;
- **Personnages** humanoïdes **skinnés** (`character.gd`) : maillage riggé sur un
  `Skeleton3D`, animé par un `AnimationPlayer` (idle / marche / course, variantes
  de visée, chute mortelle) ; le fusil (`weapon.gd`) est tenu par l'os de la main
  droite et suit l'animation.

Tout est réglé dans `scripts/env/env_builder.gd`.

> Le renderer *GL Compatibility* ne supporte pas SSAO / SSR / SSIL ni le
> brouillard volumétrique (Vulkan) ; ces effets sont donc **activés
> automatiquement** uniquement quand le renderer le permet. Pour le rendu le
> plus riche, lancez `LANCER_QUALITE_HAUTE.bat` (renderer **Forward+**). Voir GDD §8.

## Notes

- `.godot/` est le cache moteur, ignoré par Git et régénéré à l'ouverture.
- Les niveaux sont des **blockouts** : géométrie simple (boîtes) destinée à être
  habillée de vrais maillages, matériaux et animations. Les **textures** et
  **sons** actuels sont des placeholders générés (`tools/gen_assets.py`),
  remplaçables fichier par fichier sans changer le code.
- **IP originale** : aucun nom, personnage ni contenu sous licence *Die Hard*
  n'est utilisé — c'est un hommage au genre et au ton.

