# Input handling — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/inputs/index.html
- **Fetched**: 2026-11-18T14:23:49

# Input Handling in Godot Engine

Godot Engine's input handling system allows for customizable and precise control over user input in games and applications.

## Using Input Events

Input events are the foundation of Godot's input handling system. They provide a way to access and manipulate user input data, such as mouse coordinates, controller data, and more.

### Example Code
```gdscript
extends Node

func _process(delta):
    var event = Input.get_event()
    if event is InputEventMouseMotion:
        print("Mouse moved to: ", event.position)
    elif event is InputEventJoystickMotion:
        print("Joystick moved to: ", event.position)
```
## Mouse and Input Coordinates

Godot provides functions to access mouse coordinates and other input data.

### Example Code
```gdscript
extends Node

func _process(delta):
    var mouse_pos = Input.get_mouse_position()
    print("Mouse position: ", mouse_pos)
```
## Customizing the Mouse Cursor

Godot provides the `Input.set_mouse_cursor_visible` function to customize the mouse cursor.

### Example Code
```gdscript
extends Node

func _process(delta):
    Input.set_mouse_cursor_visible(false)
```
## Controllers, Gamepads, and Joysticks

Godot provides functions to access controller data and other gamepad and joystick data.

### Example Code
```gdscript
extends Node

func _process(delta):
    var controller = Input.get_joy(0)
    print("Controller data: ", controller)
```
## Controller Features

Godot supports various controller features, including:

* Haptic feedback
* Vibration
* Button mapping

### Example Code
```gdscript
extends Node

func _process(delta):
    var haptic = Input.get_haptic()
    haptic.set_haptic_setting(Input.HAPTIC_SETTING_HAPTIC_1, 0.5)
```
## Handling Quit Requests

Godot provides functions to handle quit requests, such as closing windows and quitting applications.

### Example Code
```gdscript
extends Node

func _process(delta):
    if Input.is_action_pressed("ui_close"):
        quit()
```
Note: The above examples are in GDScript, but the same functionality can be achieved using other Godot programming languages, such as C# or C++.
