# Godot 4 VFX scripting

- **Source**: https://docs.godotengine.org/en/4.4/tutorials/scripting/index.html
- **Fetched**: 2026-11-18T18:20:27

**Godot 4 VFX Scripting**
==========================

**Overview**
------------

Godot 4 provides a powerful scripting language for creating visual effects (VFX). This document provides an overview of the core features, programming languages, and APIs available for VFX scripting in Godot 4.

**Programming Languages**
------------------------

Godot 4 supports the following programming languages for VFX scripting:

*   **GDScript**: A high-level, dynamically-typed language specifically designed for Godot.
*   **C#/.NET**: A compiled, statically-typed language that can be used for VFX scripting in Godot.

**Core Features**
----------------

The following features are specific to the Godot engine and are available in all supported languages:

### **Debugging**

*   Use the `print()` function to output values to the console.
*   Use the `debug()` function to display a message box.

### **Idle and Physics Processing**

*   Use the `get_tree().connect()` method to connect to the Godot Tree.
*   Use the `get_tree().get_root()` method to access the root node.

### **Groups**

*   Use the `get_tree().get_root().get_node()` method to access nodes.

### **Nodes and Scene Instances**

*   Use the `get_tree().get_node()` method to access nodes.
*   Use the `get_tree().get_root().get_node()` method to access nodes.

### **Overridable Functions**

*   Use the `get_tree().connect()` method to connect to overridable functions.

### **Cross-Language Scripting**

*   Use the `GodotAPI` to access Godot's API from other languages.

### **Creating Script Templates**

*   Use the `get_tree().get_resource_path()` method to access script templates.

### **Evaluating Expressions**

*   Use the `eval()` function to evaluate expressions.

### **Change Scenes Manually**

*   Use the `get_tree().change_scene()` method to change scenes manually.

### **Instancing with Signals**

*   Use the `get_tree().connect()` method to connect to instancing signals.

### **Pausing Games and Process Mode**

*   Use the `get_tree().pause()` method to pause games.
*   Use the `get_tree().set_process_mode()` method to set process mode.

### **File System**

*   Use the `get_tree().get_resource_path()` method to access the file system.

### **Resources**

*   Use the `get_tree().get_resource_path()` method to access resources.

### **Singletons (Autoload)**

*   Use the `get_tree().get_resource_path()` method to access singletons.

### **Using SceneTree**

*   Use the `get_tree().get_root()` method to access the SceneTree.

### **Scene Unique Nodes**

*   Use the `get_tree().get_node()` method to access unique nodes.

**API Documentation**
--------------------

For more information on the Godot API, refer to the [Godot Engine 4.4 documentation](https://docs.godotengine.org/en/4.4/).

**Example Code**
---------------

```gdscript
extends Node

func _ready():
    # Print a message to the console
    print("Hello, World!")

    # Connect to the Godot Tree
    get_tree().connect("idle", self, "_on_idle")

func _on_idle():
    # Evaluate an expression
    var result = eval("2 + 2")
    print(result)
```

Note: This is a brief overview of the Godot 4 VFX scripting features. For more detailed information, please refer to the Godot Engine 4.4 documentation.
