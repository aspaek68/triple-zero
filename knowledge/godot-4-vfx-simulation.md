# Godot 4 VFX simulation

- **Source**: https://github.com/haowg/GODOT-VFX-LIBRARY
- **Fetched**: 2026-11-17T20:51:54

**Godot 4 VFX Simulation Library**
================================

**Overview**
------------

A comprehensive collection of 35+ particle effects and 17+ shaders for Godot 4, designed specifically for action games.

**Key Features**
----------------

### Particle Effects

* Combat Effects: Blood splash, energy burst, shield break, sparks, combo rings
* Movement Effects: Dash trails, jump dust, wall slide sparks
* Spell/Skill Effects: Portal vortex, lightning chain, ice frost, fireball trails
* Environmental Effects: Torch fire, fireflies, steam, water splash, falling leaves, rain, snow

### Shader Effects

* Character Status: Flash white, blink, dissolve, frozen, poison, burning, petrify
* Environmental: Water surface, heat distortion, portal vortex, energy barrier
* Post-Processing: Outline glow, radial blur, chromatic aberration, grayscale

### Easy-to-Use Managers

* VFX Manager: Global combat and UI effects with simple API
* EnvVFX Manager: Environmental and atmospheric effects
* Screen Effects: Camera shake, freeze frame, damage numbers
* Auto-cleanup: Smart memory management for one-shot effects

### Production Showcase

* Land of Oblivion is a 2D action-adventure built with Godot, showcasing the VFX library's capabilities.

**Installation**
----------------

### Quick Start

1. Manual Installation: Download the latest release, extract to your project's `addons/` folder, and enable "VFX Library" in Project Settings.
2. Git Clone: Clone the repository using `git clone https://github.com/haowg/GODOT-VFX-LIBRARY.git vfx_library`.
3. Symbolic Link: Create a symbolic link to the `vfx_library` folder for easy development.

**Basic Usage**
----------------

* Screen shake on impact: `VFX.screen_shake(10.0, 0.2)`
* Blood splash effect: `VFX.spawn_blood_splash(enemy.global_position)`
* Flash white on damage: `VFX.flash_white(player_sprite, 0.1)`

**Documentation**
-----------------

* Installation Guide: Detailed setup instructions
* API Reference: Complete function documentation
* Demo Examples: Interactive demo scene
* Use Cases: Combat systems, movement mechanics, environmental design, spell & magic, status effects

**Community**
--------------

* Contributing: Welcome contributions! See `CONTRIBUTING.md` for guidelines.
* Community Feedback: Report bugs via GitHub Issues or suggest features.
