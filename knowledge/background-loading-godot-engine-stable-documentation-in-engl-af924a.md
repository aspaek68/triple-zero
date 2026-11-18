# Background loading — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html
- **Fetched**: 2026-11-18T14:24:29

**Background Loading in Godot Engine**
=====================================

Background loading is a technique used to load resources asynchronously in the background, allowing for a responsive game experience. This is particularly useful when switching between scenes or loading additional resources during gameplay.

**Using ResourceLoader for Background Loading**
------------------------------------------------

To use `ResourceLoader` for background loading, you can queue requests to load resources for a path using `load_threaded_request`. This will load the resources in threads in the background.

**APIs and Methods**
--------------------

* `load_threaded_request(path)`: Queues a request to load a resource for the specified path.
* `load_threaded_get_status()`: Returns the status of a loaded resource.
* `load_threaded_get(path)`: Retrieves a loaded resource.

**Example Code**
----------------

```gdscript
# GDScript example
const ENEMY_SCENE_PATH = "Enemy.tscn"
func _ready():
    ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
    pressed.connect(_on_button_pressed)

func _on_button_pressed():
    var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
```

```csharp
// C# example
partial class MyButton : Button
{
    private const string EnemyScenePath = "Enemy.tscn";

    private void _Ready()
    {
        ResourceLoader.LoadThreadedRequest(EnemyScenePath);
        Pressed += OnButtonPressed;
    }

    private void OnButtonPressed()
    {
        var enemyScene = (PackedScene)ResourceLoader.LoadThreadedGet(EnemyScenePath);
        var enemy = enemyScene.Instantiate();
        AddChild(enemy);
    }
}
```

**Best Practices**
------------------

* Ensure there is enough time between requesting the load and retrieving the resource to avoid blocking.
* Check the status manually if you need to guarantee that the load does not block.
* Use `load_threaded_get` to retrieve the loaded resource, as it returns instantly if the resource has finished loading in the background.
