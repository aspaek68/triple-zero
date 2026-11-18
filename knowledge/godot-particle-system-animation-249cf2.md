# Godot particle system animation

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T05:50:59

**Godot Particle System Animation**
=====================================

**Overview**
-----------

Godot's particle system animation is a powerful tool for simulating complex physical effects and adding dynamic behavior to scenes. It consists of two main parts: particles and emitters, which can be used to create a wide range of effects, from simple sparks to complex fire and smoke simulations.

**Particle Nodes**
-----------------

There are two types of 3D particle systems in Godot:

*   **GPUParticles3D**: GPU-accelerated particles, processed on the GPU, which provide high performance and flexibility.
*   **CPUParticles3D**: CPU-accelerated particles, processed on the CPU, which provide better support for older devices and mobile phones, but are less flexible.

**Emitter Nodes**
----------------

Emitters are responsible for creating particles and can have a shape that controls where and how particles are spawned.

**Particle Attractor Nodes**
-----------------------------

There are three particle attractor nodes:

*   **GPUParticlesAttractorBox3D**: applies a force to all particles within a box and pulls them closer or pushes them away.
*   **GPUParticlesAttractorSphere3D**: applies a force to all particles within a sphere and pulls them closer or pushes them away.
*   **GPUParticlesAttractorVectorField3D**: applies a force to all particles in its reach and pulls them closer or pushes them away based on the direction of the force.

**Particle Collision Nodes**
-----------------------------

There are several particle collision nodes:

*   **GPUParticlesCollisionBox3D** and **GPUParticlesCollisionSphere3D**: simple collision nodes that create basic shapes like boxes and spheres.
*   **GPUParticlesCollisionSDF3D**: useful for indoor scenes, creates a heightmap of the world and objects, and uses it for large-scale particle collisions.
*   **GPUParticlesCollisionHeightField3D**: creates a heightmap of the world and objects, and uses it for large-scale particle collisions.

**Basic Usage**
---------------

To create a 3D particle system:

1.  Create a new node in the scene tree.
2.  Add a **GPUParticles3D** or **CPUParticles3D** node to the scene.
3.  Configure the particle properties, such as spawn rate, lifetime, size, speed, and color.
4.  Add an emitter node to the scene to create particles.
5.  Use attractor and collision nodes to control particle behavior and interactions.

**Advanced Topics**
------------------

*   **Particle sub-emitters**: create multiple smaller particle systems within a single system.
*   **3D particle trails**: create trails of particles behind a moving object.
*   **Particle turbulence**: create random variations in particle size, speed, and color.
*   **3D particle attractors**: apply forces to particles to create complex behavior.
*   **3D particle collisions**: create complex collision behavior between particles and objects.

**Example**
------------

```gdscript
extends GPUParticles3D

var speed = 10.0
var lifetime = 1.0

func _process(delta):
    for var i = 0; i < get_child(0).get_child_count(); i += 1:
        var particle = get_child(0).get_child(i)
        particle.velocity = Vector3(speed, 0, 0)
        particle.lifetime = lifetime
```

This code creates a particle system with a fixed speed and lifetime, and applies a force to each particle to move it along the x-axis.
