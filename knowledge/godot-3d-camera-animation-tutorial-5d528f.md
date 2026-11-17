# Godot 3D camera animation tutorial

- **Source**: https://docs.godotengine.org/en/3.1/tutorials/3d/fps_tutorial/part_one.html
- **Fetched**: 2026-11-17T21:21:04

**Godot 3D Camera Animation Tutorial**
=====================================

**Part 1: Setting up the FPS Movement Logic**
---------------------------------------------

**Overview**
------------

In this part, we will create a first-person player that can move around the environment. By the end of this part, you will have a working first-person character who can:

* Move around the game environment
* Sprint
* Look around with a mouse-based first-person camera
* Jump into the air
* Turn on and off a flashlight

**Getting Started**
-----------------

1. Launch Godot and open the project included in the starter assets.
2. Open the project settings and go to the "Input Map" tab. You will find several actions have already been defined.
3. Open the `Player.tscn` scene.

**Setting up the Player**
-------------------------

1. Notice how the player's collision shapes are set up. We are adding a small square to the 'feet' of the player to prevent sliding on edges.
2. We are also using a `Rotation_Helper` node to rotate the player on the X-axis and the player node on the Y-axis.

**Creating the Player Script**
-----------------------------

1. Attach a new script to the `Player` node and call it `Player.gd`.
2. Add the following code to `Player.gd`:
```gdscript
extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5
var dir = Vector3()
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper
var MOUSE_SENSITIVITY = 0.05

func _ready():
    camera = $Rotation_Helper/Camera
    rotation_helper = $Rotation_Helper
```
**Next Steps**
---------------

In the next part, we will add the ability to look around with the mouse and jump.
