# godot environment postfx

- **Source**: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- **Fetched**: 2026-11-17T17:09:17

Godot Engine 4.7 documentation in English
Environment and post-processing
Edit on GitHub
Learn how to contribute!
Environment and post-processing
Godot 4 provides a redesigned Environment resource, as well as a new
Note
As of Godot 4, Environment
Note that most Environment performance/quality settings are only visible
Advanced
Environment
The
Environment
Camera3D node (high priority)
An Environment can be set to a Camera3D node. It will have priority over any
This is mostly useful when you want to override an existing environment,
WorldEnvironment node (medium priority, recommended)
The WorldEnvironment node can be added to any scene, but only one can exist per
Any Environment added has higher priority than the default Environment
Preview environment and sun (low priority)

---

Environment and post-processing — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
3D
Environment and post-processing
Edit on GitHub
Learn how to contribute!
Environment and post-processing

Godot 4 provides a redesigned Environment resource, as well as a new
post-processing system with many available effects right out of the box.
Note
As of Godot 4, Environment
performance/quality
settings are defined in the
project settings instead of in the Environment resource. This makes global
adjustments easier, as you no longer have to tweak Environment resources
individually to suit various hardware configurations.
Note that most Environment performance/quality settings are only visible
after enabling the
Advanced
toggle in the Project Settings.
Environment

The
Environment
resource stores all the information required for
controlling the 2D and 3D rendering environment. This includes the sky, ambient
lighting, tone mapping, effects, and adjustments. By itself, it does nothing,
but you can enable it by using it in one of the following locations, in order
of priority:
Camera3D node (high priority)

An Environment can be set to a Camera3D node. It will have priority over any
other setting.
This is mostly useful when you want to override an existing environment,
but in general it's a better idea to use the option below.
WorldEnvironment node (medium priority, recommended)

The WorldEnvironment node can be added to any scene, but only one can exist per
active scene tree. Adding more than one will result in a warning.
Any Environment added has higher priority than the default Environment
(explained below). This means it can be overridden on a per-scene basis,
which makes it quite useful.
Preview environment and sun (low priority)

Note
Since Godot 4, the preview environment and sun system replace the
default_env.tres
file that was used in Godot 3 projects.
If no WorldEnvironment node or DirectionalLight3D node is present in the current

[... truncated ...]
