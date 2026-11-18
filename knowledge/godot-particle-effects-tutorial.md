# Godot particle effects tutorial

- **Source**: https://www.youtube.com/watch?v=F1Fyj3Lh_Pc
- **Fetched**: 2026-11-18T17:01:05

Here is a concise, well-structured markdown note summarizing the text about 'Godot particle effects tutorial':

# Godot Particle Effects Tutorial
==========================

## Introduction

This tutorial covers the basics of particle effects in Godot Engine, from beginner to professional level.

## Key Concepts

*   Particle systems are used to create simulations of natural phenomena, such as fire, water, or smoke, in a game or application.
*   Particle systems can be used for both visual and audio effects.

## Creating a Particle System

To create a particle system in Godot, follow these steps:

1.  Go to the **Scene** tab in Godot Engine.
2.  Create a new node by clicking on the **Node** tab.
3.  Select **Particles** from the **Node** tree.
4.  Set the **Particle** properties, such as **Size**, **Speed**, and **Emission**, to achieve the desired effect.

## APIs and Functions

*   `create_persistent_emitter()`: Creates a persistent emitter, which is an emitter that remains in existence even after the scene has been unloaded.
*   `create_dynamic_emitter()`: Creates a dynamic emitter, which is an emitter that is destroyed when the scene is unloaded.
*   `set_emission()`: Sets the emission rate of the particles.
*   `set_speed()`: Sets the speed of the particles.

## Examples

*   To create a simple particle system, use the following code:
    ```gdscript
extends Node

func _ready():
    var particle_system = get_node("Particles")
    particle_system.set_emission(100)
    particle_system.set_speed(10)
```
*   To create a more complex particle system, use the following code:
    ```gdscript
extends Node

func _ready():
    var particle_system = get_node("Particles")
    particle_system.set_emission(1000)
    particle_system.set_speed(50)
    particle_system.create_dynamic_emitter()
```
*   To use a sound file with the particle system, use the following code:
    ```gdscript
extends Node

func _ready():
    var particle_system = get_node("Particles")
    particle_system.set_sound_file("path/to/sound/file.wav")
```

## Conclusion

This tutorial covers the basics of particle effects in Godot Engine. By following the steps and examples outlined above, you can create a variety of particle effects to enhance your game or application.
