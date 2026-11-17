# godot 4 particle system

- **Source**: https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
- **Fetched**: 2026-11-17T20:41:03

# Godot 4 Particle System
=====================================

## Introduction

Particle systems are used to simulate complex physical effects, such as sparks, fire, magic particles, smoke, mist, etc. A particle system is created by setting base physics parameters and adding randomness to them.

## Particle Nodes

Godot provides two different nodes for 2D particles:

*   **GPUParticles2D**: More advanced and uses the GPU to process particle effects. Recommended for most use cases.
*   **CPUParticles2D**: CPU-driven option with near-feature parity with GPUParticles2D, but lower performance when using large amounts of particles. Not recommended for new projects.

## Particle Process Material

To use a particle system, you need to add a **ParticleProcessMaterial** to your particles node. This material is configured via the **Process** material in the inspector panel.

## Texture

A particle system can use a single texture or an animation flipbook.

*   **Single Texture**: Set via the **Texture** property.
*   **Animation Flipbook**: Requires additional configuration and can be used to introduce random texture variation.

## Time Parameters

The following time parameters can be adjusted:

*   **Lifetime**: The time in seconds that every particle will stay alive.
*   **One Shot**: Enables the node to emit all of its particles once and then never again.
*   **Preprocess**: Processes a given number of seconds before it is actually drawn.
*   **Speed Scale**: Adjusts the speed of a particle system.
*   **Explosiveness**: Forces particles to be emitted all together, useful for creating explosions or sudden bursts of particles.

## Randomness

All particles have the same base behavior, but the randomness associated with each parameter provides a more organic look.

### Example Use Case

```gd
var particles = GPUParticles2D.new()
particles.set_texture(Yellow.png)
particles.set_lifetime(2.0)
particles.set_explosiveness(1.5)
particles.set_randomness(0.5)
add_child(particles)
```

This code creates a new **GPUParticles2D** node, sets its texture, lifetime, explosiveness, and randomness, and adds it to the scene.
