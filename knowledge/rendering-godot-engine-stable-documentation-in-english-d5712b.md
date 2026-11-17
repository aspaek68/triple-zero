# Rendering — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/rendering/index.html
- **Fetched**: 2026-11-17T20:45:30

# Rendering in Godot Engine
=====================================

Rendering in Godot Engine refers to the process of preparing graphical content for display on the screen. The engine provides various tools and features to manage rendering, including renderers, viewports, and the Compositor.

## Overview of Renderers
------------------------

Renderers are responsible for managing the rendering pipeline in Godot Engine. They are used to render 2D and 3D graphics, and can be configured to handle various aspects of rendering, such as resolution scaling and input lag.

### Using Viewports
------------------

Viewports are a type of renderer that allows you to render graphical content to a specific area of the screen. You can use viewports to create custom user interfaces, or to render 2D graphics.

### Multiple Resolutions
-----------------------

Godot Engine allows you to render at multiple resolutions simultaneously. This can be useful for creating high-performance graphics that can handle multiple screen resolutions.

### Fixing Jitter, Stutter, and Input Lag
-----------------------------------------

Jitter, stutter, and input lag are common issues that can affect the performance of your game. Godot Engine provides various tools and techniques to help you fix these issues, including:

*   **VSync**: Enables vertical sync to prevent screen tearing.
*   **Frame rate limiting**: Limits the frame rate to prevent overloading the GPU.
*   **Input lag compensation**: Compensates for input lag to improve responsiveness.

### The Compositor
------------------

The Compositor is a rendering pipeline component that manages the rendering process. It is responsible for handling tasks such as:

*   **Texture rendering**: Renders textures to the screen.
*   **Sprite rendering**: Renders sprites to the screen.
*   **Scalable rendering**: Scales graphics to fit the screen resolution.

### Using DrawableTextures
---------------------------

DrawableTextures are a type of texture that can be used to render graphical content. They provide a number of benefits, including:

*   **Improved performance**: DrawableTextures can improve performance by reducing the number of draw calls.
*   **Customization**: DrawableTextures can be customized to fit specific use cases.

### HDR Output
--------------

HDR (High Dynamic Range) output allows you to render graphics with a wider range of colors and contrast levels. This can improve the overall visual quality of your game.

### API References
------------------

*   `Viewport`
*   `Renderer`
*   `Compositor`
*   `DrawableTexture`
*   `VSync`
*   `Frame rate limiting`
*   `Input lag compensation`
