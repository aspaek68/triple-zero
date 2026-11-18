# Godot 4 VFX particle system

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T05:48:30

**Godot 4 VFX Particle System Documentation**
=============================================

### Introduction

Godot's 3D particle system is a powerful tool for simulating complex physical effects, adding dynamic behavior to scenes, and creating organic and realistic visual effects.

### Overview of Particle System Components

A particle system consists of two main parts:

* **Particles**: The visible part of the particle system, representing the tiny specks of dust, flames, or other effects.
* **Emitters**: The nodes that create particles, controlling their spawning and behavior.

### Types of Particle Systems

Godot provides two types of 3D particle systems:

* **GPUParticles3D**: GPU-accelerated particles, processed on the GPU, and offer high performance and flexibility.
* **CPUParticles3D**: CPU-based particles, processed on the CPU, and provide better support for older devices and mobile phones.

### GPU Particle System Features

GPUParticles3D offers:

* **Custom particle shaders**: Enables advanced visual effects and control over particle behavior.
* **Attractor and collision nodes**: Allows for interaction with the environment and complex collision behavior.

### Attractor Nodes

* **GPUParticlesAttractorBox3D**: Applies a force to particles within a box-shaped area.
* **GPUParticlesAttractorSphere3D**: Applies a force to particles within a sphere-shaped area.
* **GPUParticlesAttractorVectorField3D**: Applies a force to particles within a vector field area.

### Collision Nodes

* **GPUParticlesCollisionBox3D**: Creates a basic collision shape, such as a box or a floor.
* **GPUParticlesCollisionSphere3D**: Creates a basic collision shape, such as a sphere or a wall.
* **GPUParticlesCollisionSDF3D**: Creates a collision shape based on a Signed Distance Field (SDF).
* **GPUParticlesCollisionHeightField3D**: Creates a collision shape based on a heightmap of the environment.

### Basic Usage

To create a 3D particle system:

1. Create a new node in your scene.
2. Set the **Node Type** to **Particle System**.
3. Configure the **Process Material** properties, **Spawn** settings, and **Accelerations**.
4. Add **Display** and **Collision** nodes as needed.
5. Use **Sub-emitter** nodes to create complex emission shapes.

### Advanced Topics

* **Particle Sub-emitters**: Create complex emission shapes and behaviors.
* **Particle Trails**: Create trails and paths for particles.
* **Particle Turbulence**: Add randomization and variation to particle behavior.
* **3D Particle Attractors**: Apply forces to particles using attractor nodes.
* **3D Particle Collisions**: Create complex collision behavior using collision nodes.

### APIs and Examples

* **Node API**: Consult the Godot 4 documentation for the `Node` API.
* **Node Reference**: Consult the Godot 4 documentation for the `ParticleSystem` node reference.
* **Example Scenes**: Refer to the Godot 4 documentation for example scenes and tutorials.
