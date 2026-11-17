# Godot 4 particle animation

- **Source**: https://www.youtube.com/watch?v=b7fbQ28_8w8
- **Fetched**: 2026-11-17T21:01:41

## Godot 4 Particle Animation

### Overview

Godot 4 provides a robust particle animation system, allowing for the creation of complex and visually appealing effects. This note provides an overview of the key concepts, APIs, and examples for creating animated 2D particle cloud effects in Godot 4.

### Key Concepts

* **Particles**: Represent individual elements of the animation, such as sparks, smoke, or snow.
* **Particle Emitter**: A node that controls the spawning, growth, and lifetime of particles.
* **Particle**: A 2D node that represents an individual particle, with properties such as position, velocity, and color.

### APIs

* `KinematicBody2D` (formerly `RigidBody2D`): Used to control particle movement and interaction with the environment.
* `Node2D`: Used as the root node for particle emitters and individual particles.
* `KinematicBody2D` (with `Physics2D` enabled): Used to enable physics simulations for particles.

### Example Use Case

To create a simple particle cloud effect:

1. Create a new `Node2D` scene in Godot 4.
2. Add a `KinematicBody2D` node as a child of the `Node2D`.
3. Create a `ParticleEmitter` node as a child of the `KinematicBody2D`.
4. Configure the `ParticleEmitter` to spawn particles at regular intervals, with a specified velocity and lifetime.
5. Use the `KinematicBody2D` node to control the movement of the particle cloud.

### Additional Tips

* Use the `Physics2D` simulation to enable realistic interactions between particles and the environment.
* Experiment with different particle shapes, colors, and sizes to create unique effects.
* Use Godot's built-in animation tools to create complex particle animations.

### References

* Godot 4 Documentation: [Particle Emitter](https://docs.godotengine.org/en/stable/extends/particle_emitter.html)
* Godot 4 Documentation: [KinematicBody2D](https://docs.godotengine.org/en/stable/extends/kinemathbody2d.html)
