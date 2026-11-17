# Godot 4 particle simulation

- **Source**: https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
- **Fetched**: 2026-11-17T20:46:29

**Godot 4 Particle Simulation**
==========================

**Introduction**
---------------

Particle systems are used to simulate complex physical effects, such as sparks, fire, magic particles, smoke, mist, etc. The idea is that a "particle" is emitted at a fixed interval and with a fixed lifetime. During its lifetime, every particle will have the same base behavior. What makes each particle different from the rest and provides a more organic look is the "randomness" associated with each parameter.

**GPUParticles2D vs CPUParticles2D**
-----------------------------------

Godot provides two different nodes for 2D particles: `GPUParticles2D` and `CPUParticles2D`. `GPUParticles2D` is more advanced and uses the GPU to process particle effects. `CPUParticles2D` is a CPU-driven option with near-feature parity with `GPUParticles2D`, but lower performance when using large amounts of particles.

**ParticleProcessMaterial**
-------------------------

To add a process material to your particles node, go to `Process > Material` in your inspector panel. Click on the box next to `Material` and select `New ParticleProcessMaterial`.

**Texture**
------------

A particle system can use a single texture or an animation flipbook. A flipbook is a texture that contains several frames of animation that can be played back or chosen at random during emission.

**Using an Animation Flipbook**
------------------------------

To use an animation flipbook, you must create a new `CanvasItemMaterial` in the `Material` section of the `GPUParticles2D` (or `CPUParticles2D`) node.

**Time Parameters**
--------------------

The following time parameters can be set:

* **Lifetime**: The time in seconds that every particle will stay alive. When lifetime ends, a new particle is created to replace it.
* **One Shot**: When enabled, a `GPUParticles2D` node will emit all of its particles once and then never again.
* **Preprocess**: Used to let the system process a given number of seconds before it is actually drawn the first time.
* **Speed Scale**: The speed scale has a default value of 1 and is used to adjust the speed of a particle system.
* **Explosiveness**: Forces particles to be emitted all together.

**Randomness**
--------------

All particles will have the same base behavior, and the "randomness" associated with each parameter provides a more organic look.

**Example Use Case**
-------------------

To create a particle system that uses a flipbook texture, follow these steps:

1. Create a new `GPUParticles2D` node in your scene.
2. Add a `ParticleProcessMaterial` to the node.
3. Create a new `CanvasItemMaterial` in the `Material` section of the node.
4. Enable `Particle Animation` and set `H Frames` and `V Frames` to the number of columns and rows present in your flipbook texture.
5. Set the `Texture` property to your flipbook texture.

**API Documentation**

* `GPUParticles2D`: [Godot 4 documentation](https://docs.godotengine.org/en/stable/tutorials/physics/particles.html)
* `CPUParticles2D`: [Godot 4 documentation](https://docs.godotengine.org/en/stable/tutorials/physics/particles.html)
* `ParticleProcessMaterial`: [Godot 4 documentation](https://docs.godotengine.org/en/stable/api/2.0/ GD/Node.html#class-ParticleProcessMaterial)
* `CanvasItemMaterial`: [Godot 4 documentation](https://docs.godotengine.org/en/stable/api/2.0/ GD/Node.html#class-CanvasItemMaterial)
