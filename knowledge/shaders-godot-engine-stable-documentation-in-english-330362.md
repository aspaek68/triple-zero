# Shaders — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/shaders/index.html
- **Fetched**: 2026-11-18T03:01:45

# Shaders in Godot Engine
==========================

Shaders are small programs that run on the GPU, allowing for complex visual effects and post-processing techniques. In this section, we'll cover the basics of shaders in Godot Engine.

## Introduction to Shaders

Shaders are used to modify the appearance of 3D models and 2D textures in real-time. They can be used to apply effects such as lighting, shading, and texture manipulation.

## Shading Reference

*   [Shading Reference](https://docs.godotengine.org/en/stable/sg/advanced/physics/shader_reference.html)

## Creating Your First Shader

To create a shader, you'll need to:

*   Open the **Shader Editor** in Godot Engine.
*   Create a new shader by clicking on **File** > **New Shader**.
*   Write your shader code in the editor.

## Using Visual Shaders

Visual shaders are a type of shader that can be edited directly in the **Shader Editor**.

*   **Visual Shader Example**: Create a new shader and add the following code:

    ```glsl
shader_type canvas_item;

uniform vec4 color : hint_color;

void fragment() {
    COLOR = color;
}
```

## Using Compute Shaders

Compute shaders are used for general-purpose computing on the GPU.

*   **Compute Shader Example**: Create a new shader and add the following code:

    ```glsl
shader_type compute;

void fragment() {
    // Code to execute on the GPU
}
```

## Screen-Reading Shaders

Screen-reading shaders are used to read data from the screen.

*   **Screen-Reading Shader Example**: Create a new shader and add the following code:

    ```glsl
shader_type screen_read;

void fragment() {
    // Code to read data from the screen
}
```

## Converting GLSL to Godot Shaders

Godot provides a shader conversion tool that can be used to convert GLSL shaders to Godot shaders.

## Shaders Style Guide

*   [Shaders Style Guide](https://docs.godotengine.org/en/stable/sg/advanced/physics/shader_style.html)

## Advanced Post-Processing

Advanced post-processing techniques can be achieved using custom shaders.

*   **Custom Post-Processing Example**: Create a new shader and add the following code:

    ```glsl
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    float brightness = texture_color.x + texture_color.y + texture_color.z;
    COLOR = vec4(brightness * intensity, brightness * intensity, brightness * intensity, 1.0);
}
```

## Making Trees

Trees can be created using custom shaders and the **SubViewport** node.

*   **Tree Shader Example**: Create a new shader and add the following code:

    ```glsl
shader_type canvas_item;

uniform float size : hint_range(0.0, 1.0);
uniform vec4 color : hint_color;

void fragment() {
    vec2 uv = UV;
    uv += vec2(size, size);
    uv = uv * 0.5 + 0.5;
    COLOR = color;
}
```

This shader creates a repeating pattern of trees. The `size` uniform controls the size of the trees, and the `color` uniform controls the color of the trees.
