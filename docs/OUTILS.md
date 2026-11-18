# Outils — chaîne de production TRIPLE ZERO

Tout est **gratuit** et, sauf mention contraire, **libre** (GPL / MIT / Apache /
CC0). Rien n'est copié depuis un jeu commercial : les textures, sons et
maillages viennent de Poly Haven, ambientCG (CC0) ou de nos générateurs Python.

## Installés sur cette machine

| Outil | Version | Rôle dans le projet | Commande |
|---|---|---|---|
| **Godot** | 4.7.2 | moteur, rendu Forward+ | `LANCER_QUALITE_HAUTE.bat` |
| **Blender** | 5.3 | modélisation / sculpture / export glTF | `blender --background --python <script>` |
| **GIMP** | 3.2.8 | retouche d'image (HDRI, masques) | `%LOCALAPPDATA%\Programs\GIMP 3\bin\gimp-3.2.exe` |
| **Krita** | 5.3.4 | peinture de textures (pipeline PBR) | `krita.exe` |
| **Material Maker** | 1.7 | matériaux PBR **procéduraux** → albédo/normal/rough/AO/métal | `material_maker` |
| **Inkscape** | 1.4.4 | icônes et HUD en vectoriel (SVG) | `inkscape.exe` |
| **Audacity** | 4.x | montage des WAV (boucles, normalisation) | `Audacity.exe` |
| **LMMS** | 1.2.2 | musique (les 4 couches adaptatives) | `lmms.exe` |
| **FFmpeg** | 7.x | conversion audio/vidéo, planches de textures | `ffmpeg` |
| **Real-ESRGAN** (ncnn-vulkan) | 2022-04 | upscale IA des textures (×2/×4) | `tools/upscale_ai.py` |
| **Python + Pillow** | 3.13 | générateurs d'assets, scripts | `python tools/...` |
| **Ollama** | — | `llama3.2` + `nomic-embed-text` pour la base de connaissances | `ollama serve` |

## Scripts du dépôt

| Script | Ce qu'il fait |
|---|---|
| `tools/gen_assets.py` | textures procédurales + WAV (albédo, normale Sobel, rugosité, AO multi-rayon) |
| `tools/gen_meshes.py` | props glTF de repli |
| `tools/fetch_cc0_textures.ps1` | pack ambientCG 1K (CC0) |
| `tools/fetch_cc0_models.ps1` | props Poly Haven (CC0) |
| `tools/fetch_cc0_hdri.ps1` + `hdri_sun.py` | ciel HDRI CC0 + position du soleil |
| `tools/upscale_ai.py` | upscale : **Real-ESRGAN** sur les albédos, **Lanczos** sur les cartes de données (normale/rugosité/AO) |
| `tools/set_texture_import.py` | passe les `.import` en VRAM compressé (BPTC) + mipmaps |
| `tools/learn.py`, `tools/search.py`, `tools/embed.py` | base de connaissances locale |

## Ce qui reste à faire « à la main » (compte requis)

Ces services ne peuvent pas être automatisés depuis un terminal :

- **Mixamo** (Adobe, gratuit) — animations humanoïdes (marche, course, mort).
  Télécharger en FBX, importer dans Blender, exporter en glTF.
- **Poly Haven / ambientCG** — téléchargement manuel possible, mais les scripts
  du dépôt le font déjà.
- **Quixel/Fab**, **Substance**, **Marvelous Designer** — payants, non utilisés.

## Limite matérielle

GPU : **GeForce GTX 970, 4 Go**. Elle n'a **pas** de cœurs RT (pas de ray tracing
matériel) et peu de VRAM, donc :

- SDFGI, brouillard volumétrique et SSR restent activés mais avec des réglages
  économes ;
- textures plafonnées à 2048 px (×2) et compressées en BPTC ;
- pas de TAA (incompatible avec le renderer GL de secours).
