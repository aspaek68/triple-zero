# Particle system Godot 4 examples

- **Source**: https://godotlab.org/en/tutorials/3d-particle-systems
- **Fetched**: 2026-11-18T18:19:42

**Godot 4 3D Particle Systems Guide**
=====================================

**Introduction**
---------------

Particle systems are a crucial element in 3D game development, adding dynamic life and atmospheric realism to virtual worlds. Godot 4 introduces a modern GPU-accelerated particle system architecture, making it easier to create realistic and immersive effects. This guide explores the architectural foundation of Godot 4 3D particles, covering node distinctions, process materials, multi-pass draw pipelines, temporal dynamics, attractors, collisions, drawing order, and dual-backend conversion boundaries.

**Core Features**
----------------

### Node Taxonomy

A 3D particle system in Godot is structured around two fundamental pillars:

*   **Emitter**: determines where micro-elements spawn in space, their initial ejection velocities, and their geometric emission volume.
*   **Particles**: represent the visible elements that appear on screen, such as flickering embers, rotating smoke quads, or glowing mesh debris.

### Particle Node Implementations

Godot provides two specialized node implementations tailored to distinct target hardware profiles:

*   **GPUParticles3D**: a modern particle node processed directly on graphics hardware compute pipelines. It supports custom particle shaders, vector field attractors, real-time signed distance field collisions, and ribbon trails.
*   **CPUParticles3D**: a fallback particle node processed sequentially on the host processor. It's compatible with older graphics backends and delivers rock-solid stability on legacy hardware.

### Spatial Attractors and Collision Nodes

To produce convincing physical interactions between particles and the environment, Godot 4 incorporates dedicated attractor and collision nodes:

*   **Attractors**:
    *   **GPUParticlesAttractorBox3D**: exerts directional pulling or pushing forces within its volume.
    *   **GPUParticlesAttractorSphere3D**: radiates radial attraction or repulsion from its center.
    *   **GPUParticlesAttractorVectorField3D**: samples volumetric vector field textures to produce organic turbulent swirls and complex aerodynamic currents.
*   **Collision Nodes**:
    *   **GPUParticlesCollisionBox3D**: provides rapid planar barrier detection for floors, walls, and structural crates.
    *   **GPUParticlesCollisionSphere3D**: offers efficient radial bounce surfaces for boulders, spherical obstacles, and force bubbles.
    *   **GPUParticlesCollisionSDF3D**: captures indoor level geometry into baked voxel distance fields, allowing particles to bounce realistically off ornate staircases and intricate architecture without manual collider placement.
    *   **GPUParticlesCollisionHeightField3D**: generates dynamic heightmaps of landscape geometry to manage world-scale precipitation and foliage collisions.

### Process Materials and Multi-Pass Draw Pipelines

To configure a functional GPUParticles3D node, two mandatory properties must be assigned:

*   **Process Material**: governs physics simulation.
*   **Draw Pass**: defines visual geometry.

**Example Code**
---------------

Here's an example of how to create a GPUParticles3D node in GDScript:
```gdscript
extends Node

func _ready():
    var particles = GPUParticles3D.new()
    particles.connect("process_material", self, "_process_material")
    particles.connect("draw", self, "_draw")
    add_child(particles)
```
This code creates a new GPUParticles3D node and connects its `process_material` and `draw` signals to the `_process_material` and `_draw` functions, respectively.

**Conclusion**
----------

Godot 4's 3D particle system architecture provides a powerful tool for creating realistic and immersive effects in 3D game development. By understanding the node taxonomy, process materials, multi-pass draw pipelines, temporal dynamics, attractors, collisions, drawing order, and dual-backend conversion boundaries, you can unlock the full potential of this feature and take your game development projects to the next level.
