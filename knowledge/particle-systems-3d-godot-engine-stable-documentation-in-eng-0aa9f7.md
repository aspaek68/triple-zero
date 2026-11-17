# Particle systems (3D) — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/particles/index.html
- **Fetched**: 2026-11-17T20:36:42

**Particle Systems (3D) in Godot Engine**
=============================================

**Introduction**
---------------

Particle systems are a powerful tool for simulating complex physical effects in Godot Engine, such as fire, sparks, smoke, and magical effects. They are well-suited for creating dynamic and organic behavior, adding "life" to your scenes.

**Particle System Components**
-----------------------------

A particle system consists of two main parts:

* **Particles**: The visible part of a particle system, representing tiny specks of dust, flames, or glowing orbs.
* **Emitters**: The node that creates the particles, controlling where and how they are spawned.

**Node Overview**
-----------------

Godot Engine offers two types of 3D particle systems:

* **GPUParticles3D**: GPU-accelerated particles processed on the GPU, offering high performance and flexibility.
* **CPUParticles3D**: CPU-based particles processed on the CPU, providing better support for older hardware and mobile phones.

**GPUParticles3D**
-----------------

* **Attractor Nodes**: Control the force applied to particles, pulling them closer or pushing them away.
	+ `GPUParticlesAttractorBox3D`
	+ `GPUParticlesAttractorSphere3D`
	+ `GPUParticlesAttractorVectorField3D`
* **Collision Nodes**: Define how particles interact with the environment.
	+ `GPUParticlesCollisionBox3D`
	+ `GPUParticlesCollisionSphere3D`
	+ `GPUParticlesCollisionSDF3D`
	+ `GPUParticlesCollisionHeightField3D`

**Basic Usage**
----------------

1. Create a 3D particle system and set its properties:
	* Spawn: Control the number of particles spawned.
	* Accelerations: Define the acceleration values for particles.
	* Display: Set the display options for particles.
	* Collision: Define how particles interact with the environment.
2. Customize the process material and particle flags to control particle behavior.

**Advanced Topics**
------------------

* **Particle Sub-Emitters**: Create smaller sub-particle systems within the main particle system.
* **Particle Trails**: Create trails behind moving particles.
* **Particle Turbulence**: Add random movement to particles.
* **3D Particle Attractors**: Control the force applied to particles using attractor nodes.
* **3D Particle Collisions**: Define how particles interact with the environment using collision nodes.
* **Complex Emission Shapes**: Create complex shapes to control particle emission.
