# Godot physics engine tutorial

- **Source**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- **Fetched**: 2026-11-17T21:23:32

**Godot Physics Engine Tutorial**
=====================================

**Introduction**
---------------

In game development, collision detection and response are crucial for creating realistic interactions between game objects. Godot's physics engine provides a robust solution for handling collisions, but understanding its mechanics and APIs is essential for effective use.

**Collision Objects**
---------------------

Godot offers four types of collision objects:

1. **Area2D**: Provides detection and influence. Can detect overlap and emit signals when bodies enter or exit. Can override physics properties, such as gravity or damping, in a defined area.
2. **StaticBody2D**: Participates in collision detection but does not move in response to the collision. Often used for environment objects or objects without dynamic behavior.
3. **RigidBody2D**: Implements simulated 2D physics. Forces and impulses are applied to the body, and the physics engine calculates the resulting movement.
4. **CharacterBody2D**: Provides collision detection but no physics. Movement and collision response must be implemented in code.

**Physics Material**
--------------------

Static bodies and rigid bodies can be configured to use a **PhysicsMaterial**, which allows adjusting friction, bounce, absorbency, and roughness.

**Collision Shapes**
-------------------

Physics bodies can hold multiple **Shape2D** objects as children. These shapes define the object's collision bounds and detect contact with other objects. Important: never scale collision shapes in the editor; use size handles instead.

**Physics Process Callback**
---------------------------

The physics engine runs at a fixed rate (60 iterations per second). All physics-related code must run at this fixed rate. Godot provides two callbacks:

1. **Node._physics_process()**: Called before each physics step. Use `delta` parameter for physics calculations.
2. **Node._process()**: Called on each frame (idle processing). Not recommended for physics-related code.

**Collision Layers and Masks**
---------------------------

Collision layers and masks allow complex interactions between objects. Each **CollisionObject2D** has 32 physics layers and can interact with multiple layers. Configure layers and masks via code or the Inspector.

**Example**
-----------

Create a game with four node types: Walls, Player, Enemy, and Coin. Set up layers and masks to achieve the desired collision behavior. Use **Area2D** and **RigidBody2D** for detection and response.
