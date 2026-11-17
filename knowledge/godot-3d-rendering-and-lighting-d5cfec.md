# Godot 3D rendering and lighting

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/3d/lights_and_shadows.html
- **Fetched**: 2026-11-17T21:25:12

**Godot 3D Rendering and Lighting**
=====================================

**Introduction**
---------------

Light sources emit light that interacts with materials and produces a visible result. In Godot, there are several types of light sources, including:

*   Material-based light (emission color)
*   Light nodes (DirectionalLight3D, OmniLight3D, SpotLight3D)
*   Ambient light in the environment or via Reflection probes
*   Global illumination (LightmapGI, VoxelGI, or SDFGI)

**Light Nodes**
----------------

There are three types of light nodes:

*   **DirectionalLight3D**: A directional light source with parameters:
    *   Color
    *   Energy
    *   Indirect Energy
    *   Volumetric Fog Energy
    *   Negative
    *   Specular
    *   Bake Mode
    *   Cull Mask
*   **OmniLight3D**: A omnidirectional light source with parameters:
    *   Color
    *   Energy
    *   Indirect Energy
    *   Volumetric Fog Energy
    *   Negative
    *   Specular
    *   Bake Mode
    *   Cull Mask
*   **SpotLight3D**: A spot light source with parameters:
    *   Color
    *   Energy
    *   Indirect Energy
    *   Volumetric Fog Energy
    *   Negative
    *   Specular
    *   Bake Mode
    *   Cull Mask

**Light Number Limits**
------------------------

*   **Forward+ renderer**: A default limit of 512 clustered elements (omni light, spot light, decal, or reflection probe)
*   **Mobile renderer**: A limit of 8 OmniLights + 8 SpotLights per mesh resource
*   **Compatibility renderer**: A limit of 8 OmniLights + 8 SpotLights per mesh resource, which can be increased or decreased in advanced Project Settings

**Shadow Mapping**
-------------------

Light sources can optionally cast shadows, which can improve realism but incur a performance cost. The generic shadow parameters include:

*   **Enabled**: Check to enable shadow mapping
*   **Opacity**: Darken areas occluded by this opacity factor
*   **Bias**: Adjust to avoid self-shadowing or shadows separating from the casters
*   **Normal Bias**: Adjust to avoid self-shadowing or shadows appearing misaligned
*   **Transmittance Bias**: Adjust to avoid self-shadowing or shadows not affecting materials with transmittance enabled
*   **Reverse Cull Face**: Some scenes work better when shadow mapping is rendered with face-culling inverted
*   **Blur**: Multiplies the shadow blur radius for this light

**Tips and Tricks**

*   Use baked lightmaps with lights' bake mode set to Static to reduce lighting limits
*   Split your meshes into smaller portions to improve culling efficiency
*   Enable Distance Fade on light nodes to reduce the issue of lights popping in and out during camera movement
