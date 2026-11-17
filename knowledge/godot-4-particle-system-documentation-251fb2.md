# Godot 4 particle system documentation

- **Source**: https://docs.godotengine.org/en/4.0/tutorials/3d/particles/creating_a_3d_particle_system.html
- **Fetched**: 2026-11-17T20:50:27

# Godot 4 Particle System Documentation
=====================================

## Creating a 3D Particle System

To create a 3D particle system, follow these steps:

### Required Particle Node Properties

1. Add a `GPUParticles3D` node to the scene.
2. Set up the following parameters:
	* `Process Material`: adds a new `ParticleProcessMaterial` node.
	* `Draw Passes`: sets up at least one draw pass.

### Process Material

1. To add a process material, go to the `Process Material` section in the inspector panel.
2. Click on the box next to `Process Material` and select `New ParticleProcessMaterial`.
3. A long list of properties is displayed to control each particle's behavior.

### Draw Passes

1. To set up a draw pass, go to the `Draw Passes` section in the inspector panel.
2. Click on the box next to `Pass 1` and select `New QuadMesh`.
3. Set the mesh's `Size` to 0.1 for both `x` and `y` to make it easier to see individual particle meshes.

### Using Multiple Draw Passes

1. Up to 4 draw passes can be used per particle system.
2. Each pass can render a different mesh with its own unique material.
3. All draw passes use the data computed by the process material, which is an efficient method for composing complex effects.

### Example

```gdscript
// Create a new particle process material
var process_material = ParticleProcessMaterial.new()
process_material.set_custom_resource(ParticleProcessMaterial.RESOURCE_TURBULENCE, 1.0)

// Create a new quad mesh for the draw pass
var quad_mesh = QuadMesh.new()
quad_mesh.set_size(Vector2(0.1, 0.1))

// Add the quad mesh to the draw pass
var draw_pass = DrawPass.new()
draw_pass.set_mesh(quad_mesh)
```

### Converting GPU Particles to CPU Particles

1. To convert GPU particles to CPU particles, use the entry in the viewport menu.
2. Note that some features may be lost during conversion, such as multiple draw passes, turbulence, and collision.

### API Documentation

* `GPUParticles3D`: a node that controls 3D particle behavior.
* `ParticleProcessMaterial`: a special kind of material used to update particle data and behavior on the GPU.
* `DrawPass`: a node that defines a render pass for the particle system.
* `QuadMesh`: a mesh used to render particles.

### Example Use Cases

* Creating a particle system with multiple draw passes to simulate complex effects.
* Using GPU particles to improve performance in games and simulations.
* Converting GPU particles to CPU particles for older devices that don't support modern graphics APIs.
