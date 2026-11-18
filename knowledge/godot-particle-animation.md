# Godot particle animation

- **Source**: https://shaggydev.com/2021/09/15/particle-spritesheets/
- **Fetched**: 2026-11-18T17:11:22

**Godot Particle Animation**
==========================

**Overview**
------------

Godot's particle animation feature allows for animated spritesheets to be used in 2D particles. This note summarizes the steps to create a basic particle animation using spritesheets.

**Step 1: Add Particle Node and Configure**
-------------------------------------------

*   Add a `Particles2D` node (or `CPUParticles2D` if using GLES2) to your scene.
*   Configure the particle emission shape, gravity, and other settings as desired.

**Step 2: Add Spritesheet as Texture**
-------------------------------------

*   Add the spritesheet as a texture under `Textures`.
*   This should display the entire spritesheet being used as a particle.

**Step 3: Configure Particle Animation**
--------------------------------------

*   Add a new `CanvasItemMaterial` under `Materials`.
*   Check `Particles Animation`.
*   Configure the following settings:
    *   `Particles Anim H Frames`: The number of frames horizontally in the image (in this case, 4).
    *   `Particles Anim V Frames`: The number of frames vertically in the image (in this case, 1).
    *   `Particles Anim Loop`: Whether the animation loops (not checked in this example).
*   The animation should now only use the first frame of the spritesheet.

**Step 4: Configure Animation Playback**
--------------------------------------

*   Go back to the `Particle Material` and configure the animation playback under the `Animation` tab.
*   The unit of speed for animation playback appears to be the number of times the animation should play over the particles' lifetime.
*   Set the playback speed to 1, as shown below, to play the animation once before the particle is destroyed.

**Example Code**
```gdscript
extends Particle2D

func _ready():
    # Set particle animation configuration
    var material = get_material()
    material.set_particles_animation(
        "my_animation",
        4,  # Horizontal frames
        1,  # Vertical frames
        false  # Loop
    )

    # Configure animation playback
    var animation = material.get_animation("my_animation")
    animation.set_playback_speed(1)
```
This code sets up a basic particle animation using a spritesheet and custom animation configuration.
