# Godot 4 VFX

- **Source**: https://github.com/haowg/GODOT-VFX-LIBRARY
- **Fetched**: 2026-11-17T20:42:13

# Godot 4 VFX Library
================================

A comprehensive collection of particle effects and shaders for Godot 4, designed specifically for action games like Metroidvania and platformers.

## Features
---------------

* 35+ particle effects, including:
	+ Combat Effects (blood splash, energy burst, shield break, sparks, combo rings)
	+ Movement Effects (dash trails, jump dust, wall slide sparks)
	+ Spell/Skill Effects (portal vortex, lightning chain, ice frost, fireball trails)
	+ Environmental Effects (torch fire, fireflies, steam, water splash, falling leaves, rain, snow)
* 17+ shader effects, including:
	+ Character Status (flash white, blink, dissolve, frozen, poison, burning, petrify)
	+ Environmental (water surface, heat distortion, portal vortex, energy barrier)
	+ Post-Processing (outline glow, radial blur, chromatic aberration, grayscale)
* Easy-to-use managers for global combat and UI effects, environmental and atmospheric effects, screen effects, and auto-cleanup for smart memory management

## Installation
--------------

* Manual Installation: Download the latest release, extract to your project's `addons/` folder, and enable "VFX Library" in Project Settings → Plugins
* Git Clone: Clone the repository to your project's `addons/vfx_library/` folder
* Symbolic Link: Clone to a central location and link to your project's `addons/` folder for easy use across multiple projects

## Basic Usage
----------------

* Screen shake on impact: `VFX.screen_shake(10.0, 0.2)`
* Blood splash effect: `VFX.spawn_blood_splash(enemy.global_position)`
* Flash white on damage: `VFX.flash_white(player_sprite, 0.1)`

## Documentation
-----------------

* API Reference: Complete function documentation for all effects and managers
* Demo Examples: Interactive demo scene to test all effects in real-time
* Installation Guide: Detailed setup instructions

## Use Cases
-------------

* Combat Systems: Blood splashes, screen shake, damage numbers, critical hit effects
* Movement Mechanics: Dash trails, jump dust, wall slide sparks
* Environmental Design: Fire sources, weather effects, ambient particles
* Spell & Magic: Portal vortex, lightning chains, summoning circles
* Status Effects: Visual feedback for freeze, poison, burning states

## Contributing
--------------

* Report bugs via GitHub Issues
* Suggest features for new effects or improvements
* Submit effects, presets, or presets
* Improve docs: examples, tutorials, translations
