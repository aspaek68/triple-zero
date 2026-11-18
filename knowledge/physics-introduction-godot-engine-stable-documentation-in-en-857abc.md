# Physics introduction — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- **Fetched**: 2026-11-18T03:04:23

# Physics Introduction in Godot Engine
=====================================

Godot Engine provides a robust physics system for 2D and 3D game development. This guide introduces the four collision object types, physics material, collision shapes, and collision layers and masks.

## Collision Object Types
------------------------

Godot offers four collision object types that extend `CollisionObject2D`:

### Area2D

* Provides detection and influence
* Can detect when objects overlap and emit signals when bodies enter or exit
* Can override physics properties, such as gravity or damping, in a defined area

### StaticBody2D

* A static body that participates in collision detection but does not move in response to collisions
* Most often used for objects that are part of the environment or that do not need dynamic behavior

### RigidBody2D

* Implements simulated 2D physics
* You do not control a `RigidBody2D` directly, but instead apply forces (gravity, impulses, etc.) and let the physics engine calculate the resulting movement

### CharacterBody2D

* A body that provides collision detection but no physics
* All movement and collision response must be implemented in code

## Physics Material
------------------

Static bodies and rigid bodies can be configured to use a `PhysicsMaterial`. This allows adjusting the friction and bounce of an object, as well as setting if it's absorbent and/or rough.

## Collision Shapes
-----------------

A physics body can hold any number of `Shape2D` objects as children. These shapes are used to define the object's collision bounds and detect contact with other objects.

* The most common way to assign a shape is by adding a `CollisionShape2D` or `CollisionPolygon2D` as a child of the object
* Be careful to never scale your collision shapes in the editor; instead, use the size handles to change the size of the collision shape

## Physics Process Callback
-------------------------

The physics engine runs at a fixed rate (a default of 60 iterations per second). It is essential that all physics-related code runs at this fixed rate.

* Godot differentiates between physics and idle processing
* Code that runs each frame is called idle processing, while code that runs on each physics tick is called physics processing
* Godot provides two different callbacks: `Node._physics_process()` for physics processing and `Node._process()` for idle processing

## Collision Layers and Masks
---------------------------

One of the most powerful, but frequently misunderstood, collision features is the collision layer system.

* Each `CollisionObject2D` has 32 different physics layers it can interact with
* The `collision_layer` property describes the layers that the object appears in, while the `collision_mask` property describes what layers the body will scan for collisions
* These properties can be configured via code or by editing them in the Inspector
* Keeping track of what you're using each layer for can be difficult, so it's recommended to assign names to the layers you're using

## Example
---------

Create a simple game with four node types: Walls, Player, Enemy, and Coin. Use collision layers and masks to control the interactions between these objects.

* Name layers 1-4 "walls", "player", "enemies", and "coins" in the Project Settings > Layer Names > 2D Physics
* Place each node type in its respective layer using the "Layer" property
* Set the `collision_mask` property to allow collisions between Player and Walls, and Enemy and Walls
* Set the `collision_layer` property to allow collisions between Player and Enemy
