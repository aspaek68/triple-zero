# Environment and post-processing — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- **Fetched**: 2026-11-17T20:37:53

**Environment and Post-Processing in Godot Engine**
======================================================

**Overview**
------------

Godot Engine 4 provides a redesigned Environment resource and a new post-processing system with many available effects. This documentation will guide you through setting up and configuring the environment and post-processing in Godot.

**Environment**
---------------

The Environment resource stores information required for controlling the rendering environment. It includes the sky, ambient lighting, tone mapping, effects, and adjustments.

**Usage**
---------

1. **Camera3D Node**: Set the Environment to a Camera3D node to override any other setting.
2. **WorldEnvironment Node**: Add a WorldEnvironment node to any scene. This has higher priority than the default Environment and can be overridden on a per-scene basis.
3. **Preview Environment and Sun**: The preview environment and sun system replaces the default_env.tres file. It can be disabled by clicking on the three vertical dots at the top of the 3D editor.

**Camera Attributes**
--------------------

The CameraAttributes resource stores exposure and depth of field information. There are two types:

1. **CameraAttributesPractical**: Exposes features in arbitrary units, suitable for most game use cases.
2. **CameraAttributesPhysical**: Exposes features in real-world units, recommended for photorealistic rendering.

**Camera Attributes Usage**
---------------------------

1. Add a CameraAttributesPractical or CameraAttributesPhysical resource to a Camera3D or WorldEnvironment node.
2. The CameraAttributesPractical resource is recommended, as it prevents depth of field from displaying in the 3D editor viewport.

**Environment Options**
----------------------

1. **Background**: Settings for filling the background, affecting ambient and reflected light.
	* Clear Color: Uses the default clear color defined in the project settings.
	* Custom Color: A custom color value.
	* Sky: Defines a background sky material.
	* Canvas: Displays the 2D scene as a background to the 3D scene.
	* Keep: Does not draw any sky, keeping what was present on previous frames.

**Example Use Cases**
---------------------

* Use the Environment resource to override an existing environment with a Camera3D node.
* Add a WorldEnvironment node to a scene to override the default Environment on a per-scene basis.
* Use the CameraAttributesPractical resource to expose features in arbitrary units.
* Use the CameraAttributesPhysical resource for photorealistic rendering.
