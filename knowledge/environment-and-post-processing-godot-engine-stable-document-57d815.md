# Environment and post-processing — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- **Fetched**: 2026-11-18T14:19:35

**Environment and Post-Processing in Godot Engine**
=====================================================

**Overview**
------------

Godot Engine 4 provides a redesigned Environment resource and a new post-processing system with many available effects. This section explains how to use the Environment resource and post-processing system in Godot Engine.

**Environment Resource**
-----------------------

The Environment resource stores information required for controlling the 2D and 3D rendering environment. It includes the sky, ambient lighting, tone mapping, effects, and adjustments.

**Using the Environment Resource**
--------------------------------

There are three ways to use the Environment resource:

1. **Camera3D node**: Set the Environment resource to a Camera3D node. This will have priority over any other setting.
2. **WorldEnvironment node**: Add a WorldEnvironment node to the scene. This has medium priority and can override the default Environment resource.
3. **Preview environment and sun**: The preview environment and sun system replaces the default_env.tres file in Godot 3 projects. It can be disabled using the buttons at the top of the 3D editor.

**Camera Attributes**
--------------------

In Godot Engine 4, exposure and depth of field information was split from the Environment resource into a separate CameraAttributes resource. This allows adjusting those properties independently of other Environment settings.

**CameraAttributes resources**
-----------------------------

There are two types of CameraAttributes resources:

1. **CameraAttributesPractical**: Features are exposed using arbitrary units, which are easier to reason about for most game use cases.
2. **CameraAttributesPhysical**: Features are exposed using real world units, similar to a digital camera. This is recommended when physical accuracy is important.

**Environment Options**
-----------------------

The Environment options include:

1. **Background**:
	* **Clear Color**: Uses the default clear color defined in the project settings.
	* **Custom Color**: Uses a custom color value.
	* **Sky**: Defines a background sky material.
	* **Canvas**: Displays the 2D scene as a background to the 3D scene.
	* **Keep**: Does not draw any sky, keeping what was present on previous frames.

**Tips and Best Practices**
---------------------------

* Use the WorldEnvironment node to override the default Environment resource on a per-scene basis.
* Use the CameraAttributesPractical resource unless physical accuracy is required.
* Use the CameraAttributesPhysical resource to override the Camera3D node's exposure and depth of field settings.
* Use the Environment resource to control the 2D and 3D rendering environment.

**API Documentation**
---------------------

For more information on the Environment resource and post-processing system, see the Godot Engine documentation.
