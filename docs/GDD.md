# TRIPLE ZERO — Document de conception (GDD)

> Remake moderne, **hommage** à *Die Hard Trilogy* (PlayStation 1, 1996).
> **TRIPLE ZERO** est une œuvre originale : pas de nom, de personnage ni de
> contenu sous licence. On en reprend la *formule* — un seul jeu, trois
> expériences — et le ton « film d'action des années 90 ».

---

## 1. Vision

**Une seule cartouche, trois façons de jouer.** Le joueur vit une soirée qui
dégénère en trois actes : il infiltre une tour, il tient une position sous le
feu, il fonce à travers la ville. Chaque acte est un jeu complet et court,
rejouable, à la difficulté réglable.

**Piliers de conception**

1. **Trois jeux en un** — TPS, rail shooter, conduite arcade. Variété assumée :
   on change de mode, donc de rythme et de sensations, à chaque acte.
2. **Arcade d'abord** — plaisir immédiat, objectifs lisibles, parties courtes
   (5–12 min par niveau), redémarrage instantané.
3. **Cinéma interactif** — mise en scène, caméra dynamique, effets spectaculaires,
   mais **lisibilité totale** pendant l'action.
4. **Rejouabilité** — score, classement, défis, chemins alternatifs, Nouvelle
   partie+.

