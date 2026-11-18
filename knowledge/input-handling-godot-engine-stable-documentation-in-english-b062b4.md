# Input handling — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/inputs/index.html
- **Fetched**: 2026-11-18T03:07:17

# Input Handling in Godot Engine
=====================================

Godot Engine provides a robust input handling system to handle user input from various devices such as mice, gamepads, and joysticks.

## Using InputEvent

To handle user input, you need to use the `InputEvent` class. This class represents a single input event and provides information about the event, such as the input device, the type of input (e.g., mouse move, key press), and the timestamp of the event.

### Example:
```gdscript
extends Node

func _process(delta):
    var mouse_position = Input.get_mouse_position()
    var mouse_velocity = Input.get_mouse_velocity()
    print("Mouse Position:", mouse_position)
    print("Mouse Velocity:", mouse_velocity)
```
## Mouse and Input Coordinates

You can get the current mouse position and velocity using the `Input.get_mouse_position()` and `Input.get_mouse_velocity()` functions, respectively.

### Example:
```gdscript
extends Node

func _process(delta):
    var mouse_position = Input.get_mouse_position()
    var mouse_velocity = Input.get_mouse_velocity()
    print("Mouse Position:", mouse_position)
    print("Mouse Velocity:", mouse_velocity)
```
## Customizing the Mouse Cursor

You can customize the mouse cursor by setting its shape, size, and color using the `Input.set_mouse_cursor()` function.

### Example:
```gdscript
extends Node

func _process(delta):
    Input.set_mouse_cursor(0, 0, 0, 0, Vector2(10, 10), Color(1, 1, 1, 1))
```
## Controllers, Gamepads, and Joysticks

You can detect controllers, gamepads, and joysticks using the `Input.is_controller_connected()` function.

### Example:
```gdscript
extends Node

func _process(delta):
    if Input.is_controller_connected(0):
        print("Controller connected!")
    else:
        print("No controller connected.")
```
## Controller Features

Controllers, gamepads, and joysticks have various features, such as acceleration, braking, and axis values. You can access these values using the `Input.get_joy_axis()` function.

### Example:
```gdscript
extends Node

func _process(delta):
    var axis_value = Input.get_joy_axis(0, 0)
    print("Axis Value:", axis_value)
```
## Handling Quit Requests

You can handle quit requests by listening for the `Input.quitting` event.

### Example:
```gdscript
extends Node

func _process(delta):
    if Input.quitting:
        print("Quit request received!")
        # Handle quit request
```
By using these APIs and examples, you can handle user input effectively in your Godot Engine project.
