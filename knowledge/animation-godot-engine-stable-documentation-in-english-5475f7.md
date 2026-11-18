# Animation — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/animation/index.html
- **Fetched**: 2026-11-18T14:21:54

# Animation in Godot Engine
=====================================

## Overview
------------

This section of the Godot Engine documentation covers the basics of animation, including animation track types, cutout animation, 2D skeletons, and more.

## Animation Track Types
-------------------------

*   **Cutout Animation**: A type of animation where the object is replaced with a new texture frame for each animation frame.
*   **2D Skeletons**: Used for 2D animations, allowing for more complex movements and interactions.

## Using AnimationTree
---------------------

*   The AnimationTree is a visual representation of the animation.
*   It allows for easy creation and editing of animations.

## Playing Videos
-----------------

*   Godot supports playing videos as animations.
*   This can be used for creating movie-like animations.

## Creating Movies
-----------------

*   Godot's animation system allows for creating movies.
*   This can be useful for creating complex animations or for using the animations in other projects.

## Importing 3D Scenes
----------------------

*   For information on importing animations from a 3D model, please see the [Importing 3D Scenes](https://docs.godotengine.org/en/stable/tutorials/animation/3d_animation.html) tutorial.

## APIs
-----

*   `AnimationTree`: The AnimationTree API allows for creating and editing animations programmatically.
*   `Animation`: The Animation API allows for playing and controlling animations.

## Examples
-----------

### Example 1: Creating a Cutout Animation

```gdscript
var animation = Animation.new()
animation.add_animation("animation", 0, 1, Vector2(10, 10), Vector2(20, 20))
animation.add_animation("animation", 1, 2, Vector2(10, 20), Vector2(20, 30))
animation.add_animation("animation", 2, 3, Vector2(10, 30), Vector2(20, 40))
```

### Example 2: Playing a Video

```gdscript
var video = VideoPlayer.new()
video.play("path/to/video")
```

### Example 3: Creating a Movie

```gdscript
var animation = Animation.new()
animation.add_animation("animation", 0, 1, Vector2(10, 10), Vector2(20, 20))
animation.add_animation("animation", 1, 2, Vector2(10, 20), Vector2(20, 30))
animation.add_animation("animation", 2, 3, Vector2(10, 30), Vector2(20, 40))
var movie = MoviePlayer.new()
movie.add_animation("animation")
movie.play("path/to/movie")
```

Note: The code examples provided are in GDScript, the primary scripting language used in Godot Engine.
