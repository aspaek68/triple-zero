# GDScript style guide — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Fetched**: 2026-11-17T17:41:17

GDScript style guide — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
Scripting
GDScript
GDScript style guide
Edit on GitHub
Learn how to contribute!
GDScript style guide
This style guide lists conventions to write elegant GDScript. The goal is to
Since GDScript is close to Python, this guide is inspired by Python's
PEP 8
Style guides aren't meant as hard rulebooks. At times, you may not be able to
Note
Godot's built-in script editor uses a lot of these conventions
Here is a complete class example based on these guidelines:
StateMachine
Node
Node
Events
State

---

GDScript style guide — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
Scripting
GDScript
GDScript style guide
Edit on GitHub
Learn how to contribute!
GDScript style guide

This style guide lists conventions to write elegant GDScript. The goal is to
encourage writing clean, readable code and promote consistency across projects,
discussions, and tutorials. Hopefully, this will also support the development of
auto-formatting tools.
Since GDScript is close to Python, this guide is inspired by Python's
PEP 8
programming
style guide.
Style guides aren't meant as hard rulebooks. At times, you may not be able to
apply some of the guidelines below. When that happens, use your best judgment,
and ask fellow developers for insights.
In general, keeping your code consistent in your projects and within your team is
more important than following this guide to a tee.
Note
Godot's built-in script editor uses a lot of these conventions
by default. Let it help you.
Here is a complete class example based on these guidelines:
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

[... truncated ...]
