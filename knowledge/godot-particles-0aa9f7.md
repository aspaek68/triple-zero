# godot particles

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T19:36:22

**Godot Particles**
================

**Introduction**
---------------

Godot particles are a powerful tool for simulating complex physical effects, such as fire, sparks, smoke, and magical effects, in 3D scenes.

**Particle System Overview**
---------------------------

A particle system consists of two main parts:

*   **Particles**: The visible part of the system, which can be randomized to create organic behavior.
*   **Emitters**: The source of particles, which can have a shape that controls where and how particles are spawned.

**Node Overview**
----------------

There are two types of 3D particle systems in Godot:

*   **GPUParticles3D**: Processed on the GPU, offering high performance and flexibility.
*   **CPUParticles3D**: Processed on the CPU, providing better support for older devices and mobile phones.

**GPU Particle System Features**
-------------------------------

*   **Attractors**: Apply forces to particles, pulling them closer or pushing them away.
*   **Collision**: Allow particles to interact with the environment, such as walls, floors, and ceilings.

**CPU Particle System Features**
-------------------------------

*   **Collision**: Allow particles to interact with the environment, such as walls, floors, and ceilings.

**Basic Usage**
----------------

*   **Spawn**: Control where and how particles are spawned.
*   **Accelerations**: Define the acceleration of particles.
*   **Display**: Control the display of particles.

**Advanced Topics**
-----------------

*   **Particle Sub-Emitters**: Create multiple sub-emitters within a particle system.
*   **Particle Trails**: Create trails behind particles.
*   **Particle Turbulence**: Add turbulence to particles.
*   **Attractors**: Apply forces to particles.
*   **Collisions**: Allow particles to interact with the environment.
*   **Complex Emission Shapes**: Create complex emission shapes.

**API References**
-----------------

*   **`GPUParticles3D`**: [Godot Documentation](https://docs.godotengine.org/en/stable/community/tutorials/physics/particle_systems.html)
*   **`CPUParticles3D`**: [Godot Documentation](https://docs.godotengine.org/en/stable/community/tutorials/physics/particle_systems.html)
*   **`GPUParticlesAttractorBox3D`**: [Godot Documentation](https://docs.godotengine.org/en/stable/community/tutorials/physics/particle_attractors.html)
*   **`GPUParticlesCollisionBox3D`**: [Godot Documentation](https://docs.godotengine.org/en/stable/community/tutorials/physics/particle_collisions.html)
