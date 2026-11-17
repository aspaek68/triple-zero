# Godot 4 particle animation tutorial

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T21:14:51

# Godot 4 Particle Animation Tutorial
==========================

## Introduction

Particle systems are a powerful tool for simulating complex physical effects in Godot. They can be used to create dynamic and organic behavior, adding "life" to your scenes.

## Key Concepts

*   Particle systems consist of two main parts: **particles** and **emitters**.
*   **Particles** are the visible part of a particle system, representing the tiny specks of dust, flames, or other effects.
*   **Emitters** are responsible for creating the particles, controlling where and how they are spawned.

## 3D Particle Nodes

Godot offers two types of 3D particle systems:

*   **GPUParticles3D**: Processed on the GPU, allowing for more complex behaviors and larger particle counts.
*   **CPUParticles3D**: Processed on the CPU, providing better support for older hardware and mobile phones.

### GPU Particle Nodes

*   **GPUParticlesAttractorBox3D**, **GPUParticlesAttractorSphere3D**, and **GPUParticlesAttractorVectorField3D**: Apply forces to particles, influencing their movement and behavior.
*   **GPUParticlesCollisionBox3D** and **GPUParticlesCollisionSphere3D**: Create basic collision shapes.
*   **GPUParticlesCollisionSDF3D** and **GPUParticlesCollisionHeightField3D**: Provide more complex collision behavior.

### CPU Particle Nodes

*   **CPUParticles3D**: Processed on the CPU, providing better support for older hardware and mobile phones.
*   **GPUParticles3D**: More flexible and performant, allowing for custom particle shaders and interaction with the environment.

## Basic Usage

1.  **Creating a 3D Particle System**:
    *   Set the particle system properties, such as material, flags, and spawn interval.
    *   Configure the emitter node, including its shape and spawn position.
2.  **Processing Material Properties**:
    *   Assign a material to the particle system to control its visual appearance.
3.  **Spawn**:
    *   Define the spawn point and interval to create new particles.
4.  **Accelerations**:
    *   Apply forces to particles to influence their movement and behavior.
5.  **Display**:
    *   Adjust the display settings to control the particle system's visibility.
6.  **Collision**:
    *   Configure the collision nodes to interact with the environment.
7.  **Sub-Emitters**:
    *   Create sub-emitters to further control the particle system's behavior.

### Advanced Topics

*   **Particle Sub-Emitters**: Create sub-emitters to divide the particle system into smaller parts.
*   **3D Particle Trails**: Use trails to create a visual representation of particle movement.
*   **Particle Turbulence**: Add turbulence to the particle system to create more realistic behavior.
*   **3D Particle Attractors**: Apply forces to particles using attractor nodes.
*   **3D Particle Collisions**: Configure collision nodes to interact with the environment.

By mastering these concepts and techniques, you can create stunning particle effects in Godot and bring your scenes to life.
