# Godot 4 particle system tutorial

- **Source**: https://docs.godotengine.org/en/4.0/tutorials/3d/particles/creating_a_3d_particle_system.html
- **Fetched**: 2026-11-18T18:17:23

# Godot 4 Particle System Tutorial
=====================================

## Overview

This tutorial covers the basics of creating a 3D particle system in Godot 4.0. It provides a step-by-step guide on setting up a particle system, including the process material and draw passes.

## Required Particle Node Properties

To get started, add a `GPUParticles3D` node to the scene and set up the following properties:

*   `Process Material`
*   `Draw Passes` (at least one)

## Process Material

*   To add a process material, go to `Process Material` in the inspector panel and click on the box next to it.
*   Select `New ParticleProcessMaterial` from the dropdown menu.
*   This material is used to update particle data and behavior on the GPU, providing a massive performance boost.

## Draw Passes

*   At least one draw pass is required to render particles.
*   To create a draw pass, go to `Draw Passes` in the inspector panel and click on the box next to `Pass 1`.
*   Select `New QuadMesh` from the dropdown menu.
*   Set the mesh's `Size` to 0.1 for both `x` and `y` to make it easier to tell individual particle meshes apart.

## Using Multiple Draw Passes

*   Each draw pass can render a different mesh with its own unique material.
*   Up to 4 draw passes can be used per particle system.
*   Each pass uses the data computed by the process material, making it an efficient method for composing complex effects.

### Example: Using Multiple Draw Passes

```markdown
# Using multiple draw passes

## Step 1: Create a new draw pass

*   Go to `Draw Passes` in the inspector panel and click on the box next to `Pass 2`.
*   Select `New QuadMesh` from the dropdown menu.
*   Set the mesh's `Size` to 0.1 for both `x` and `y`.

## Step 2: Assign a material to the new draw pass

*   Right-click on the new draw pass and select `Assign Material`.
*   Select a material for the new draw pass, such as a yellow rectangle material.

## Step 3: Render the particle system with multiple draw passes

*   Go to `Draw Passes` in the inspector panel and click on the box next to `Pass 1`.
*   Select the original quadmesh.
*   Go to `Process Material` in the inspector panel and select the process material.
*   Press the play button to render the particle system with multiple draw passes.
```

## Particle Conversion

*   You can convert GPU particles to CPU particles at any time using the entry in the viewport menu.
*   Note that some features of GPU particles may not be available for CPU particles, affecting the resulting particle system.

### Example: Converting GPU Particles to CPU Particles

```markdown
# Converting GPU particles to CPU particles

## Step 1: Convert the particle system

*   Go to the viewport menu and select `Convert to CPU`.
*   Confirm that you want to convert the particle system to CPU.

## Step 2: Update the particle system

*   Go to `Draw Passes` in the inspector panel and click on the box next to `Pass 1`.
*   Select the original quadmesh.
*   Go to `Process Material` in the inspector panel and select the process material.
*   Press the play button to render the particle system.

## Note

*   Some features of GPU particles, such as turbulence, sub-emitters, trails, and attractors, may not be available for CPU particles.
*   Converting to CPU particles may be necessary when releasing a game on older devices that don't support modern graphics APIs.
