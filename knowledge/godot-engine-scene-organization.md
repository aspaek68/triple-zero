# Godot engine scene organization

- **Source**: https://docs.godotengine.org/en/latest/tutorials/best_practices/scene_organization.html
- **Fetched**: 2026-11-17T21:21:47

# Scene Organization in Godot Engine
=====================================

## Best Practices

Scene organization is crucial in maintaining a well-structured and maintainable Godot project. The goal is to design scenes that have no dependencies on external contexts, and instead, use dependency injection to provide the necessary dependencies.

### Key Concepts

*   **Loose Coupling**: Keep the size of objects small and improve their reusability by using loose coupling.
*   **Dependency Injection**: Expose data and then rely on a parent context to initialize it.
*   **Signal and Slot Mechanism**: Use signals and slots to respond to behavior without starting it.
*   **Callable and CallableProperty**: Use callables and callables properties to start behavior safely.

## Scene Structure

*   **No Dependencies**: Design scenes to have no dependencies on external contexts.
*   **Self-Sufficient**: Create scenes that keep everything they need within themselves.

## API Examples

### Dependency Injection

```gd
// Parent
var child = get_node("Child")
child.connect("signal_name", self, "_handle_signal")
child.emit_signal("signal_name")

func _handle_signal():
    print("Received signal")

# Child
func _ready():
    emit_signal("signal_name")
```

### Signal and Slot Mechanism

```gd
// Parent
var child = get_node("Child")
child.connect("signal_name", self, "_handle_signal")
child.emit_signal("signal_name")

func _handle_signal():
    print("Received signal")
```

### Callable and CallableProperty

```gd
// Parent
var child = get_node("Child")
child.connect("signal_name", self, "_handle_signal")
child.emit_signal("signal_name")

func _handle_signal():
    print("Received signal")

# Child
func _ready():
    var func_property = Callable.from(self, "_handle_signal")
    set("func_property", func_property)
    func_property()
```

### Node Reference

```gd
// Parent
var child = get_node("Child")
child.set("target", self)
print(child.get("target"))

# Child
func _ready():
    var target = get_node("../Parent").get_node("Child").get("target")
    print(target)
```

### NodePath

```gd
// Parent
var child = get_node("Child")
child.set("target_path", ".")
print(child.get("target_path"))

# Child
func _ready():
    var target_path = "../Parent/Child"
    set("target_path", NodePath(target_path))
    print(get_node(target_path))
```

By following these best practices and using the provided APIs, you can create well-organized scenes that are easy to maintain and reuse.
