# Godot 4 particle system tutorial

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T20:53:59

**Godot 4 Particle System Tutorial**
=====================================

**Overview**
------------

Godot's particle system is a powerful tool for simulating complex physical effects, adding dynamic behavior, and creating organic visuals. This tutorial covers the basics of 3D particle systems, including particles and emitters, as well as advanced topics like attractors, collisions, and sub-emitters.

**Key Concepts**
----------------

*   **Particles**: The visible part of a particle system, which can be randomized to create organic behavior.
*   **Emitters**: The source of particles, controlling their spawn, speed, and movement direction.
*   **GPUParticles3D**: GPU-accelerated particle systems, ideal for modern hardware and custom shaders.
*   **CPUParticles3D**: CPU-based particle systems, suitable for older devices and mobile phones.

**Particle Node Overview**
-------------------------

*   **GPUParticles3D**: Processed on the GPU, with custom shaders and interaction with the environment.
*   **CPUParticles3D**: Processed on the CPU, with limitations on performance and available options.

**Advanced Topics**
-----------------

### Attractors

*   **GPUParticlesAttractorBox3D**: Applies a force to all particles within a box.
*   **GPUParticlesAttractorSphere3D**: Applies a force to all particles within a sphere.
*   **GPUParticlesAttractorVectorField3D**: Applies a force to all particles based on a vector field.

### Collisions

*   **GPUParticlesCollisionBox3D**: Basic collision with a box.
*   **GPUParticlesCollisionSphere3D**: Basic collision with a sphere.
*   **GPUParticlesCollisionSDF3D**: Collision with a signed distance field (SDF).
*   **GPUParticlesCollisionHeightField3D**: Collision with a heightmap.

### Sub-Emitters

*   **Particle sub-emitters**: Used to create complex emission patterns.

### Trails

*   **3D Particle trails**: Create trails behind particles.

### Turbulence

*   **Particle turbulence**: Adds random movement to particles.

### Complex Emission Shapes

*   **Complex emission shapes**: Create complex shapes for particle emission.

**API References**
------------------

*   `GPUParticles3D`
*   `CPUParticles3D`
*   `GPUParticlesAttractorBox3D`
*   `GPUParticlesAttractorSphere3D`
*   `GPUParticlesAttractorVectorField3D`
*   `GPUParticlesCollisionBox3D`
*   `GPUParticlesCollisionSphere3D`
*   `GPUParticlesCollisionSDF3D`
*   `GPUParticlesCollisionHeightField3D`
*   `Particle sub-emitters`
*   `3D Particle trails`
*   `Particle turbulence`

**Example Use Cases**
---------------------

*   Simulate fire or sparks using GPU-accelerated particle systems.
*   Create dynamic and organic behavior using randomization and attractors.
*   Add complex collision behavior to particles using heightfields and SDFs.
