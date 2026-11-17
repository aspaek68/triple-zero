# Shaders — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/shaders/index.html
- **Fetched**: 2026-11-17T20:37:09

# Shaders in Godot Engine
==========================

Shaders in Godot Engine allow for custom visual effects and post-processing techniques. This document provides an overview of shaders in Godot Engine, including introduction, shading reference, and examples.

## Introduction to Shaders
-------------------------

Shaders are small programs that run on the GPU, allowing for custom rendering and visual effects. They can be used for a variety of purposes, including screen-reading, post-processing, and more.

## Shading Reference
-------------------

The Godot Engine provides a shading reference guide, which includes information on how to use different shader models and techniques.

## Your First Shader
---------------------

The first shader to create is a simple vertex shader. A vertex shader is responsible for transforming vertices before they are sent to the GPU.

### Vertex Shader Example
```glsl
shader_type vertex_shader;

void fragment() {
    // Your shader code here
}
```

## Using VisualShaders
----------------------

VisualShaders are a convenient way to create shaders without writing raw GLSL code. They provide a visual interface for creating and editing shaders.

### VisualShader Example
```glsl
shader_type visual_shader;

uniform float value : hint_range(0, 1);

void fragment() {
    // Your shader code here
}
```

## Using Compute Shaders
----------------------

Compute shaders are used for tasks that require more processing power, such as physics simulations or image processing.

### ComputeShader Example
```glsl
shader_type compute_shader;

uniform float value : hint_range(0, 1);

void fragment() {
    // Your shader code here
}
```

## Screen-Reading Shaders
------------------------

Screen-reading shaders are used to read information from the screen, such as the screen's brightness or color.

### ScreenReadingShader Example
```glsl
shader_type screen_reading_shader;

uniform float value : hint_range(0, 1);

void fragment() {
    // Your shader code here
}
```

## Converting GLSL to Godot Shaders
-----------------------------------

Converting GLSL code to Godot shaders requires modifying the shader code to use Godot-specific syntax and functionality.

## Shaders Style Guide
----------------------

The Godot Engine provides a shaders style guide, which includes best practices for writing shaders and using Godot's shader functionality.

## Using a SubViewport as a Texture
-------------------------------------

Using a SubViewport as a texture allows for advanced visual effects, such as screen-reading and post-processing.

## Custom Post-Processing
-------------------------

Custom post-processing allows for advanced visual effects, such as depth of field and motion blur.

## Advanced Post-Processing
---------------------------

Advanced post-processing allows for even more advanced visual effects, such as lens flares and glow effects.

## Making Trees
----------------

Making trees is an example of using shaders to create a custom visual effect.
