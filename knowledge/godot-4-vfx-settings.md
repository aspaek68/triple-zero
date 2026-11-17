# Godot 4 VFX settings

- **Source**: https://github.com/haowg/GODOT-VFX-LIBRARY
- **Fetched**: 2026-11-17T20:59:01

**Godot 4 VFX Library Documentation**
=====================================

### Overview

The Godot 4 VFX Library is a comprehensive collection of particle effects and shaders designed specifically for action games like Metroidvania and platformers. It features 35+ particle effects and 17+ shaders, as well as easy-to-use managers for global combat and UI effects, environmental and atmospheric effects, and screen effects.

### Features

* **Particle Effects**: 35+ effects, including combat effects (blood splash, energy burst, shield break), movement effects (dash trails, jump dust, wall slide sparks), spell/skill effects (portal vortex, lightning chain), environmental effects (torch fire, fireflies, steam), and more.
* **Shader Effects**: 17+ effects, including character status effects (flash white, blink, dissolve), environmental effects (water surface, heat distortion, portal vortex), post-processing effects (outline glow, radial blur, chromatic aberration, grayscale), and more.
* **Easy-to-Use Managers**: VFX Manager for global combat and UI effects, EnvVFX Manager for environmental and atmospheric effects, and Screen Effects for camera shake, freeze frame, and damage numbers.
* **Auto-cleanup**: Smart memory management for one-shot effects.

### Usage

#### Basic Usage

* **Screen shake on impact**: `VFX.screen_shake(10.0, 0.2)`
* **Blood splash effect**: `VFX.spawn_blood_splash(enemy.global_position)`
* **Flash white on damage**: `VFX.flash_white(player_sprite, 0.1)`
* **Environmental torch**: `EnvVFX.create_torch(self, Vector2(100, 50))`
* **Weather effects**: `EnvVFX.create_rain(self, 600)`

#### Manager APIs

* **VFX Manager**: Extend `vfx.gd` for custom effects
* **EnvVFX Manager**: Extend `env_vfx.gd` for custom effects

#### Customization

* **Particle Effects**: Edit `.tscn` files directly in Godot editor
* **Shaders**: Modify `.gdshader` files or create variants
* **Colors & Timing**: Adjust via GDScript parameters

### Use Cases

* **Combat Systems**: Blood splashes, screen shake, damage numbers, critical hit effects
* **Movement Mechanics**: Dash trails, jump dust, wall slide sparks
* **Environmental Design**: Fire sources, weather effects, ambient particles
* **Spell & Magic**: Portal vortex, lightning chains, summoning circles
* **Status Effects**: Visual feedback for freeze, poison, burning states

### Contributing

* **Report bugs**: via GitHub Issues
* **Suggest features**: for new effects or improvements
* **Submit effects**: new particles, shaders, or presets
* **Improve docs**: examples, tutorials, translations
* **License**: MIT License - see LICENSE file for details
