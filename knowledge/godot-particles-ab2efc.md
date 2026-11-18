# Godot particles

- **Source**: https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
- **Fetched**: 2026-11-18T15:41:26

**Godot Particles Documentation**
================================

**Introduction**
---------------

Particle systems in Godot Engine are used to simulate complex physical effects, such as sparks, fire, magic particles, smoke, mist, etc. The idea is to emit particles at a fixed interval and with a fixed lifetime. During its lifetime, every particle will have the same base behavior, but with randomness associated with each parameter, creating a more organic look.

**Particle Nodes**
-----------------

Godot provides two different nodes for 2D particles:

*   `GPUParticles2D`: more advanced and uses the GPU to process particle effects.
*   `CPUParticles2D`: CPU-driven option with near-feature parity with `GPUParticles2D`, but lower performance when using large amounts of particles.

**Particle Process Material**
-----------------------------

A `ParticleProcessMaterial` is required for the `GPUParticles2D` node to function. To add a process material, go to the `Process` menu in the inspector panel and select `New ParticleProcessMaterial`.

**Texture**
------------

A particle system can use a single texture or an animation flipbook. The texture is set via the `Texture` property.

**Flipbook**
-------------

A flipbook is a texture that contains several frames of animation that can be played back, or chosen at random during emission. To use an animation flipbook, create a new `CanvasItemMaterial` in the `Material` section of the `GPUParticles2D` node, and enable `Particle Animation`. Set `H Frames` and `V Frames` to the number of columns and rows present in your flipbook texture.

**Time Parameters**
------------------

The following time parameters control the behavior of particle systems:

*   `Lifetime`: the time in seconds that every particle will stay alive.
*   `One Shot`: enables the particle system to emit all of its particles once and then never again.
*   `Preprocess`: allows the system to process a given number of seconds before it is actually drawn for the first time.
*   `Speed Scale`: adjusts the speed of a particle system. Lowering the value makes the particles slower, while increasing the value makes them faster.
*   `Explosiveness`: forces particles to be emitted all together, useful for creating explosions or sudden bursts of particles.
*   `Randomness`: introduces randomness to the particle system, creating a more organic look.

**Example Code**
----------------

```gd
extends GPUParticles2D

var material = ParticleProcessMaterial.new()
material.set_texture("res://texture.png")
material.set_flipbook("res://flipbook.png")

var lifetime = 2.0
var speed_scale = 1.0
var explosiveness = 0.0
var randomness = 0.5

emit_rate = 10.0
speed_scale = 1.0
```

Note: This is a basic example and can be customized to fit your specific needs.
