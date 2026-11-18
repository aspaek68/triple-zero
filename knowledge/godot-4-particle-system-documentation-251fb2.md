# Godot 4 particle system documentation

- **Source**: https://docs.godotengine.org/en/4.0/tutorials/3d/particles/creating_a_3d_particle_system.html
- **Fetched**: 2026-11-18T05:47:45

**Godot 4 Particle System Documentation**
======================================

**Creating a 3D Particle System**
--------------------------------

To create a 3D particle system in Godot 4.0, follow these steps:

### Required Particle Node Properties

1. Add a `GPUParticles3D` node to the scene.
2. Set up two parameters on the node:
	* `Process Material`
	* At least one `Draw Pass`

### Process Material

1. Go to the `Process Material` property in the inspector panel.
2. Click on the box next to `Process Material` and select `New ParticleProcessMaterial`.
3. This material is used to update particle data and behavior on the GPU, which comes with a massive performance boost.

### Draw Passes

1. Go to the `Draw Passes` property in the inspector panel.
2. Click on the box next to `Pass 1` and select `New QuadMesh`.
3. Set the mesh's `Size` to 0.1 for both `x` and `y` to make it easier to distinguish individual particle meshes.
4. You can use up to 4 draw passes per particle system, each rendering a different mesh with its own unique material.

### Using Multiple Draw Passes

* Example: Using yellow rectangles (pass1) and blue spheres (pass2)
* Each pass uses the data computed by the process material, an efficient method for composing complex effects.

### Particle Conversion

* You can convert GPU particles to CPU particles at any time using the entry in the viewport menu.
* Note that not every feature of GPU particles is available for CPU particles, so the resulting particle system will look and behave differently from the original.

**API and Properties**

* `Process Material`: a special kind of material used to update particle data and behavior on the GPU.
* `Draw Passes`: a property that allows you to define multiple draw passes for rendering particles.
* `QuadMesh`: a mesh used for drawing particles in each pass.
* `ParticleProcessMaterial`: a material used to update particle data and behavior on the GPU.

**Examples**

* Creating a particle system with multiple draw passes: yellow rectangles (pass1) and blue spheres (pass2)
* Using the `Process Material` to update particle data and behavior on the GPU.

**Notes**

* The particle system's performance will be improved when using the `Process Material` and multiple draw passes.
* Converting GPU particles to CPU particles can become necessary when releasing a game on older devices that don't support modern graphics APIs.
