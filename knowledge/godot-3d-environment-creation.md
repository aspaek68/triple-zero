# Godot 3D environment creation

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- **Fetched**: 2026-11-17T21:25:50

**Godot 3D Environment Creation**
================================

**Environment Resource**
-----------------------

The Environment resource stores information for controlling the 2D and 3D rendering environment, including sky, ambient lighting, tone mapping, effects, and adjustments.

**Priority Locations**
--------------------

An Environment can be set to a:

1. **Camera3D node** (high priority): Useful for overriding an existing environment, but not recommended.
2. **WorldEnvironment node** (medium priority, recommended): Adds Environment to the scene, overriding default settings, and can be overridden on a per-scene basis.
3. **Preview environment and sun** (low priority): Displays in the editor, not in the running project.

**Post-Processing System**
-------------------------

Godot 4 provides a redesigned post-processing system with many available effects right out of the box.

**Camera Attributes**
------------------

The CameraAttributes resource stores exposure and depth of field information, allowing independent adjustments of Environment settings.

* **CameraAttributesPractical**: Features are exposed using arbitrary units, suitable for most game use cases.
* **CameraAttributesPhysical**: Features are exposed using real-world units, recommended for photorealistic rendering.

**Environment Options**
----------------------

The Background section contains settings for filling the background, which affects ambient and reflected light. Available options:

* **Clear Color**: Uses the default clear color defined in the project settings.
* **Custom Color**: Uses a custom color value.
* **Sky**: Defines a background sky material.
* **Canvas**: Displays the 2D scene as a background to the 3D scene.
* **Keep**: Does not draw any sky, keeping what was present on previous frames.

**Example Use Case**
--------------------

To create a new Environment resource:

1. Create a new Environment resource in the Scene Tree.
2. Set the Environment resource to a Camera3D node or WorldEnvironment node, depending on your needs.
3. Adjust the Environment settings to suit your project.

**Tips and Best Practices**
---------------------------

* Use the WorldEnvironment node to override Environment settings on a per-scene basis.
* Use the CameraAttributesPractical resource type for most game use cases.
* Use the CameraAttributesPhysical resource type for photorealistic rendering.
* Use the preview environment and sun system to customize the appearance of the preview environment and sun in the editor.
