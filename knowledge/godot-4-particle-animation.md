# Godot 4 particle animation

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T21:00:25

**Godot 4 Particle Animation**
==========================

**Overview**
------------

Particle systems in Godot Engine 4.4 are a powerful tool for simulating complex physical effects like fire, sparks, smoke, and magical effects. They are well-suited for creating dynamic and organic behavior and adding "life" to your scenes.

**Key Concepts**
----------------

*   **Particles**: The visible part of a particle system, representing the tiny specks of dust, flames, or glowing orbs.
*   **Emitters**: The nodes that create the particles, controlling their spawning and behavior.
*   **GPUParticles3D** and **CPUParticles3D**: Two types of 3D particle systems, one processed on the GPU and the other on the CPU.

**GPUParticles3D**
-----------------

*   **Process material properties**: Control how particles are processed, including material properties, particle flags, spawn, accelerations, display, and collision.
*   **Attractors**: Nodes that apply forces to particles, controlling their behavior, such as:
    *   `GPUParticlesAttractorBox3D`
    *   `GPUParticlesAttractorSphere3D`
    *   `GPUParticlesAttractorVectorField3D`
*   **Collisions**: Nodes that simulate particle collisions, including:
    *   `GPUParticlesCollisionBox3D`
    *   `GPUParticlesCollisionSphere3D`
    *   `GPUParticlesCollisionSDF3D`
    *   `GPUParticlesCollisionHeightField3D`

**CPUParticles3D**
-----------------

*   Less flexible than GPUParticles3D
*   Works on a wider range of hardware and provides better support for older devices and mobile phones
*   Not as performant as GPUParticles3D and can't render as many individual particles

**Example Use Cases**
---------------------

*   Simulating fire or sparks
*   Creating dynamic and organic behavior
*   Adding "life" to your scenes

**API Documentation**
---------------------

*   [GPUParticles3D](https://docs.godotengine.org/en/stable/channels/4.4/reference/core/particle_systems.html)
*   [CPUParticles3D](https://docs.godotengine.org/en/stable/channels/4.4/reference/core/particle_systems.html)

**Tips and Tricks**
--------------------

*   Use particle sub-emitters to create complex emission shapes
*   Utilize particle turbulence to add randomness to particle behavior
*   Experiment with different attractor and collision nodes to achieve the desired effect
