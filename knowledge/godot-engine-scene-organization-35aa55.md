# Godot engine scene organization

- **Source**: https://docs.godotengine.org/en/4.0/getting_started/workflow/best_practices/scene_organization.html
- **Fetched**: 2026-11-17T21:22:27

**Scene Organization Best Practices in Godot Engine**
=====================================================

This document provides guidance on effective scene organization in Godot Engine, following object-oriented programming (OOP) best practices.

**Designing Scenes with No Dependencies**
-----------------------------------------

*   One should design scenes to have no dependencies. Keep everything needed within the scene itself.
*   If a scene must interact with an external context, use **Dependency Injection**.

**Parent-Child Relationships**
---------------------------

*   To establish a parent-child relationship, use the following pattern:
    *   Parent scene connects to a signal emitted by the child node.
    *   Child node emits the signal and triggers parent-defined behavior.
*   Alternatively, use method calls to start behavior:
    *   Parent scene calls a method on the child node.
    *   Child node calls a method on the parent node.

**Example: Parent-Child Relationship**
```gdscript
# Parent
$Child.connect("SignalName", self, "_on_Child_SignalName")
# Child
emitSignal("SignalName")

func _on_Child_SignalName():
    # Trigger parent-defined behavior
```
```gdscript
# Parent
call("do")

func _ready():
    $Child.call("do")

# Child
func _ready():
    call("do")
```
**Initializing Callable Properties**
------------------------------------

*   Use callable properties to start behavior:
    *   Parent scene sets a callable property on the child node.
    *   Child node calls the method.

```gdscript
# Parent
$Child.func_property = Callable.from("ChildMethod")
# Child
func ChildMethod():
    # Start behavior
```
```gdscript
# Parent
$Child.func_property = Callable.from("ParentMethod")
# Parent
func ParentMethod():
    # Start behavior
```
**Initializing Node References**
------------------------------

*   Use node references to use parent-defined nodes:
    *   Parent scene sets a node reference on the child node.
    *   Child node uses the reference.

```gdscript
# Parent
$Child.target = self
# Child
print($Target)
```
```gdscript
# Parent
$Child.target_path = ".."
# Child
$Target = GetNode("..")
print($Target)
```
**Best Practices for Object Relations**
--------------------------------------

*   Nodes should only be aware of their hierarchy and communicate through their ancestors.
*   Avoid placing dependencies on external contexts, as it can lead to development hell.

By following these best practices, you can design effective scene organization in Godot Engine, ensuring maintainable and reusable code.
