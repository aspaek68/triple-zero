# Godot particle editor guide

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-18T17:02:26

**Godot Particle Editor Guide**
================================

**Introduction**
---------------

Godot's particle editor allows you to create dynamic and organic behavior in your scenes by simulating complex physical effects. This guide covers the basics of 3D GPU-accelerated particle systems and provides an overview of the key concepts, APIs, and examples.

**Particle System Overview**
---------------------------

A particle system consists of two main parts:

*   **Particles**: The visible part of the particle system, which can have anywhere from hundreds to tens of thousands of particles.
*   **Emitters**: The source of the particles, which can be a shape controlling where and how particles are spawned.

**Node Overview**
-----------------

Godot offers three types of 3D particle systems:

*   **GPUParticles3D**: Processed on the GPU, these particle systems are more flexible and performant, but require modern hardware.
*   **CPUParticles3D**: Processed on the CPU, these particle systems are less flexible but provide better support for older devices and mobile phones.

**Particle Attractors**
----------------------

There are three particle attractor nodes:

*   **GPUParticlesAttractorBox3D**: Applies a force to all particles in its reach and pulls them closer or pushes them away based on the direction of that force.
*   **GPUParticlesAttractorSphere3D**: Similar to the box attractor, but applies the force based on the direction from the sphere's center.
*   **GPUParticlesAttractorVectorField3D**: Applies a force to all particles in its reach and pulls them closer or pushes them away based on the direction of that force, similar to the box attractor.

**Particle Collisions**
----------------------

There are several particle collision nodes:

*   **GPUParticlesCollisionBox3D**: Simple collision with a box-shaped collider.
*   **GPUParticlesCollisionSphere3D**: Simple collision with a sphere-shaped collider.
*   **GPUParticlesCollisionSDF3D**: Collision with a signed distance field (SDF) shape.
*   **GPUParticlesCollisionHeightField3D**: Collision with a heightmap of a world and its objects.

**Basic Usage**
----------------

Creating a 3D particle system involves the following steps:

*   **Process material properties**: Define the material properties for the particles.
*   **Particle flags**: Set the particle flags, such as spawn, acceleration, and display.
*   **Spawn**: Set the spawn options, such as the number of particles and their initial position and velocity.
*   **Accelerations**: Set the accelerations for the particles.
*   **Display**: Set the display options, such as the particle size and color.
*   **Collision**: Set the collision options, such as the collision shape and flags.
*   **Sub-emitter**: Set the sub-emitter options, such as the number of sub-emitters and their initial position and velocity.

**Advanced Topics**
-------------------

Some advanced topics include:

*   **Particle sub-emitters**: Create sub-emitters for more complex emission shapes.
*   **3D Particle trails**: Create trails for particles.
*   **Particle turbulence**: Add turbulence to particles.
*   **3D Particle attractors**: Use attractors to create more complex behavior.
*   **3D Particle collisions**: Use collisions to create more complex behavior.

**Example Use Case**
--------------------

Create a fire effect using a particle system:

*   Set the particle system to use GPUParticles3D.
*   Define the material properties for the particles, including color and size.
*   Set the spawn options, such as the number of particles and their initial position and velocity.
*   Set the accelerations for the particles.
*   Set the display options, such as the particle size and color.
*   Set the collision options, such as the collision shape and flags.
*   Use a particle attractor to create a flame effect.
*   Use a particle collision to create a burning effect.

```gdscript
extends Particle3D

extends KinematicBody3D

func _process(delta):
    # Set the material properties
    self.material = load("res://fire_material.gd")

    # Set the spawn options
    self.spawn_mode = SpawnMode.MIDDLE
    self.spawn_count = 100
    self.spawn_rate = 0.1

    # Set the accelerations
    self.acceleration = Vector3(0, 1, 0)

    # Set the display options
    self.scale = Vector3(0.1, 0.1, 0.1)
    self.color = Color(1, 0, 0)

    # Set the collision options
    self.shape = CollisionShape3D.new()
    self.shape.shape = CollisionShape3D.MESH
    self.shape.mesh = load("res://fire_mesh.gd")

    # Use a particle attractor
    var attractor = GPUParticlesAttractorBox3D.new()
    attractor.shape = CollisionShape3D.new()
    attractor.shape.shape = CollisionShape3D.MESH
    attractor.shape.mesh = load("res://flame_mesh.gd")
    self.add_child(attractor)

    # Use a particle collision
    var collision = GPUParticlesCollisionBox3D.new()
    self.add_child(collision)
```

This guide provides a comprehensive overview of Godot's particle editor and its features. By following this guide, you can create complex and realistic particle effects for your scenes.
