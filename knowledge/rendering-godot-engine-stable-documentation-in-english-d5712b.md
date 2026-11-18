# Rendering — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/rendering/index.html
- **Fetched**: 2026-11-18T14:23:25

Rendering
===============

Overview
--------

The Godot Engine's rendering system is responsible for rendering 2D and 3D graphics. This documentation provides an overview of the rendering process, including using viewports, multiple resolutions, and the Compositor.

Using Viewports
---------------

*   A viewport is a render target that can be used to render multiple resolutions.
*   Viewports can be used to create scalable graphics.
*   Viewports can be used to create animations and effects.

Multiple Resolutions
-------------------

*   Rendering multiple resolutions can be achieved using multiple viewports.
*   Viewports can be used to create scalable graphics.
*   Viewports can be used to create animations and effects.

Fixing Jitter, Stutter, and Input Lag
------------------------------------

*   Jitter, stutter, and input lag can be fixed by adjusting the following settings:
    *   VSync (Vertical Sync)
    *   Async (Async rendering)
    *   Motion Blur
    *   Depth Buffer

The Compositor
-------------

*   The Compositor is a rendering pipeline that handles rendering, lighting, and post-processing effects.
*   The Compositor can be used to create complex effects and animations.

Using DrawableTextures
---------------------

*   DrawableTextures can be used to create 2D graphics.
*   DrawableTextures can be used to create animations and effects.

HDR Output
------------

*   HDR (High Dynamic Range) output can be achieved by using the HDR format.
*   HDR output can be used to create realistic and detailed graphics.

APIs and Examples
-----------------

*   For more information on the rendering APIs, please refer to the [2D rendering](2d-rendering) and [3D rendering](3d-rendering) documentation.
*   Example use case:
    ```gdscript
var viewport = Viewport.new()
viewport.add_child(Node.new())
viewport.resize(800, 600)
viewport.update()
```
Languages and Versions
---------------------

*   This documentation is available in multiple languages, including:
    *   English
    *   Portuguese (pt-br)
    *   Czech (cs)
    *   French (fr)
    *   German (de)
    *   Italian (it)
    *   Japanese (ja)
    *   Korean (ko)
    *   Polish (pl)
    *   Russian (ru)
    *   Simplified Chinese (zh-cn)
    *   Spanish (es)
    *   Traditional Chinese (zh-tw)
    *   Ukrainian (uk)
*   This documentation covers the following versions:
    *   Latest
    *   Stable
    *   4.7
    *   4.6
    *   4.5
    *   4.4
    *   4.3
    *   4.2
    *   4.1
    *   4.0
    *   3.6
    *   3.5
    *   3.4
    *   3.3
    *   3.2
    *   3.1
    *   3.0
    *   2.1
