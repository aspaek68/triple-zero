# Godot 4 particle system tutorial

- **Source**: https://docs.godotengine.org/en/4.0/tutorials/3d/particles/creating_a_3d_particle_system.html
- **Fetched**: 2026-11-17T20:55:29

**Godot 4 Particle System Tutorial**
=====================================

**Overview**
------------

This tutorial guides you through creating a 3D particle system in Godot Engine 4.0. It covers the basics of particle systems, process materials, and draw passes.

**Required Node Properties**
----------------------------

* `GPUParticles3D` node
* `Process Material` set to a `ParticleProcessMaterial`
* At least one `Draw Pass` defined

**Process Material**
------------------

* To add a process material, go to `Process Material` in the inspector panel and select `New ParticleProcessMaterial`
* This material is used to update particle data and behavior on the GPU instead of the CPU
* Properties can be set to control each particle's behavior

**Draw Passes**
----------------

* At least one draw pass is required
* To define a draw pass, go to `Draw Passes` in the inspector panel and select `New QuadMesh`
* Set the mesh size to 0.1 for both x and y to make it easier to distinguish individual particle meshes
* Multiple draw passes can be used to render different meshes with unique materials
* Each pass uses the data computed by the process material

**Example: Using Multiple Draw Passes**
--------------------------------------

* Create a particle system with multiple draw passes
* Use the `Process Material` to control particle behavior
* Use the `Draw Passes` to render different meshes with unique materials

**Particle Conversion**
----------------------

* Convert GPU particles to CPU particles at any time using the entry in the viewport menu
* Note that not every feature of GPU particles is available for CPU particles
* Conversion may be necessary when releasing a game on older devices that don't support modern graphics APIs

**APIs and Functions**
----------------------

* `GPUParticles3D`
* `Process Material`
* `Draw Passes`
* `ParticleProcessMaterial`
* `QuadMesh`

**Code Example**
----------------

```gdscript
extends GPUParticles3D

func _ready():
    # Set up process material
    process_material = ParticleProcessMaterial.new()
    add_process_material(process_material)

    # Set up draw pass
    var quad_mesh = Mesh.new()
    quad_mesh.set_size(Vector2(0.1, 0.1))
    add_draw_pass(quad_mesh)
```

This code sets up a `GPUParticles3D` node with a `ParticleProcessMaterial` and a `QuadMesh` for the draw pass.
