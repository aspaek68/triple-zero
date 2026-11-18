# GDScript style guide — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Fetched**: 2026-11-18T03:05:54

**GDScript Style Guide**
========================

This style guide provides conventions for writing elegant GDScript code, aiming to promote consistency across projects, discussions, and tutorials.

### General Guidelines

* This style guide is inspired by Python's PEP 8 style guide.
* Style guides are not hard rulebooks, but rather guidelines to encourage clean and readable code.
* Consistency is more important than following this guide exactly.

### Formatting

#### Encoding and Special Characters

* Use UTF-8 encoding without a byte order mark.
* Use line feed (LF) characters to break lines, not CRLF or CR.

#### Indentation

* Each indent level should be one greater than the block containing it.
* Use tabs instead of spaces for indentation.
* Use 2 indent levels to distinguish continuation lines from regular code blocks.

#### Trailing Comma

* Use a trailing comma on the last line in arrays, dictionaries, and enums.

#### Blank Lines

* Surround functions and class definitions with two blank lines.
* Use one blank line inside functions to separate logical sections.

### Line Length

* Keep individual lines of code under 100 characters.
* Try to keep lines under 80 characters for improved readability.

### One Statement per Line

* Avoid combining multiple statements on a single line, including conditional statements.

### Exceptions

* The only exception to the one statement per line rule is the ternary operator.

### Example

```gdscript
class_name StateMachine extends Node:
    signal state_changed(previous, new)

    var initial_state = Node.new()
    var is_active = true

    @onready var _state = initial_state
    @onready var _state_name = _state.name

    func _init():
        add_to_group("state_machine")

    func _enter_tree():
        print("this happens before the ready method!")

    func _ready():
        state_changed.connect(_on_state_changed)
        _state.enter()

    func _unhandled_input(event):
        _state.unhandled_input(event)

    func _physics_process(delta):
        _state.physics_process(delta)

    func transition_to(target_state_path, msg={}):
        if not has_node(target_state_path):
            return
        var target_state = get_node(target_state_path)
        assert not target_state.is_composite
        _state.exit()
        self._state = target_state
        target_state.enter(msg)
        Events.player_state_changed.emit(_state.name)

    func set_is_active(value):
        is_active = value
        set_physics_process(value)
        set_process_unhandled_input(value)
        set_block_signals(not value)

    func set_state(value):
        _state = value
        _state_name = _state.name

    func _on_state_changed(previous, new):
        print("state changed")
        state_changed.emit()
```

Note: This is just a sample code snippet and is not intended to be a complete example of a GDScript class.
