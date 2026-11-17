# Godot 4 particle simulation

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T20:45:09

# Godot 4 Particle Simulation
=====================================

## Introduction

Godot 4 provides a powerful particle simulation system for creating dynamic and organic behavior in 3D scenes. Particle systems can be used to simulate complex physical effects like fire, sparks, smoke, and magical effects.

## Overview of Particle Systems

A particle system consists of two main parts: particles and emitters. Particles are the visible part of the system, while emitters are responsible for creating and controlling the particles.

## Types of Particle Systems

There are two types of 3D particle systems in Godot:

*   **GPUParticles3D**: GPU-accelerated particle systems that run on the GPU and can render hundreds of thousands of particles on modern hardware.
*   **CPUParticles3D**: CPU-based particle systems that run on the CPU and are less flexible than GPUParticles3D but provide better support for older devices and mobile phones.

### GPUParticles3D

GPUParticles3D offer advanced features like:

*   **Custom particle shaders**: allows for fine-grained control over particle behavior and appearance.
*   **Attractor and collision nodes**: enables particles to interact with the environment and each other.
*   **Three types of attractor nodes**:
    *   `GPUParticlesAttractorBox3D`
    *   `GPUParticlesAttractorSphere3D`
    *   `GPUParticlesAttractorVectorField3D`
*   **Several particle collision nodes**:
    *   `GPUParticlesCollisionBox3D`
    *   `GPUParticlesCollisionSphere3D`
    *   `GPUParticlesCollisionSDF3D`
    *   `GPUParticlesCollisionHeightField3D`

### CPUParticles3D

CPUParticles3D offer features like:

*   **Better support for older devices and mobile phones**: runs on the CPU and is less performant than GPUParticles3D but works on a wider range of hardware.

## Creating a 3D Particle System

To create a 3D particle system, you can follow these steps:

1.  Create a new node in your scene and add a `GPUParticles3D` or `CPUParticles3D` node to it.
2.  Set the `particles` property to the number of particles you want to create.
3.  Configure the `emitter` node to control the behavior of the particles.
4.  Add attractor and collision nodes to the system as needed.

## Advanced Topics

Some advanced topics in particle simulation include:

*   **Particle sub-emitters**: allows for more complex and customized particle behavior.
*   **Particle trails**: adds a trail effect to the particles.
*   **Particle turbulence**: adds random motion to the particles.
*   **3D Particle attractors**: controls the behavior of particles in 3D space.
*   **3D Particle collisions**: controls the behavior of particles when they collide with each other or the environment.

## Example Code

Here is an example of how to create a simple 3D particle system:
```gdscript
extends GPUParticles3D

var num_particles = 1000
var spawn_rate = 10

# Create a new emitter node
var emitter = create_node("Node")

# Configure the emitter node
emitter.set_shape(CollisionShape3D.new())
emitter.set_position(Vector3(0, 0, 0))
emitter.set_rotation(Vector3(0, 0, 0))

# Set the spawn rate and number of particles
spawn_rate = 10
num_particles = 1000

# Create a new particle system
var particle_system = create_node("GPUParticles3D")

# Configure the particle system
particle_system.set_particles(num_particles)
particle_system.set_spawn_rate(spawn_rate)

# Add the emitter node to the particle system
particle_system.add_child(emitter)

# Start the particle system
particle_system.start()
```
This code creates a simple 3D particle system that emits particles at a fixed rate. The particles are controlled by an emitter node that is added to the particle system.
