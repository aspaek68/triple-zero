# Godot particle system documentation

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T17:00:23

Particle Systems (3D) in Godot Engine
=====================================

Table of Contents
-----------------

1. [Introduction](#introduction)
2. [Particles and Emitters](#particles-and-emitters)
3. [Node Overview](#node-overview)
4. [CPU Particle Systems](#cpu-particle-systems)
5. [GPU Particle Systems](#gpu-particle-systems)
6. [Particle Attractors](#particle-attractors)
7. [Particle Collision Nodes](#particle-collision-nodes)
8. [Basic Usage](#basic-usage)
9. [Advanced Topics](#advanced-topics)

### Introduction

Particle systems are a powerful tool in Godot Engine for simulating complex physical effects like fire, sparks, smoke, and magical effects. They are well-suited for creating dynamic and organic behavior and adding "life" to your scenes.

### Particles and Emitters

A particle system consists of two main parts: particles and emitters.

*   **Particles**: The visible part of a particle system, represented by tiny specks of dust, flames, glowing orbs, etc. Particles can be randomized to create organic behavior.
*   **Emitters**: The source of particles, controlling where and how particles are spawned. Emitters can have a shape, which determines the particle spawning pattern.

### Node Overview

Godot provides two types of 3D particle systems:

*   **GPUParticles3D**: Processed on the GPU, rendering hundreds of thousands of particles on modern hardware. Can be used with custom particle shaders.
*   **CPUParticles3D**: Processed on the CPU, providing better support for older devices and mobile phones. However, less flexible and performant than GPU particle systems.

### CPU Particle Systems

*   Pros:
    *   Works on a wider range of hardware and older devices.
    *   Provides better support for mobile phones.
*   Cons:
    *   Less flexible and performant than GPU particle systems.
    *   Limited options for control.

### GPU Particle Systems

*   Pros:
    *   Renders hundreds of thousands of particles on modern hardware.
    *   Can be used with custom particle shaders.
    *   Can interact with the environment using attractor and collision nodes.
*   Cons:
    *   Requires modern hardware to run efficiently.
    *   Limited support for older devices and mobile phones.

### Particle Attractors

*   **GPUParticlesAttractorBox3D**: Applies a force to particles in a box-shaped area, pulling them closer or pushing them away.
*   **GPUParticlesAttractorSphere3D**: Applies a force to particles within a sphere-shaped area, pulling them closer or pushing them away.
*   **GPUParticlesAttractorVectorField3D**: Applies a force to particles in a vector field-shaped area, pulling them closer or pushing them away.

### Particle Collision Nodes

*   **GPUParticlesCollisionBox3D**: Simulates basic collisions with box-shaped objects.
*   **GPUParticlesCollisionSphere3D**: Simulates basic collisions with sphere-shaped objects.
*   **GPUParticlesCollisionSDF3D**: Simulates complex collisions with SDF (Smoothed Distance Field) objects.
*   **GPUParticlesCollisionHeightField3D**: Simulates complex collisions with height field objects.

### Basic Usage

1.  Create a new particle system.
2.  Set the particle system properties, such as material, flags, spawn, acceleration, display, and collision.
3.  Configure the emitter, including the shape and spawn pattern.

### Advanced Topics

*   **Particle Sub-Emitters**: Create sub-emitters to generate particles with different properties.
*   **3D Particle Trails**: Create trails for particles to follow.
*   **Particle Turbulence**: Add turbulence to particles to create more realistic behavior.
*   **3D Particle Attractors**: Use attractor nodes to control particle behavior.
*   **3D Particle Collisions**: Use collision nodes to simulate particle interactions with the environment.

Example Code
------------

```gdscript
# Create a new particle system
var particle_system = Particle3D.new()

# Set the particle system properties
particle_system.material = Material.new()
particle_system.flags = Flags.ALL
particle_system.spawn = 10
particle_system.acceleration = Vector3(0, 0, 1)
particle_system.display = true
particle_system.collision = CollisionShape3D.new()

# Configure the emitter
var emitter = particle_system.emitter
emitter.shape = Emittershape3D.BOX
emitter.spawn_pattern = EmitterspawnPattern.REPEAT
```

This code creates a new particle system, sets its properties, and configures the emitter to spawn particles at a fixed interval and with a fixed lifetime. The particles are then attracted to a box-shaped area, creating a simple particle system.
