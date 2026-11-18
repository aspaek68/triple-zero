# Godot 4 VFX particle system

- **Source**: https://godotlab.org/en/tutorials/3d-particle-systems
- **Fetched**: 2026-11-18T05:49:14

**Godot 4 3D Particle System Architecture**
=============================================

**Overview**
------------

Godot 4 introduces a modern GPU-accelerated particle system architecture, designed to simulate dynamic life and atmospheric realism in virtual worlds. The 3D particle system is structured around emitters and particles, with two specialized node implementations: GPUParticles3D and CPUParticles3D.

**GPUParticles3D**
-----------------

*   **Overview**: A modern particle node processed directly on graphics hardware compute pipelines.
*   **Features**:
    *   Supports custom particle shaders
    *   Vector field attractors
    *   Real-time signed distance field collisions
    *   Ribbon trails
*   **Desktop Platforms**: Premier choice for modern consoles and Vulkan-compatible mobile devices.

**CPUParticles3D**
-----------------

*   **Overview**: A fallback particle node processed sequentially on the host processor.
*   **Features**:
    *   Universal compatibility with older graphics backends
    *   Rock-solid stability on legacy hardware

**Spatial Attractors and Collision Nodes**
-----------------------------------------

The particle system incorporates dedicated attractor and collision nodes to produce convincing physical interactions between particles and the environment.

*   **Attractors**:
    *   GPUParticlesAttractorBox3D
    *   GPUParticlesAttractorSphere3D
    *   GPUParticlesAttractorVectorField3D
*   **Collision Nodes**:
    *   GPUParticlesCollisionBox3D
    *   GPUParticlesCollisionSphere3D
    *   GPUParticlesCollisionSDF3D
    *   GPUParticlesCollisionHeightField3D

**Process Materials and Multi-Pass Draw Pipelines**
-------------------------------------------------

To configure a functional GPUParticles3D node, two mandatory properties must be assigned:

*   **Process Material**: A specialized computational material governing physics simulation.
*   **Draw Pass**: A definition of visual geometry.

**Example GDScript Implementation**
-----------------------------------

```gdscript
extends GPUParticles3D

var emitter = Emits.at(0, 0, 0)
var attractor = GPUParticlesAttractorBox3D.new()
var material = ParticleProcessMaterial.new()

material.add_shader("CustomShader")
material.add_shader("StandardMaterial")
material.set_physics_simulation(true)

add_child(emitter)
add_child(attractor)
add_child(material)
```

**Key Facts and APIs**
-----------------------

*   `GPUParticles3D`: A modern particle node processed directly on graphics hardware compute pipelines.
*   `CPUParticles3D`: A fallback particle node processed sequentially on the host processor.
*   `ParticleProcessMaterial`: A specialized computational material governing physics simulation.
*   `GPUParticlesAttractorBox3D`, `GPUParticlesAttractorSphere3D`, `GPUParticlesAttractorVectorField3D`: Attractors for simulating physical interactions.
*   `GPUParticlesCollisionBox3D`, `GPUParticlesCollisionSphere3D`, `GPUParticlesCollisionSDF3D`, `GPUParticlesCollisionHeightField3D`: Collision nodes for simulating particle collisions.
