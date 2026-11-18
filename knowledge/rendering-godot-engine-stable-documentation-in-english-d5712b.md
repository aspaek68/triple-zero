# Rendering — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/rendering/index.html
- **Fetched**: 2026-11-18T03:06:50

Rendering
================

Overview
--------

Godot Engine provides a robust rendering system to handle various graphical needs. This section covers the basics of rendering, including renderers, viewports, and the Compositor.

### Viewports

A viewport is a region of the screen where the game's content is rendered. Godot provides two types of viewports:

*   **SceneViewport**: renders the scene's nodes.
*   **SpriteViewport**: renders sprites.

Example:
```gdscript
extends Viewport

func _process(delta):
    # Example code to render a custom texture
    var texture = load("res://texture.tres")
    set_texture(texture)
```

### Multiple Resolutions

Godot allows for multiple resolutions to be handled efficiently. This can be achieved through the use of:

*   **Viewport Resolution**: sets the resolution for a specific viewport.
*   **Screen Resolution**: sets the resolution for the entire screen.

Example:
```gdscript
extends Viewport

func _process(delta):
    # Example code to set the viewport resolution
    set_viewport_size(1920, 1080)
```

### Fixing Jitter, Stutter, and Input Lag

Jitter, stutter, and input lag can be mitigated using the following techniques:

*   **Async Queue**: allows for asynchronous processing, reducing lag.
*   **Async Texture Loading**: loads textures asynchronously, reducing stuttering.
*   **Input Lag Compensation**: compensates for input lag by adjusting rendering times.

Example:
```gdscript
extends Node2D

func _process(delta):
    # Example code to use an async queue
    async_queue.begin_async_task(func_name, "texture_load")
```

### The Compositor

The Compositor is a central component in Godot's rendering pipeline. It handles tasks such as:

*   **HDR Output**: supports High Dynamic Range (HDR) rendering.
*   **Color Space**: handles color spaces and conversions.

Example:
```gdscript
extends Node2D

func _process(delta):
    # Example code to use the compositor
    var compositor = get_compositor()
    compositor.update HDR rendering
```

See also
--------

For more information on 2D and 3D rendering, refer to:

*   [2D Rendering](https://docs.godotengine.org/en/stable/extends/viewport.html)
*   [3D Rendering](https://docs.godotengine.org/en/stable/extends/3d_node.html)
