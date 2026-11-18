# Particle systems (3D) — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T14:18:40

# Particle Systems (3D) in Godot Engine
=====================================================

Godot Engine provides a powerful tool for simulating complex physical effects using particle systems. This documentation covers the basics of 3D particle systems, including their usage, properties, and advanced features.

## Introduction

Particle systems are ideal for creating dynamic and organic behavior, adding "life" to your scenes. They consist of two main parts: particles and emitters. Particles are the visible part of the system, and emitters are responsible for creating and controlling the particles.

## Types of Particle Systems

Godot Engine provides two types of 3D particle systems:

*   `GPUParticles3D`: Processed on the GPU, these systems are more flexible and performant, but less compatible with older hardware.
*   `CPUParticles3D`: Processed on the CPU, these systems are less flexible and performant, but provide better support for older devices and mobile phones.

## Particle Attractors

Particle attractors apply forces to particles and control their movement. The following nodes are available:

*   `GPUParticlesAttractorBox3D`: Attracts particles to a box-shaped area.
*   `GPUParticlesAttractorSphere3D`: Attracts particles to a sphere-shaped area.
*   `GPUParticlesAttractorVectorField3D`: Attracts particles to a vector field.

## Particle Collisions

Particle collisions allow particles to interact with the environment. The following nodes are available:

*   `GPUParticlesCollisionBox3D`: Simulates collisions with a box-shaped area.
*   `GPUParticlesCollisionSphere3D`: Simulates collisions with a sphere-shaped area.
*   `GPUParticlesCollisionSDF3D`: Simulates collisions with a signed distance field (SDF).
*   `GPUParticlesCollisionHeightField3D`: Simulates collisions with a heightmap.

## Basic Usage

To create a 3D particle system, follow these steps:

1.  Create a new particle system node.
2.  Set the particle flags, spawn rate, and acceleration.
3.  Add emitters to the system.
4.  Customize the process material.
5.  Add particle attractors and collisions as needed.

## Advanced Topics

*   **Particle Sub-Emitters**: Use sub-emitters to create multiple particles from a single emitter.
*   **3D Particle Trails**: Create trails for particles using the `GPUParticlesTrail3D` node.
*   **Particle Turbulence**: Add turbulence to particles using the `GPUParticlesTurbulence3D` node.
*   **3D Particle Attractors**: Use attractors to control particle movement.
*   **3D Particle Collisions**: Use collisions to simulate particle interactions with the environment.

Example Use Case
---------------

Create a fire effect using particle systems:

*   Create a new particle system node.
*   Add an emitter node with a box-shaped area to simulate the fire's base.
*   Add a `GPUParticlesAttractorSphere3D` node to attract particles to the center of the fire.
*   Add a `GPUParticlesCollisionBox3D` node to simulate collisions with the surrounding environment.
*   Customize the process material to control the particle's size, speed, and color.
*   Use particle turbulence and trails to create a realistic effect.
