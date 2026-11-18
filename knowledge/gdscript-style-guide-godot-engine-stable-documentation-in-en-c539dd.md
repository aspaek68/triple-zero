# GDScript style guide — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Fetched**: 2026-11-18T14:22:32

GDScript Style Guide
=====================

### Overview

The GDScript style guide provides conventions for writing elegant and readable GDScript code. The goal is to promote consistency across projects, discussions, and tutorials, and to support the development of auto-formatting tools.

### Inspiration

The GDScript style guide is inspired by Python's PEP 8 programming style guide.

### Conventions

#### Class and Function Definitions

* Surround class and function definitions with two blank lines.
* Use a single line between classes and function definitions in the class reference and in short code snippets.

#### Indentation

* Each indent level should be one greater than the block containing it.
* Use 2 indent levels to distinguish continuation lines from regular code blocks.

#### Line Length

* Keep individual lines of code under 100 characters.
* Try to keep lines under 80 characters for better readability.

#### Trailing Comma

* Use a trailing comma on the last line in arrays, dictionaries, and enums.

#### Blank Lines

* Surround functions and class definitions with two blank lines.
* Use one blank line inside functions to separate logical sections.

#### Arrays, Dictionaries, and Enums

* Use a single indentation level to distinguish continuation lines.
* Use a trailing comma on the last line in arrays, dictionaries, and enums.

### Examples

```gdscript
class_name StateMachine extends Node:
    ## Hierarchical State machine for the player.
    ## Initializes states and delegates engine callbacks ([method Node._physics_process],
    ## [method Node._unhandled_input]) to the state.
    signal state_changed(previous, new)

    @export var initial_state: Node
    var is_active = true: set = set_is_active

    @onready var _state = initial_state: set = set_state

    func _init():
        add_to_group("state_machine")

    func enter_tree():
        print("this happens before the ready method!")

    func _ready():
        state_changed.connect(_on_state_changed)

    func transition_to(target_state_path, msg={}):
        if not has_node(target_state_path):
            return
        var target_state = get_node(target_state_path)
        assert(target_state.is_composite() == false)
        _state.exit()
        self._state = target_state
        _state.enter(msg)

    # ...

class State:
    var foo = 0

    func _init():
        print("Hello!")
```

```gdscript
func heal(amount):
    health += amount
    health = min(health, max_health)
    health_changed.emit(health)

func take_damage(amount, effect = null):
    health -= amount
    health = max(0, health)
    health_changed.emit(health)
```

```gdscript
var party = [
    "Godot",
    "Godette",
    "Steve"
]

var character_dict = {
    "Name": "Bob",
    "Age": 27,
    "Job": "Mechanic"
}

enum Tile:
    BRICK
    FLOOR
    SPIKE
    TELEPORT
```
