# Animation — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/animation/index.html
- **Fetched**: 2026-11-17T20:41:25

# Animation in Godot Engine
=====================================================

## Overview

The Godot Engine provides a robust animation system, allowing for flexible and customizable animation control. This section of the tutorial covers the basics of animation in Godot, including animation track types, cutout animation, 2D skeletons, and using the AnimationTree.

## Animation Track Types
-------------------------

Godot supports several animation track types, including:

* Cutout animation: used for sprite animations
* 2D skeletons: used for character animations

## Cutout Animation
-----------------

Cutout animation is used for sprite animations. It involves creating a set of sprite sheets for each animation frame, and then using the `AnimationPlayer` to play back these sprite sheets in sequence.

### Example:

```gdscript
// Create an AnimationPlayer
var animation_player = AnimationPlayer.new()

// Set the animation to play
animation_player.play("animation_name")
```

## 2D Skeletons
----------------

2D skeletons are used for character animations. They allow for more complex animations and are used in conjunction with the `AnimationTree` node.

### Example:

```gdscript
// Create an AnimationTree
var animation_tree = AnimationTree.new()

// Set the skeleton to use
animation_tree.set_skeleton("skeleton_name")
```

## Using AnimationTree
---------------------

The AnimationTree node is used to control 2D skeletons. It allows for more complex animations and is used in conjunction with the `AnimationPlayer` node.

### Example:

```gdscript
// Create an AnimationPlayer
var animation_player = AnimationPlayer.new()

// Create an AnimationTree
var animation_tree = AnimationTree.new()

// Set the skeleton to use
animation_tree.set_skeleton("skeleton_name")

// Set the animation to play
animation_player.play("animation_name")
```

## Playing Videos
-----------------

Godot also supports playing videos as animations. This can be done using the `VideoPlayer` node.

### Example:

```gdscript
// Create a VideoPlayer
var video_player = VideoPlayer.new()

// Load the video
video_player.load("video_file")
```

## Creating Movies
------------------

Godot also supports creating movies as animations. This can be done using the `MoviePlayer` node.

### Example:

```gdscript
// Create a MoviePlayer
var movie_player = MoviePlayer.new()

// Load the movie
movie_player.load("movie_file")
```

## Importing 3D Scenes
----------------------

For information on importing animations from a 3D model, see [Importing 3D scenes](https://example.com/).
