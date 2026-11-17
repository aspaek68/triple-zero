# Physics introduction — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- **Fetched**: 2026-11-17T18:06:20

Physics introduction — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
Physics
Physics introduction
Edit on GitHub
Learn how to contribute!
Physics introduction
In game development, you often need to know when two objects in the game
When a collision is detected, you typically want something to happen. This
In this guide, you will learn:
Godot's four collision object types
How each collision object works
When and why to choose one type over another
Note
This document's examples will use 2D objects. Every 2D physics object
Warning
Physics in Godot, regardless of physics engine, is
Collision objects
Godot offers four kinds of collision objects which all extend
CollisionObject2D

---

Physics introduction — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
Physics
Physics introduction
Edit on GitHub
Learn how to contribute!
Physics introduction

In game development, you often need to know when two objects in the game
intersect or come into contact. This is known as
collision detection
.
When a collision is detected, you typically want something to happen. This
is known as
collision response
.
Godot offers a number of collision objects in 2D and 3D to provide both collision detection
and response. Trying to decide which one to use for your project can be confusing.
You can avoid problems and simplify development if you understand how each works
and what their pros and cons are.
In this guide, you will learn:
Godot's four collision object types
How each collision object works
When and why to choose one type over another
Note
This document's examples will use 2D objects. Every 2D physics object
and collision shape has a direct equivalent in 3D and in most cases
they work in much the same way.
Warning
Physics in Godot, regardless of physics engine, is
not
deterministic,
the nature of physics engine determinism is very complex and has to do with many factors,
this means physics is not guaranteed to run the same way for seemingly identical situations.
Collision objects

Godot offers four kinds of collision objects which all extend
CollisionObject2D
.
The last three listed below are physics bodies and additionally extend
PhysicsBody2D
.
Area2D
Area2D
nodes provide
detection
and
influence
. They can detect when
objects overlap and can emit signals when bodies enter or exit. An
Area2D
can also be used to override physics properties, such as gravity or damping,
in a defined area.
StaticBody2D
A static body is one that is not moved by the physics engine. It participates
in collision detection, but does not move in response to the collision. They
are most often used for objects that are part of the environment or that

[... truncated ...]
