# Background loading — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html
- **Fetched**: 2026-11-18T03:08:06

**Background Loading in Godot Engine**
=====================================

Background loading allows you to load resources asynchronously, improving the responsiveness of your game. This feature is particularly useful when loading resources during gameplay or when switching between scenes.

**Using ResourceLoader for Asynchronous Loading**
---------------------------------------------------

You can use the `ResourceLoader` class to load resources asynchronously in background threads. Here's an overview of the process:

1.  **Queue a request**: Use `ResourceLoader.load_threaded_request` to queue a request to load a resource for a specific path.
2.  **Check the status**: Use `ResourceLoader.load_threaded_get_status` to check the status of the loaded resource.
3.  **Get the resource**: Use `ResourceLoader.load_threaded_get` to retrieve the loaded resource.

**Example Code**
----------------

Here's an example that demonstrates how to load a scene in the background:

```gdscript
const ENEMY_SCENE_PATH = "Enemy.tscn"

func _ready():
    ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
    pressed.connect(_on_button_pressed)

func _on_button_pressed():
    var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
```

In this example, the `_ready` function starts a request to load the enemy scene and connects the `_on_button_pressed` function to the `pressed` signal. When the button is pressed, the `_on_button_pressed` function retrieves the loaded resource and instantiates the enemy scene.

**Best Practices**
------------------

To ensure that background loading doesn't block, you should:

*   Ensure there's enough time between requesting the load and retrieving the resource.
*   Check the status of the loaded resource manually.

By using background loading, you can improve the responsiveness of your game and provide a better user experience.
