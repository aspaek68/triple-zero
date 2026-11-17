# Physics introduction — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- **Fetched**: 2026-11-17T20:39:09

**Godot Physics Introduction**
===========================

**Overview**
------------

Godot provides a variety of collision objects to detect and respond to collisions in game development. This guide will introduce the four types of collision objects, their usage, and provide examples to help you understand how to use them effectively.

**Collision Objects**
--------------------

Godot offers four types of collision objects, all extending `CollisionObject2D`. The last three types are physics bodies and extend `PhysicsBody2D`.

*   `Area2D`: Provides detection and influence. Can detect overlapping objects and emit signals when bodies enter or exit. Can also override physics properties, such as gravity or damping, in a defined area.
*   `StaticBody2D`: A static body that participates in collision detection but does not move in response to the collision. Used for objects that are part of the environment or do not need dynamic behavior.
*   `RigidBody2D`: Implements simulated 2D physics. Forces are applied to the body, and the physics engine calculates the resulting movement. Does not control the body directly.
*   `CharacterBody2D`: Provides collision detection but no physics. Movement and collision response must be implemented in code.

**Physics Material**
------------------

Static bodies and rigid bodies can be configured to use a `PhysicsMaterial`. Allows adjusting friction, bounce, absorbency, and roughness.

**Collision Shapes**
------------------

A physics body can hold any number of `Shape2D` objects as children. These shapes are used to define the object's collision bounds and detect contact with other objects.

**Physics Process Callback**
---------------------------

The physics engine runs at a fixed rate (default 60 iterations per second). Physics-related code should run at this rate. Godot differentiates between physics and idle processing. Two callbacks are provided: `Node._physics_process()` for physics processing and a default `Node._process()` for idle processing.

**Collision Layers and Masks**
-----------------------------

The collision layer system allows complex interactions between objects. The key concepts are layers and masks. Each `CollisionObject2D` has 32 different physics layers it can interact with. Layers can be configured via code or the Inspector.

*   `collision_layer`: Describes the layers an object appears in.
*   `collision_mask`: Describes what layers the body will scan for collisions.

Example: GUI Example
--------------------

Create a GUI with the following node types:

*   Walls (layer 1)
*   Player (layer 2)
*   Enemy (layer 3)
*   Coin (layer 4)

Assign layers to each node type and configure collision masks and layers as needed.
