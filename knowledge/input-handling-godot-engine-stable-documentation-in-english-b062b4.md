# Input handling — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/inputs/index.html
- **Fetched**: 2026-11-17T20:46:50

# Input Handling in Godot Engine

## Introduction

Input handling is a crucial aspect of game development in Godot Engine. It allows you to capture user input, such as keyboard, mouse, and controller events, and react to them accordingly.

## Using InputEvent

The `InputEvent` class is the foundation for input handling in Godot Engine. It provides a way to access input events, such as keyboard presses, mouse movements, and controller button presses.

### Example:
```gdscript
var input_event = InputEvent.new()
if input_event.is_action_pressed("ui_right"):
    print("Right arrow key pressed")
```
## Mouse and Input Coordinates

Godot Engine provides a way to get the mouse coordinates at any point in time. This can be useful for tasks such as drawing, scrolling, or targeting.

### Example:
```gdscript
var mouse_x = Input.get_mouse_position().x
var mouse_y = Input.get_mouse_position().y
print("Mouse position: ", mouse_x, ", ", mouse_y)
```
## Customizing the Mouse Cursor

You can customize the mouse cursor to suit your game's needs. This can be done using the `Input.set_mouse_cursor_visible()` function.

### Example:
```gdscript
Input.set_mouse_cursor_visible(false)
```
## Controllers, Gamepads, and Joysticks

Godot Engine supports a wide range of controllers, gamepads, and joysticks. You can use the `Input.get_connected_controller()` function to check if a controller is connected.

### Example:
```gdscript
var controller = Input.get_connected_controller()
if controller:
    print("Controller found")
```
## Controller Features

Godot Engine provides several features for working with controllers, including support for analog sticks, directional buttons, and trigger buttons.

### Example:
```gdscript
var controller = Input.get_connected_controller()
if controller:
    var analog_stick_x = controller.get_analog_stick_x()
    var analog_stick_y = controller.get_analog_stick_y()
    print("Analog stick values: ", analog_stick_x, ", ", analog_stick_y)
```
## Handling Quit Requests

You can handle quit requests using the `Input.is_key_pressed()` function.

### Example:
```gdscript
if Input.is_key_pressed(KEY_ESC):
    print("Escape key pressed")
    # Handle quit request here
```
By mastering input handling in Godot Engine, you can create more immersive and responsive gaming experiences.
