# Godot 3D camera animation tutorial

- **Source**: https://docs.godotengine.org/en/latest/tutorials/3d/spring_arm.html
- **Fetched**: 2026-11-17T21:20:41

Third-Person Camera with Spring Arm
=====================================

Table of Contents
-----------------

*   [Introduction](#introduction)
*   [What is a Spring Arm?](#what-is-a-spring-arm)
*   [Setting up the Spring Arm and Camera](#setting-up-the-spring-arm-and-camera)
*   [Example Code](#example-code)

### Introduction

In 3D games, a third-person camera is commonly used to follow and rotate around a character or vehicle. In Godot, this can be achieved by setting a `Camera3D` node as a child of a node. However, if not done correctly, the camera can clip through geometry and hide the scene.

This tutorial introduces the `SpringArm3D` node, which is used to prevent the camera from clipping through geometry. A spring arm has two main components that affect its behavior: length and shape. The shape is used to check for collisions, and the spring arm tries to keep its children at the end of its length.

### What is a Spring Arm?

A spring arm has two main components:

*   **Length**: The distance from the global position to check for collisions.
*   **Shape**: The shape used to check for collisions. The spring arm will "sweep" this shape from its origin out towards its length.

The spring arm tries to keep all of its children at the end of its length. When the shape collides with something, the children are placed at or near that collision point.

### Setting up the Spring Arm and Camera

To set up a spring arm camera, follow these steps:

1.  Create a new node (e.g., `Player`) and add a `Camera3D` node as a child.
2.  Create a new node (e.g., `SpringArm`) and add it as a child to the `Camera3D` node.
3.  Set the `SpringArm` node's `Length` property to a value that is sufficient to prevent the camera from clipping through geometry.
4.  Set the `Shape` property of the `SpringArm` node to an empty shape.
5.  Update the `player/player.gd` script to grab the `Camera3D` and `SpringArm` nodes by their unique names.

### Example Code

```gd
@export_range(0.0, 1.0)
var mouse_sensitivity = 0.01

@export
var tilt_limit = deg_to_rad(75)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _camera_pivot.rotation.x -= event.screen_relative.y * mouse_sensitivity
        _camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
        _camera_pivot.rotation.y += -event.screen_relative.x * mouse_sensitivity
```

This code snippet implements mouselook using `screen_relative` for resolution-independent sensitivity. It also prevents the camera from rotating too far up or down.

Run the game and notice that mouse movement now rotates the camera around the character. If the camera moves into a wall, it will collide with it.
