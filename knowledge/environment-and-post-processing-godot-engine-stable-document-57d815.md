# Environment and post-processing — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- **Fetched**: 2026-11-18T03:02:20

**Environment and Post-Processing in Godot Engine**
=====================================================

**Overview**
------------

Godot Engine 4 provides a redesigned Environment resource and a new post-processing system with many available effects right out of the box.

**Environment Resource**
------------------------

The Environment resource stores information required for controlling the 2D and 3D rendering environment, including sky, ambient lighting, tone mapping, effects, and adjustments.

**Configuring the Environment**
-------------------------------

The Environment can be set to a Camera3D node, WorldEnvironment node, or PreviewEnvironment node, each with a specific priority level.

*   Camera3D node: High priority, useful for overriding an existing environment.
*   WorldEnvironment node: Medium priority, recommended, as it can be overridden on a per-scene basis.
*   PreviewEnvironment node: Low priority, displays a preview environment and sun in the editor.

**Camera Attributes**
---------------------

In Godot 4, exposure and depth of field information is split from the Environment resource into a separate CameraAttributes resource.

*   CameraAttributesPractical: Features are exposed using arbitrary units, easier to reason about for most game use cases.
*   CameraAttributesPhysical: Features are exposed using real-world units, recommended for photorealistic rendering.

**Environment Options**
------------------------

The following is a detailed description of all environment options and how they are intended to be used.

*   Background:
    *   Clear Color: Uses the default clear color defined in the project settings.
    *   Custom Color: Like Clear Color, but with a custom color value.
    *   Sky: Lets you define a background sky material.
    *   Canvas: Displays the 2D scene as a background to the 3D scene.
    *   Keep: Does not draw any sky, keeping what was present on previous frames.

**Example Use Cases**
----------------------

*   Use the WorldEnvironment node to override the default Environment on a per-scene basis.
*   Use the CameraAttributes resource to adjust exposure and depth of field independently of other Environment settings.
*   Use the Background options to customize the appearance of your scene's background.

**API References**
------------------

*   `Environment`: The Environment resource.
*   `CameraAttributes`: The CameraAttributes resource.
*   `WorldEnvironment`: The WorldEnvironment node.
*   `PreviewEnvironment`: The PreviewEnvironment node.
