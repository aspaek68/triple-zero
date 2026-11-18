# Godot 4 particle system documentation

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T05:47:11

Particle Systems (3D) Documentation
=====================================

**Introduction**

Particle systems are a powerful tool for simulating complex physical effects in Godot Engine 4.4. They are well-suited for creating dynamic and organic behavior, adding "life" to your scenes.

**Particle System Components**

A particle system consists of two main parts:

*   **Particles**: The visible part of the particle system, representing the tiny specks of dust, flames, or other effects.
*   **Emitters**: The source of the particles, controlling where and how they are spawned.

**GPU vs. CPU Particle Systems**

Godot Engine 4.4 offers two types of 3D particle systems:

*   **GPUParticles3D**: Processed on the GPU, providing better performance and flexibility on modern hardware.
*   **CPUParticles3D**: Processed on the CPU, offering better support for older devices and mobile phones, but with limited performance and options.

**GPU Particle System Features**

GPUParticles3D offer:

*   **Custom particle shaders**: Highly flexible and powerful.
*   **Attractor and collision nodes**: Interact with the environment, creating complex simulations.

**Attractor Nodes**

There are three types of attractor nodes:

*   **GPUParticlesAttractorBox3D**: Applies a force to particles within a box.
*   **GPUParticlesAttractorSphere3D**: Applies a force to particles within a sphere.
*   **GPUParticlesAttractorVectorField3D**: Applies a force to particles based on a vector field.

**Collision Nodes**

There are several particle collision nodes:

*   **GPUParticlesCollisionBox3D**: Basic collision with a box.
*   **GPUParticlesCollisionSphere3D**: Basic collision with a sphere.
*   **GPUParticlesCollisionSDF3D**: Indoor scene collision without individual collider creation.
*   **GPUParticlesCollisionHeightField3D**: Large-scale outdoor scene collision using a heightmap.

**Basic Usage**

Creating a 3D particle system involves:

*   Setting up particles and emitters.
*   Configuring properties, such as spawn rate, acceleration, display, and collision.
*   Using sub-emitters, trails, turbulence, and attractors.

**Advanced Topics**

Particle sub-emitters, 3D particle trails, particle turbulence, 3D particle attractors, and complex emission shapes offer more advanced features for creating complex simulations.

API Documentation
-----------------

For detailed information on the particle system API, please refer to the [Godot Engine 4.4 documentation](https://docs.godotengine.org/en/stable/extended/physics/3d/particles.html).

Example Use Case
----------------

Here is an example of creating a simple particle system using GPUParticles3D:
```gdscript
extends Node

var particles = P2DParticles3D.new()

# Create a new particle system
particles.create()

# Set up particle properties
particles.set_min_particle_count(100)
particles.set_max_particle_count(1000)
particles.set_particle_speed(10)
particles.set_particle_color(1, 0, 0)

# Set up emitter properties
particles.set_emitter_shape(0, 0, 0, 0, 0, 0)
particles.set_emitter_size(0.1, 0.1, 0.1)

# Add attractor node
particles.add_attractor(GPUParticlesAttractorBox3D.new())

# Add collision node
particles.add_collision(GPUParticlesCollisionBox3D.new())
```
This code creates a new particle system, sets up particle and emitter properties, and adds an attractor node to draw particles towards the center.
