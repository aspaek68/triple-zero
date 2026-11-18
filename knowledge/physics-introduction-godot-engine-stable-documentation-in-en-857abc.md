# Physics introduction — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- **Fetched**: 2026-11-18T14:21:03

Physics Introduction
=====================

Godot Engine provides a powerful physics system to simulate collisions between objects in your game. In this guide, we will explore the four collision object types, how they work, and when to choose one over another.

### Collision Object Types

Godot offers four types of collision objects:

1. **Area2D**: Provides detection and influence. Can detect when objects overlap and emit signals when bodies enter or exit. Can also override physics properties, such as gravity or damping, in a defined area.
2. **StaticBody2D**: A static body that participates in collision detection but does not move in response to the collision. Often used for objects that are part of the environment or that do not need dynamic behavior.
3. **RigidBody2D**: Implements simulated 2D physics. You apply forces to it (gravity, impulses, etc.) and the physics engine calculates the resulting movement.
4. **CharacterBody2D**: A body that provides collision detection but no physics. All movement and collision response must be implemented in code.

### Physics Material

Static bodies and rigid bodies can be configured to use a `PhysicsMaterial`, which allows adjusting the friction and bounce of an object and setting whether it's absorbent and/or rough.

### Collision Shapes

A physics body can hold multiple `Shape2D` objects as children, which are used to define the object's collision bounds and detect contact with other objects.

### Physics Process Callback

The physics engine runs at a fixed rate (default 60 iterations per second). To ensure physics-related code runs at this rate, use the `Node._physics_process()` callback. This method is called before each physics step and passes a `delta` parameter, which is the time passed in seconds since the last step.

### Collision Layers and Masks

The collision layer system allows you to build complex interactions between objects. Each collision object has 32 different physics layers it can interact with. Use `collision_layer` and `collision_mask` properties to configure layer interactions.

Example Use Case
---------------

```gdscript
extends Area2D

func _process(delta):
    if get_overlapping_bodies() != []:
        print("Collision detected!")
```

In this example, the `Area2D` node detects collisions with other bodies on the same layer (default layer 1).