**Anti-objectifs** (ce que le jeu n'est *pas*)

- ❌ Pas de monde ouvert immense : des niveaux **denses** et spectaculaires.
- ❌ Pas de simulation réaliste (conduite, armes) : on reste **arcade**.
- ❌ Pas de système de progression qui déséquilibre : améliorations **plafonnées**.

---

## 2. Univers et ton

**Cadre** : une grande ville américaine, fin des années 90. Un groupe
paramilitaire prend le contrôle d'une tour de bureaux pendant une soirée de
gala. Un flic de la vieille école, au mauvais endroit au mauvais moment, décide
de tout faire capoter.

**Ton** : tendu mais divertissant. Le héros est **débrouillard** — il improvise
avec ce qu'il trouve (extincteur, câble, chariot de ménage), râle, et garde un
**humour sec** même quand tout part en vrille.

**Direction narrative**

- **Acte 1 (Tour)** : infiltration et action, de la cave au dernier étage.
- **Acte 2 (Aéroport)** : rail shooter, tenir la position pendant l'évacuation.
- **Acte 3 (Ville)** : conduite arcade, rattraper le convoi avant l'aube.

**Règles de ton**

| Faire | Éviter |
|---|---|
| Répliques courtes, ironiques, jamais cyniques | Grandiloquence, mélodrame |
| Dégradation progressive : courant, alarmes, renforts | Grimdark gratuit |
| Réactions crédibles aux impacts | Gore excessif |
| Caméra qui accompagne l'action | Caméra qui la cache |

---

## 3. Les trois modes de jeu

### 3.1 Acte 1 — Infiltration et action (troisième personne)

**Boucle** : observer → se couvrir → progresser → engager → objectif.

- **Caméra** : épaule dynamique (décalage au tir, recentrage au sprint),
  transparence automatique des obstacles proches.
- **Déplacement** : marche, course, glissade sous les obstacles, **escalade**
  contextuelle (corniches, gaines techniques).
- **Couverture** : aimantation douce, tir à l'aveugle, sortie rapide, destruction
  progressive des couverts légers.
- **Combat** : visée assistée réglable, armes à débloquer, munitions limitées,
  corps-à-corps d'urgence (crosse, pistolet).
- **Itinéraires alternatifs** : conduits d'aération, ascenseurs de service,
  façades — chaque route échange **rapidité** contre **risque**.
- **Objectifs lisibles** : un objectif principal, deux secondaires (sauver un
  otage, couper une alarme, récupérer un plan).

**Plaisir immédiat** : combats courts et nerveux, pas de gestion de chargeur
fastidieuse, ennemis clairement lisibles (couleur, silhouette, son).

### 3.2 Acte 2 — Rail shooter

**Boucle** : viser → tirer → protéger → repérer → réagir.

- **Caméra sur rail** : le parcours est scénarisé ; le joueur contrôle **la
  visée**, pas les déplacements. Temps de réaction court, cibles nettes.
- **Visée** : curseur à la souris, **visée manette assistée** (aimantation
  optionnelle, zone de tolérance réglable).
- **Priorités** : neutraliser les menaces, **épargner les civils** (pénalité si
  touchés), repérer les **objets utiles** (clés, explosifs, trousses) à tirer ou
  à collecter, réagir aux **événements imprévus** (vitre qui explose, câble qui
  lâche, véhicule qui fonce).
- **Accessoires facultatifs** : prise en charge de manettes/pointeurs compatibles
  (gyroscope, light gun USB), **toujours optionnelle**.
- **Mise en scène** : coupes franches entre les « wagons », respiration narrative,
  QTE d'action intégrés à la visée (jamais pénalisants à la première erreur).

### 3.3 Acte 3 — Conduite arcade

**Boucle** : foncer → déraper → raccourcir → percuter → objectif.

- **Modèle de conduite** : adhérence généreuse, **dérapage** déclenché au
  frein à main, boost court à rechargement, aucune gestion de boîte de vitesses.
- **Objectifs variés** : poursuite, fuite, point de passage chronométré,
  protection d'un véhicule, course à checkpoints.
- **Monde** : couloirs urbains denses, **raccourcis** à découvrir (ruelles,
  tunnels, rampes), trafic léger servant d'obstacle.
- **Collisions** : spectaculaires mais **lisibles** — tôles qui se froissent,
  vitres qui éclatent, débris, sans détruire le véhicule en un choc.

---

## 4. Nouveautés par rapport à l'original

| Nouveauté | Mise en œuvre |
|---|---|
| **Chemins multiples** | Acte 1 : deux coursives surélevées (ouest et est) ; Acte 2 : deux commutateurs verts à abattre ; Acte 3 : deux anneaux de raccourci hors route. Chacun crédite `Score.alternate_paths` |
| **Objectifs secondaires** | Acte 1 : trois civils à rejoindre avant de quitter leur zone, plus le matériel et les communications des vagues ; Acte 2 : caisses de matériel et relais radio à abattre ; Acte 3 : caisses et relais à récupérer en piste — tout alimente le score |
| **Décor partiellement destructible** | Vitres, cloisons, mobilier, véhicules : réactions crédibles (éclats, poussière, sons) |
| **Situations dynamiques** | Coupures de courant, alarmes, obstacles, renforts, changements de météo |
| **Score et classement** | Précision, rapidité, exploration, civils protégés → rang S/A/B/C |
| **Déblocages** | Armes, véhicules, tenues ; améliorations **plafonnées** (pas de power creep) |
| **Défis rejouables + NG+** | Modificateurs (sans dégâts, chrono, arme imposée), NG+ avec ennemis retravaillés |
| **Accessibilité** | Visée, commandes, difficulté, effets visuels |

**Système de score** (exemple d'Acte 1)

```
Précision        +100 / coup au but, +150 / tête
Rapidité         bonus dégressif selon le temps restant
Exploration      +500 / itinéraire alternatif emprunté
Civils protégés  +200 / civil sain et sauf, −400 / civil perdu
Matériel         +250 / équipement récupéré
Communications   +350 / relais rétabli
Sans dégâts      multiplicateur ×1.5 si aucun coup encaissé
```

**Améliorations plafonnées** : chaque arme a 3 niveaux max ; chaque niveau
améliore **une** statistique (recul, cadence, capacité) sans rendre l'arme
polyvalente. Les véhicules gagnent **une** amélioration (frein à main, boost,
adhérence) au choix.

---

## 5. Graphismes et son

**Rendu (cible)**
- Éclairage moderne : lumière directe + rebond, ombres douces, **éclairage
  dynamique réactif** (coupures de courant, gyrophares, alarmes).
- Matériaux détaillés : métal brossé, verre, béton, tissu — variété et
  rugosité crédibles.
- Animations expressives : démarches, réactions aux impacts, ragdolls contrôlés.
- Caméra dynamique : épaule, secousses d'impact, ralentis courts sur les
  moments forts (désactivables).

**Lisibilité** (contrainte forte)
- Contraste net entre le joueur, les menaces et le décor.
- Effets « spectaculaires » jamais opaques : fumée brève, flashs courts.
- Options pour réduire les secousses, le flou, les flashs (accessibilité).

**Son**
- **Bande-son originale** inspirée des films d'action 90s : cuivres tendus,
  nappes synthétiques, percussions sèches ; thème principal décliné par acte.
- **Effets puissants et distinctifs** : chaque arme, chaque impact, chaque
  alarme a une signature sonore reconnaissable.
- **Mixage dynamique** : priorité aux menaces proches, musique qui monte en
  tension, baisse automatique sur les dialogues.

> **Implémenté (prototype)** : les sons sont *générés par le moteur* (aucun
> fichier fourni) — tir, impact, confirmation, alarme « civil touché », boost,
> moteur, plus une courte nappe musicale par acte. Trois bus (**Master /
> Musique / Effets**) réglables dans les options. Ces sons placeholder seront
> remplacés par de vraies prises sans changer le code.

---

## 6. Interface et accessibilité

**HUD** : minimal et lisible — santé, munitions, objectif courant, score en
cours, indicateur de direction vers l'objectif. Les invites de commandes
s'adaptent automatiquement au périphérique utilisé (manette ou clavier/souris).

**Manette (priorité)**
- **Le jeu se joue entièrement à la manette**, reconnue à chaud.
- Mouvement : stick gauche / croix ; visée-caméra : stick droit.
- Tir : **X** ou gâchette droite ; course/boost : gâchette gauche ou RB ;
  saut : **A** ; couvert / frein à main : **B** ; pause : **Start**.
- Menus entièrement navigables à la manette (croix/stick, **A** valider,
  **B** retour).
- **Vibration** contextuelle (tir, impacts, boost), réglable.

**Options d'accessibilité**
- Visée : assistance (aucune / légère / forte), taille du réticule, aimantation.
- Commandes : sensibilité souris **et sticks**, zone morte, inversion d'axes.
- Difficulté : réglable à tout moment ; ennemis, dégâts, fenêtres de temps.
- Effets visuels : secousses, flou, flashs, grain, motion blur, chromaticité.
- Confort : sous-titres, taille de texte, contraste élevé, daltonisme.

---

## 7. Contraintes de conception (rappel)

1. **Reconnaissable** : trois modes, rythme arcade, un seul « package ».
2. **Variété préservée** : chaque acte se joue différemment.
3. **Pas de monde ouvert** : niveaux denses, couloirs, scènes spectaculaires.
4. **Pas de simulation** : conduite et armes accessibles avant tout.
5. **Parties courtes et rejouables** : score, classement, défis, NG+.

---

## 8. Mise en œuvre technique (Godot 4.7)

**Moteur** : Godot 4.7. Le prototype tourne par défaut en *GL Compatibility*
(compatibilité large). Sur une machine compatible Vulkan, le lanceur
`LANCER_QUALITE_HAUTE.bat` démarre le même projet en **Forward+** pour
débloquer éclairage global, ombres avancées et effets modernes. Le choix du
renderer se fait au lancement (Godot ne le change pas à chaud) ; le projet
reste donc un seul code, deux profils.

**Architecture logicielle**

```
project.godot
scenes/
  main.tscn              # menu principal / sélecteur de mode + résultats
  modes/tps.tscn         # Acte 1
  modes/rail.tscn        # Acte 2
  modes/drive.tscn       # Acte 3
scripts/
  core/
    game_state.gd        # autoload : mode courant, actions d'entrée (clavier + manette)
    options.gd           # autoload : accessibilité, difficulté, manette, audio
    score.gd             # autoload : calcul du score et rang
    audio.gd             # autoload : charge assets/audio/*.wav (repli procédural)
  env/
    env_builder.gd       # ciel, soleil, brouillard, PBR (normales + rugosité)
    character.gd         # humanoïde skinné (squelette, animations, mort)
    weapon.gd            # fusil en primitives (recul, flash de bouche)
    destructible.gd      # barils explosifs, caisses cassables
    enemy.gd             # hostile à points de vie, sensible aux explosions
  modes/
    tps.gd               # personnage TPS, couverture, tir, ennemis, effondrement
    rail.gd              # rail, cibles, civils, barils
    drive.gd             # véhicule arcade, dérapage, boost, citernes
  ui/
    menu.gd, hud.gd, options_menu.gd
tools/
  gen_assets.py          # génère les textures (PNG) et les sons (WAV)
assets/
  textures/  audio/      # albédo + normales + rugosité, sons, générés
```

> **Destructibilité** : les barils explosent (dégâts de zone, réaction en chaîne,
> lumière et vibration) ; les caisses se brisent. **Situations dynamiques** :
> effondrement de hangar, embuscade, citernes qui sautent à l'impact.
>
> **Personnages & armes** : les acteurs sont des humanoïdes **skinnés**
> (`character.gd`) — un maillage riggé sur un `Skeleton3D`, animé par un
> `AnimationPlayer` (idle, marche, course, variantes de visée, chute mortelle) ;
> le fusil (`weapon.gd`) est tenu par l'os de la main droite. **Rendu** :
> tonemapping AgX, bloom, PBR (normales + rugosité) et, en Forward+, SSAO/SSIL,
> SSR et brouillard volumétrique.
>
> **Nouvelle partie+ & défis** : terminer les trois actes débloque la NG+
> (hostiles plus coriaces, ressources plus rares, chrono resserré). Des **défis**
> rejouables (sans dégâts, contre-la-montre, tireur d'élite, **explorateur**)
> se choisissent au menu et sont évalués à la fin de chaque partie.

**Jalons**

| Étape | Contenu | État |
|---|---|---|
| P0 | Blockout jouable (jour) | ✅ fait |
| P1 | Menu de sélection de mode + options | ✅ fait |
| P2 | TPS : couverture, tir, ennemis, itinéraire alterné | ✅ fait |
| P3 | Rail shooter : rail, cibles, civils | ✅ fait |
| P4 | Conduite arcade : véhicule, dérapage, boost | ✅ fait |
| P5 | Score, classement (S/A/B/C), déblocages | ✅ score + rang faits |
| P6 | **Manette complète** (jeu + menus + vibration) | ✅ fait |
| P7 | Audio (placeholder procédural, 3 bus) | ✅ fait |
| P8 | Contenu de niveau enrichi (zones, vagues, circuit, checkpoints) | ✅ fait |
| P9 | Destructibilité (barils, chaînes) + situations dynamiques | ✅ fait |
| P10 | Assets sur disque (textures PNG + sons WAV) | ✅ fait |
| P11 | Personnages et armes plus réalistes + rendu PBR/AgX | ✅ fait |
| P12 | Personnages skinnés + animations squelettiques, NG+, défis | ✅ fait |
| P13 | Maillages glTF générés, textures 256 px + AO, audio mixé | ✅ fait |
| P14 | Modèles artistiques (Blender/bpy), musique adaptative par couches | ✅ fait |
| P15 | Décor de niveau étendu, véhicules ennemis, cinématiques | ✅ fait |
| P16 | Éditeur de niveaux, météo dynamique, replay | ✅ fait |
| P17 | Itinéraires multiples dans les 3 actes, civils à retrouver, défi « Explorateur » | ✅ fait |
| P18 | Variantes d'ennemis (fusilier, éclaireur, lourd, élite), équipement détaillé, micro-détail tissu, matériaux triplanaires | ✅ fait |
| P19 | Pack CC0 ambientCG (5 sets PBR 1K) + placeholders 1024 px, repli automatique | ✅ fait |
| P20 | Ciel HDRI CC0 Poly Haven aligné sur le soleil + 6 props CC0 normalisés (taille/sol) | ✅ fait |
| P21 | Viseur partagé (croix dessinée) + tir TPS centré caméra avec aide à la visée | ✅ fait |

---

### 8.5 Mise en scène dynamique (P16)

- **Météo** (`scripts/env/weather.gd`) : quatre presets (clair, pluie, orage,
  brouillard) pilotent ciel, brouillard, soleil et pluie, avec transition
  douce ; éclairs + tonnerre en orage ; l'Acte 3 réduit l'adhérence sous la
  pluie. Touche **C** / **Y** pour changer, option « météo dynamique » pour
  laisser le temps tourner seul.
- **Replay** (`scripts/core/replay.gd`) : tampon borné des dernières secondes
  (transforms seulement) ; rejeu en **ralenti** avec fantômes, caméra orbitale
  et bandes noires. Touche **R** / **Back**, ou automatique en fin d'acte.
- **Éditeur de niveau** (`scripts/ui/level_editor.gd`) : vue de dessus du
  circuit de l'Acte 3 ; nœuds déplaçables, props posables, sauvegarde dans
  `user://level.json` (autoload `LevelData`). L'Acte 3 charge ce tracé quand il
  existe, sinon garde son circuit d'origine.

### 8.6 Rendu et personnages (P18)

- **Variantes** (`scripts/env/character.gd`) : `rifleman`, `heavy`, `scout`,
  `elite`, `civilian`. Le kit (casque, visière émissive, gilet, plaques
  d'épaule, genouillères, sac) est construit en géométrie riggée sur les mêmes
  os, donc l'animation reste identique. `Enemy._pick_variant()` décide à
  l'apparition ; les lourds sont toujours `heavy`, la NG+ peut sortir des
  `elite`, et des `scout` plus légers cassent la silhouette.
- **Textures** : `tools/gen_assets.py` génère les placeholders en **1024 px**
  avec albédo, normale, rugosité et occlusion ; le motif **tissu** (`fabric`)
  sert de micro-détail aux personnages. `--size` et `--only` permettent de
  régénérer une seule famille sans tout recalculer.
- **Pack CC0** : `tools/fetch_cc0_textures.ps1` télécharge cinq sets PBR
  **CC0 1.0** d'ambientCG (béton, asphalte, métal, brique, sol) en 1K et les
  convertit en PNG dans `assets/textures_cc0/`. `EnvBuilder` préfère ce dossier
  puis retombe sur les placeholders ; les scans gardent leur couleur d'origine
  (pas de teinte palette) et la provenance est dans `LICENSE.txt`.
- **Matériaux** : mappage **triplanaire monde** sur le décor, avec une échelle
  par surface (0,3 à 0,6 m par répétition selon la matière), pour une densité
  de texels constante sur les murs, sols et props de toute taille (plus
  d'étirement d'une seule tuile UV).

### 8.7 Ciel HDRI et props CC0 (P20)

- **Ciel HDRI** : `tools/fetch_cc0_hdri.ps1` récupère un ciel **CC0 1.0** de
  Poly Haven en Radiance 1K (`assets/hdri/sky.hdr`). `EnvBuilder` le monte en
  `PanoramaSkyMaterial` (`HDRI_ENERGY = 0,65`), et `tools/hdri_sun.py` lit les
  pixels RGBE pour trouver le soleil de l'image (`sun.json`). Le panorama est
  tourné de `SUN_YAW - azimut` pour que ce soleil coïncide avec le
  `DirectionalLight3D` : une seule ombre, pas de double éclairage.
- **Repli** : sans fichier — ou sans cache d'import `.godot/`, car `.hdr` ne se
  charge que par l'import — `EnvBuilder._build_panorama_sky()` renvoie `null` et
  le ciel procédural reprend la main, sans erreur. La météo gère les deux cas :
  elle repeint le ciel procédural, ou assombrit l'HDRI et laisse le brouillard
  teinter le fond (`sky_energy`, `sky_affect`).
- **Props CC0** : `tools/fetch_cc0_models.ps1` télécharge six props Poly Haven
  (baril, caisse militaire, lampadaire, barrière béton, poubelle, jardinière) en
  glTF 1K dans `assets/models_cc0/`. `EnvBuilder.load_model_scene()` les
  normalise à leur **plus grande dimension** (`MODEL_SIZE`), les centre en X/Z et
  pose leur base à `y = 0`; `MODEL_DROP` retire les variantes inutilisées des
  scènes multi-objets (2ᵉ caisse, poubelle rouillée). `prop_bounds()` expose
  l'AABB local : `Destructible` en dérive sa hitbox (cylindre pour le baril,
  boîte pour la caisse) et les replis centrés sont remontés au sol.
- **Ordre de repli** : `models_cc0/<nom>/` → `models/<nom>.glb` → primitive
  générée. Aucun fichier sous licence commerciale n'est utilisé.

### 8.8 Visée et viseur (P21)

- **Viseur unique** : `Hud` contient un `Reticle` (`Control` dessiné) en espace
  écran, partagé par l'Acte 1 et l'Acte 2. Croix à quatre traits + point
  central, écartés par le recul (`reticle_kick`), teintés en orange sur une
  cible (`set_reticle_hot`) avec marqueur de touche à quatre traits
  (`reticle_hit`). Il apparaît à la fin de la cinématique d'intro et reste
  masqué en Acte 3.
- **Acte 1** : le viseur suit le centre du viewport et le tir est un **hitscan
  depuis la caméra** (`_resolve_shot()`), RID du joueur exclu. L'ancien
  `RayCast3D` partait du joueur à hauteur d'œil et restait horizontal (le
  tangage était ignoré) : le tir tombe désormais exactement sous la croix.
  L'aide à la visée convertit `Options.aim_tolerance()` (pixels) en cône
  angulaire selon le FOV, ne retient que les ennemis vivants à ligne de vue
  dégagée et prend le plus proche de l'axe.
- **Acte 2** : la visée reste en espace écran (`_aim` + `_screen_distance`), le
  HUD ne fait qu'afficher `_aim` ; la tolérance existante (40 px + aide, ×1,4
  avec l'équipement de visée assistée) est inchangée.
- **Retour de tir** : `Vfx` (`scripts/env/vfx.gd`) trace une balistique fine du
  canon (`Weapon.muzzle()`) au point d'impact et y fait jaillir une étincelle
  émissive orientée par la normale du mur. Les deux effets sont *unshaded*, sans
  ombre, se fondent puis `queue_free` en ~0,15 s, donc compatibles avec le
  renderer `gl_compatibility`. Un tir dans le vide garde le tracer (vers un
  point lointain) mais pas l'étincelle ; en Acte 1 l'aide à la visée fait
  converger le tracer sur la poitrine de l'ennemi réellement touché.
- **Ralenti** : `Director.start_replay()` masque le viseur et le restaure à la
  fin, sans toucher au point de visée (le mode reste maître de `follow_center`).

## 9. Références et inspiration

- *Die Hard Trilogy* (PS1, 1996) — structure trois-en-un, ton, rythme.
- Films d'action des années 90 — mise en scène, humour sec, héros débrouillard.
- Jeux arcade d'action modernes — lisibilité, rejouabilité, accessibilité.

> **Note juridique** : *TRIPLE ZERO* est un hommage original. Aucune marque,
> aucun personnage ni extrait sous licence n'est utilisé. Toute ressemblance
> volontaire porte sur le **genre** et le **ton**, jamais sur l'identité protégée.
