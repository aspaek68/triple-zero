# Godot 4 VFX tutorials

- **Source**: https://github.com/Sidremus/Godot-4.1-VFX-Tutorial-Project
- **Fetched**: 2026-11-18T18:18:39

# Godot 4 VFX Tutorials
======================

A project showcasing approaches to creating visual effects (VFX) in Godot 4.1.

## Overview
------------

This project aims to demonstrate how to build VFX in Godot 4.1, with a focus on low-poly effects. It is updated regularly as new tutorials are created for the author's YouTube channel.

## Features and APIs
--------------------

*   Uses Godot 4.1 as the game engine
*   Demonstrates the use of the `torch` library for VFX
*   Utilizes Godot's built-in API for creating custom effects

## Tutorials and Effect Types
---------------------------

The project currently features a single tutorial for a low-poly fire effect. Future updates will add more effect types, showcasing how to build them in Godot.

### Example: Low-Poly Fire Effect

*   To create a low-poly fire effect, use the `torch` library and Godot's built-in API for creating custom effects.
*   Example code:
    ```gd
extends KinematicBody2D

func _process(delta):
    # Calculate fire effect position and size
    var fire_position = Vector2(rand_range(-100, 100), rand_range(-100, 100))
    var fire_size = 50 + rand_range(-10, 10)

    # Update fire effect position and size
    position = Vector2(fire_position.x, fire_position.y)
    scale = Vector2(fire_size, fire_size)

    # Apply fire effect shader
    $FireEffectShader.set_shader_param("position", position)
    $FireEffectShader.set_shader_param("size", fire_size)
```
    ```gd
extends Sprite

func _process(delta):
    # Update fire effect texture
    $FireEffectTexture.set_texture(load("res://fire_effect.png"))

    # Apply fire effect shader
    $FireEffectShader.set_shader_param("texture", $FireEffectTexture.get_texture())
```
### Contributing

Contributions to this project are welcome. New tutorials and effect types can be added, and the project can be updated to reflect the latest changes in the Godot game engine.

## Resources
------------

*   [GitHub Repository](https://github.com/Sidremus/Godot-4.1-VFX-Tutorial-Project)
*   [YouTube Channel](https://www.youtube.com/Sidremus)

## License
---------

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
