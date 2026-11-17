# Godot 3D camera animation tutorial

- **Source**: https://docs.godotengine.org/en/latest/tutorials/3d/spring_arm.html
- **Fetched**: 2026-11-17T21:19:03

**Third-Person Camera with Spring Arm in Godot 3D**

**Introduction**
---------------

In Godot 3D, a third-person camera is used to follow and rotate around a player character or vehicle. To achieve this, a `Camera3D` is set as a child of a node, but the camera clips through geometry and hides the scene. This is where the `SpringArm3D` node comes in.

**What is a Spring Arm?**
-------------------------

A spring arm has two main components that affect its behavior:

*   `length`: The distance from the global position to check for collisions.
*   `shape`: The shape used to check for collisions. The spring arm tries to keep all of its children at the end of its length.

**Spring Arm with a Camera**
---------------------------

When a camera is placed as a child of a spring arm, a pyramid representing the camera is used as the shape. This pyramid represents the near plane of the camera.

**Setting up the Spring Arm and Camera**
----------------------------------------

To set up the spring arm and camera, follow these steps:

1.  Add a `SpringArm3D` node as a child of the player node.
2.  Set the `length` of the spring arm to 3 units, so it is placed behind the character.
3.  Leave the `shape` of the spring arm as empty, so it uses the camera's pyramid shape.
4.  Update the `player/player.gd` script to grab the camera and the pivot points by their unique names.
5.  Add an `_UnhandledInput` function to check for camera movement and rotate the pivot point accordingly.

**Example Code**
----------------

```gdscript
@export_range(0.0, 1.0)
var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@onready
var _camera := %Camera3D as Camera3D
@onready
var _camera_pivot := %CameraPivot as Node3D

func _UnhandledInput(event: InputEvent):
    if event is InputEventMouseMotion:
        _camera_pivot.rotation.x -= event.screen_relative.y * mouse_sensitivity
        _camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
        _camera_pivot.rotation.y += -event.screen_relative.x * mouse_sensitivity
```

**Tips and Variations**
-------------------------

*   You can try other shapes for the spring arm, such as a sphere, to achieve a smoother camera movement.
*   To prevent the camera from rotating too far up or down, use the `clampf` function to limit the camera's rotation.

By following these steps and using the provided example code, you can create a third-person camera with a spring arm in Godot 3D.
