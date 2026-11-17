# GDScript style guide — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Fetched**: 2026-11-17T20:43:14

**GDScript Style Guide**
==========================

**Overview**
------------

This style guide outlines conventions for writing elegant GDScript code, promoting consistency across projects, discussions, and tutorials. It is inspired by Python's PEP 8 style guide.

**Conventions**
---------------

### Encoding and Special Characters

* Use UTF-8 encoding without a byte order mark.
* Use line feed (LF) characters to break lines, not CRLF or CR.
* Use tabs instead of spaces for indentation.

### Indentation

* Each indent level should be one greater than the block containing it.
* Use 2 indent levels to distinguish continuation lines from regular code blocks.
* Exceptions: arrays, dictionaries, and enums.

### Trailing Comma

* Use a trailing comma on the last line in arrays, dictionaries, and enums.

### Blank Lines

* Surround functions and class definitions with two blank lines.
* Use one blank line inside functions to separate logical sections.

### Line Length

* Keep individual lines of code under 100 characters.
* Try to keep lines under 80 characters for optimal readability.

### One Statement per Line

* Avoid combining multiple statements on a single line, including conditional statements.

### Ternary Operator

* Format multiline statements for readability when using the ternary operator.

### Example

```gdscript
# Complete class example
class_name
StateMachine
extends
Node

## Hierarchical State machine for the player.
##
## Initializes states and delegates engine callbacks ([method Node._physics_process],
## [method Node._unhandled_input]) to the state.

signal
state_changed
(
previous
,
new
)
@export
var
initial_state
:
Node
var
is_active
=
true
:
set
=
set_is_active
@onready
var
_state
=
initial_state
:
set
=
set_state
@onready
var
_state_name
=
_state
.
name

func
_init
():
add_to_group
(
"state_machine"
)

func
_enter_tree
():
print
(
"this happens before the ready method!"
)

func
_ready
():
state_changed
.
connect
(
_on_state_changed
)
_state
.
enter
()

func
_unhandled_input
(
event
):
_state
.
unhandled_input
(
event
)

func
_physics_process
(
delta
):
_state
.
physics_process
(
delta
)

func
transition_to
(
target_state_path
,
msg
=
{}):
if
not
has_node
(
target_state_path
):
return
var
target_state
=
get_node
(
target_state_path
)
assert
(
target_state
.
is_composite
==
false
)
_state
.
exit
()
self
.
_state
=
target_state
_state
.
enter
(
msg
)

Events
.
player_state_changed
.
emit
(
_state
.
name
)

func
set_is_active
(
value
):
is_active
=
value
set_physics_process
(
value
)
set_process_unhandled_input
(
value
)
set_block_signals
(
not
value
)

func
set_state
(
value
):
_state
=
value
_state_name
=
_state
.
name

class
State
:
var
foo
=
0

func
_init
():
print
(
"Hello!"
)
```

Note: This is not an exhaustive list of all GDScript style guidelines. For more information, please refer to the official Godot Engine documentation.
