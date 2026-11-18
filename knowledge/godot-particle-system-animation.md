# Godot particle system animation

- **Source**: https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
- **Fetched**: 2026-11-18T05:50:14

# Godot Particle System Animation
=====================================

**Introduction**
---------------

Particle systems are used to simulate complex physical effects, such as sparks, fire, magic particles, smoke, mist, etc. In essence, creating a particle system means setting base physics parameters and then adding randomness to them.

**Particle Nodes**
-----------------

Godot provides two different nodes for 2D particles:

*   `GPUParticles2D`: More advanced and uses the GPU to process particle effects.
*   `CPUParticles2D`: CPU-driven option with near-feature parity with `GPUParticles2D`, but lower performance when using large amounts of particles.

**Particle Process Material**
-----------------------------

To add a process material to your particles node, go to `Process` > `Material` in the inspector panel and select `New` > `ParticleProcessMaterial`.

**Texture**
------------

A particle system can use a single texture or an animation flipbook.

### Single Texture

The texture is set via the `Texture` property.

### Animation Flipbook

Particle flipbooks are suited to reproduce complex effects such as smoke, fire, explosions. They can also be used to introduce random texture variation, by making every particle use a different texture.

**Configuring a CanvasItemMaterial**
-------------------------------------

To use an animation flipbook, you must create a new `CanvasItemMaterial` in the `Material` section of the `GPUParticles2D` (or `CPUParticles2D`) node.

### H and V Frames

Enable `Particle Animation` and set `H Frames` and `V Frames` to the number of columns and rows present in your flipbook texture.

### Example Code
```gdscript
// Create a new CanvasItemMaterial
var canvas_item_material = ParticleProcessMaterial.new()
canvas_item_material.set_h_frames(5)  # Number of columns
canvas_item_material.set_v_frames(7)  # Number of rows

// Configure the CanvasItemMaterial
canvas_item_material.set_particle_animation(true)

// Assign the CanvasItemMaterial to the GPUParticles2D node
get_node("GPUParticles2D").set_material(canvas_item_material)
```
**Time Parameters**
-------------------

Particle systems have several time parameters:

*   **Lifetime**: The time in seconds that every particle will stay alive. When lifetime ends, a new particle is created to replace it.
*   **One Shot**: When enabled, a `GPUParticles2D` node will emit all of its particles once and then never again.
*   **Preprocess**: Used to let the system process a given number of seconds before it is actually drawn the first time.
*   **Speed Scale**: Used to adjust the speed of a particle system. Lowering the value will make the particles slower while increasing the value will make the particles much faster.
*   **Explosiveness**: Forces particles to be emitted all together. Ranges are: 0 (Emit particles at regular intervals), 1 (Emit all particles simultaneously), and values in the middle are also allowed.
*   **Randomness**: All particles use a different texture.

**Example Use Cases**
----------------------

*   Simulate sparks, fire, magic particles, smoke, mist, etc.
*   Create explosions or sudden bursts of particles
*   Introduce random texture variation by making every particle use a different texture

By following these guidelines and using the provided code examples, you can create complex and realistic particle systems in Godot.
