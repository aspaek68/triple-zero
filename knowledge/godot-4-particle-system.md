# godot 4 particle system

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T20:39:59

**Godot 4 Particle System**
================================

**Introduction**
---------------

Godot 4's particle system is a powerful tool for simulating complex physical effects, such as fire, sparks, smoke, and magical effects. It allows for dynamic and organic behavior, adding "life" to your scenes.

**Main Components**
--------------------

A particle system consists of two main parts: **particles** and **emitters**.

*   **Particles**: The visible part of a particle system, represented by tiny specks of dust, flames, glowing orbs, etc.
*   **Emitters**: The source of the particles, controlling where and how particles are spawned.

**Types of Particle Systems**
-----------------------------

Godot offers two types of 3D particle systems:

*   **GPUParticles3D**: Processed on the GPU, allowing for high-performance rendering of hundreds of thousands of particles on modern hardware.
*   **CPUParticles3D**: Processed on the CPU, providing better support for older devices and mobile phones, but with lower performance and fewer options.

**GPU Particle System Features**
--------------------------------

GPUParticles3D offer advanced features, including:

*   **Custom particle shaders**: Allows for high degree of customization and flexibility.
*   **Attractor and collision nodes**: Enables interaction with the environment, creating complex behaviors.

**Attractor Nodes**
--------------------

Three types of attractor nodes are available:

*   **GPUParticlesAttractorBox3D**: Applies a force to all particles in its reach, pulling them closer or pushing them away.
*   **GPUParticlesAttractorSphere3D**: Similar to the box attractor, but with a spherical force field.
*   **GPUParticlesAttractorVectorField3D**: Applies a force to all particles in its reach, with a direction based on a vector field.

**Collision Nodes**
-------------------

Several particle collision nodes are available:

*   **GPUParticlesCollisionBox3D** and **GPUParticlesCollisionSphere3D**: Simple collision nodes for basic shapes.
*   **GPUParticlesCollisionSDF3D**: Useful for indoor scenes, allowing for collision detection without individual colliders.
*   **GPUParticlesCollisionHeightField3D**: Useful for large outdoor scenes, creating a heightmap for collision detection.

**Basic Usage**
---------------

To create a 3D particle system:

1.  Create a **GPUParticles3D** or **CPUParticles3D** node.
2.  Configure the **Spawn** property to control particle emission.
3.  Set the **Accelerations** property to control particle movement.
4.  Adjust the **Display** property to control particle visibility.
5.  Use the **Collision** property to set up collision detection.

**Advanced Topics**
------------------

*   **Particle sub-emitters**: Allow for more complex emission behaviors.
*   **Particle trails**: Creates a trail behind the particles.
*   **Particle turbulence**: Adds randomness to particle behavior.
*   **3D Particle attractors**: Enables interaction with the environment.
*   **3D Particle collisions**: Allows for complex collision detection.

### Example Code

Here is an example of creating a simple GPUParticles3D node:
```gdscript
extends GPUParticles3D

func _ready():
    # Configure spawn properties
    spawn = 10.0
    duration = 1.0

    # Configure accelerations properties
    acceleration = 100.0
    velocity = 50.0

    # Configure display properties
    display = true
    size = 10.0
```
This code creates a GPUParticles3D node with a spawn rate of 10 particles per second, a duration of 1 second, and accelerations of 100 and 50. The display properties are set to true, with a size of 10.
