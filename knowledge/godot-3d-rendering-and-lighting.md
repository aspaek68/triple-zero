# Godot 3D rendering and lighting

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html
- **Fetched**: 2026-11-17T21:24:29

**Godot 3D Rendering and Lighting**
=====================================

**Introduction**
---------------

Godot's 3D rendering and lighting engine allows for realistic lighting and shading effects in scenes. This document provides an overview of Godot's lighting capabilities, including light sources, global illumination, and shadow mapping.

**Light Sources**
----------------

Godot supports several types of light sources:

*   **DirectionalLight3D**: A directional light source that emits light from a single direction.
*   **OmniLight3D**: A directional light source that emits light in all directions.
*   **SpotLight3D**: A directional light source that emits light from a specific direction, with a conical shadow.
*   **Reflection Probes**: Ambient light sources that capture and diffuse light from the environment.

**Light Properties**
-------------------

Each light source has several properties that can be adjusted:

*   **Color**: The base color of the emitted light.
*   **Energy**: The energy multiplier for the light.
*   **Indirect Energy**: The secondary multiplier for indirect light.
*   **Volumetric Fog Energy**: The secondary multiplier for volumetric fog.
*   **Negative**: Makes the light subtractive instead of additive.
*   **Specular**: Affects the intensity of the specular blob in objects affected by the light.
*   **Bake Mode**: Sets the bake mode for the light.

**Global Illumination**
----------------------

Godot supports several global illumination techniques:

*   **LightmapGI**: Baked lightmaps that can be used to speed up rendering.
*   **VoxelGI**: Voxel-based global illumination.
*   **SDFGI**: Signed distance field-based global illumination.

**Shadow Mapping**
-----------------

Light sources can optionally cast shadows. The shadow mapping parameters are:

*   **Enabled**: Enables or disables shadow mapping.
*   **Opacity**: Darkens occluded areas by this opacity factor.
*   **Bias**: Adjusts the shadow mapping bias.
*   **Normal Bias**: Adjusts the normal bias.
*   **Transmittance Bias**: Adjusts the transmittance bias.
*   **Reverse Cull Face**: Inverts the face culling.
*   **Blur**: Multiplies the shadow blur radius.

**Limitations and Optimization**
---------------------------------

Godot has several limitations and optimization techniques to improve performance:

*   **Max Clustered Elements**: The maximum number of clustered elements that can be present in the current camera view.
*   **Max Renderable Elements**: The maximum number of renderable elements that can be rendered per mesh resource.
*   **Distance Fade**: Enables distance fade to reduce the effect of light popping in and out during camera movement.
*   **Baked Lightmaps**: Baked lightmaps can be used to speed up rendering and reduce the number of light sources.

**Example Use Case**
--------------------

To demonstrate Godot's lighting capabilities, you can use the 3D Lights and Shadows demo project. This project showcases various lighting techniques, including directional lighting, omnilighting, and shadow mapping.

```gdscript
# Create a directional light source
var directional_light = DirectionalLight3D.new()
directional_light.position = Vector3(0, 0, 5)
directional_light.color = Color(1, 1, 1)
directional_light.energy = 10.0

# Create an omnilight source
var omnilight_source = OmniLight3D.new()
omnilight_source.color = Color(0, 1, 0)
omnilight_source.energy = 5.0

# Add the light sources to the scene
add_child(directional_light)
add_child(omnilight_source)
```

This code creates a directional light source and an omnilight source and adds them to the scene. The `directional_light` has a color of white and an energy of 10, while the `omnilight_source` has a color of green and an energy of 5.
