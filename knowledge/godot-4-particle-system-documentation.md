# Godot 4 particle system documentation

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T20:49:36

**Godot 4 Particle System Documentation**
=====================================

**Introduction**
---------------

Particle systems in Godot Engine 4.4 are GPU-accelerated, allowing for complex physical effects and dynamic behavior in scenes. They are ideal for creating organic effects like fire, sparks, smoke, and magical effects.

**Particle System Components**
-----------------------------

A particle system consists of two main parts:

*   **Particles**: The visible part of a particle system, which can have random size, speed, movement direction, and color over its lifetime.
*   **Emitters**: The source of particles, controlling where and how they are spawned.

**Node Overview**
----------------

### 3D Particle Nodes

Godot provides two types of 3D particle systems:

*   **GPUParticles3D**: Processed on the GPU, offering high performance and flexibility.
*   **CPUParticles3D**: Processed on the CPU, providing better support for older devices and mobile phones.

### Attractor Nodes

Attractor nodes apply a force to all particles in their reach, influencing their movement:

*   **GPUParticlesAttractorBox3D**
*   **GPUParticlesAttractorSphere3D**
*   **GPUParticlesAttractorVectorField3D**

### Collision Nodes

Collision nodes simulate particle interactions with the environment:

*   **GPUParticlesCollisionBox3D**
*   **GPUParticlesCollisionSphere3D**
*   **GPUParticlesCollisionSDF3D**
*   **GPUParticlesCollisionHeightField3D**

**Basic Usage**
-------------

### Creating a 3D Particle System

To create a 3D particle system:

1.  Create a new node and add the `GPUParticles3D` or `CPUParticles3D` node to it.
2.  Configure the particle system properties, such as material, spawn rate, acceleration, and display settings.

### Particle System Properties

*   `Process material properties`: Enables or disables material processing for particles.
*   `Particle flags`: Sets particle flags, such as birth rate, lifetime, and emission shapes.
*   `Spawn`: Configures particle spawning settings, including spawn rate, distribution, and velocity.
*   `Accelerations`: Sets particle acceleration settings, including gravity and velocity.
*   `Display`: Controls how particles are displayed, including color and opacity.

### Advanced Topics

*   **Particle Sub-Emitters**: Enables or disables sub-emitters for particles.
*   **3D Particle Trails**: Configures particle trail settings, including trail length and color.
*   **Particle Turbulence**: Enables or disables turbulence for particles.
*   **3D Particle Attractors**: Configures attractor node settings, including shape and force.
*   **3D Particle Collisions**: Configures collision node settings, including shape and collision detection.

Example:
```gdscript
extends GPUParticles3D

func _ready():
    # Set particle system properties
    spawn_rate = 10
    acceleration = Vector3(0, -9.8, 0)
    display = true
    material = Material.new()
    material.set_shader_param("color", Color(1, 0, 0))  # Set material color
```
This example sets the spawn rate, acceleration, and display settings for a particle system, and assigns a custom material with a red color.
