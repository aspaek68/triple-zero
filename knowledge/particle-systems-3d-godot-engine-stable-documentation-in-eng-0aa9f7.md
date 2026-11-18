# Particle systems (3D) — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T03:01:12

**Particle Systems (3D) in Godot Engine**
=====================================

**Introduction**
---------------

Particle systems are a powerful tool in Godot Engine for simulating complex physical effects, adding dynamic and organic behavior to scenes, and creating realistic simulations of fire, sparks, smoke, and magical effects.

**Overview**
------------

A particle system consists of two main parts: particles and emitters. Particles are the visible part of the system, while emitters are responsible for creating the particles.

**Types of Particle Systems**
-----------------------------

*   **GPUParticles3D**: GPU-accelerated particle systems that run on the GPU, providing high performance and flexibility.
*   **CPUParticles3D**: CPU-based particle systems that are less flexible but work on a wider range of hardware.

**Particle Properties and Behavior**
--------------------------------------

*   **Particles**: Can be randomized to create organic behavior, with attributes such as size, speed, movement direction, and color.
*   **Emitters**: Can have a shape, controlling where and how particles are spawned.
*   **Attractors**: Nodes that apply a force to particles, pulling them closer or pushing them away.
*   **Collision Nodes**: Nodes that create complex collision behavior, such as collision with boxes, spheres, or heightmaps.

**Basic Usage**
----------------

*   Creating a 3D particle system
*   Setting properties, such as spawn interval, acceleration, display, and collision
*   Customizing the process material and particle flags

**Advanced Topics**
-------------------

*   **Particle Sub-Emitters**: Creating sub-emitters to control the behavior of particles
*   **3D Particle Trails**: Creating trails of particles for a more realistic effect
*   **Particle Turbulence**: Adding randomization to particle behavior for a more organic effect
*   **3D Particle Attractors**: Using attractor nodes to create complex particle behavior
*   **3D Particle Collisions**: Using collision nodes to create complex collision behavior
*   **Complex Emission Shapes**: Creating complex emission shapes using custom shaders and material properties.

**APIs and Examples**
----------------------

*   `GPUParticles3D`
*   `CPUParticles3D`
*   `GPUParticlesAttractorBox3D`
*   `GPUParticlesAttractorSphere3D`
*   `GPUParticlesAttractorVectorField3D`
*   `GPUParticlesCollisionBox3D`
*   `GPUParticlesCollisionSphere3D`
*   `GPUParticlesCollisionSDF3D`
*   `GPUParticlesCollisionHeightField3D`
*   Custom shaders and material properties for advanced usage.

**Example Use Case**
--------------------

```gdscript
# Create a GPUParticles3D system
var particles = GPUParticles3D.new()

# Set properties
particles.set_spawn_interval(1.0)
particles.set_acceleration(Vector3(0, 0, 1))
particles.set_display(true)
particles.set_collision(true)

# Add emitters
var emitter = Node3D.new()
emitter.add_child(particles)

# Create a custom shader for the particles
var shader = ShaderMaterial.new()
shader.set_shader_type(ShaderType.ShaderMaterial)
shader.set_shader_code(code)

# Set the shader as the material for the particles
particles.set_material(shader)
```
