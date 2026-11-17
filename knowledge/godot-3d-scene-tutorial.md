# Godot 3D scene tutorial

- **Source**: https://docs.godotengine.org/en/stable/getting_started/first_3d_game/index.html
- **Fetched**: 2026-11-17T21:17:29

# Godot 3D Scene Tutorial
=====================================

## Table of Contents

* [Setting up the game area](#setting-up-the-game-area)
* [Player scene and input actions](#player-scene-and-input-actions)
* [Moving the player with code](#moving-the-player-with-code)
* [Designing the mob scene](#designing-the-mob-scene)
* [Spawning monsters](#spawning-monsters)
* [Jumping and squashing monsters](#jumping-and-squashing-monsters)
* [Killing the player](#killing-the-player)
* [Score and replay](#score-and-replay)
* [Character animation](#character-animation)
* [Going further](#going-further)

## Setting up the game area
Create a new 3D scene in Godot and set up the game area by adding a `Spatial` node as the main container.

## Player scene and input actions
Create a new `KinematicBody3D` node for the player and set up input actions using the `InputAction` class. For example:
```gdscript
extends KinematicBody3D

var speed = 10.0

func _process(delta):
    var velocity = Vector3.ZERO
    velocity.x = get_input_vector().x * speed
    velocity.z = get_input_vector().z * speed
    move_and_slide(velocity)
```
## Moving the player with code
Use the `move_and_slide` function to move the player based on the input velocity.

## Designing the mob scene
Create a new `KinematicBody3D` node for the mob and set up its properties, such as position, velocity, and size.

## Spawning monsters
Use the `spawn` function to spawn monsters at regular intervals. For example:
```gdscript
extends Spatial

func _process(delta):
    if rand() < 0.1:  # 10% chance of spawning a monster
        spawn_monster()
    pass

func spawn_monster():
    var mob = load("res://Mob.tscn")
    mob.position = Vector3.random() * 10
    add_child(mob)
```
## Jumping and squashing monsters
Use the `KinematicBody3D` node's `apply_central_impulse` function to make the player jump, and implement the squashing mechanic using the `Area3D` node's `start_detection_mode` function.

## Killing the player
Use the `CollisionShape3D` node's `start_detection_mode` function to detect when the player collides with a monster.

## Score and replay
Implement a score system and a retry screen using the `Label` and `Button` nodes.

## Character animation
Use the `AnimationPlayer` node to play animations for the player and mobs.

## Going further
This tutorial is just the beginning of your 3D game development journey. You can explore more advanced topics, such as physics, AI, and graphics rendering, to create a more complex and engaging game.
