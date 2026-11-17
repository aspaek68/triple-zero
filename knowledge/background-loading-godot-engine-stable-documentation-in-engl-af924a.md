# Background loading — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html
- **Fetched**: 2026-11-17T20:48:51

**Background Loading in Godot Engine**
=====================================

Background loading allows you to load resources asynchronously, making your game appear responsive even when loading large resources. This can be useful for loading scenes, textures, audio files, and more during gameplay.

**How it Works**
----------------

*   Use `ResourceLoader.load_threaded_request` to queue a request to load a resource for a given path.
*   Check the status using `ResourceLoader.load_threaded_get_status`.
*   Obtain progress using an array variable passed to `load_threaded_get`, which returns a one-element array containing the percentage.
*   Retrieve loaded resources by calling `load_threaded_get`.

**Example**
------------

```gdscript
const ENEMY_SCENE_PATH = "Enemy.tscn"

func _ready():
    ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
    self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
    # Button was pressed.
    # Obtain the resource now that we need it.
    var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)
    # Instantiate the enemy scene and add it to the current scene.
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
```

```csharp
private const string EnemyScenePath = "Enemy.tscn";

public partial class MyButton : Button
{
    private const string EnemyScenePath = "Enemy.tscn";

    public override void _Ready()
    {
        ResourceLoader.LoadThreadedRequest(EnemyScenePath);
        Pressed += OnButtonPressed;
    }

    private void OnButtonPressed()
    {
        // Button was pressed.
        // Obtain the resource now that we need it.
        var enemyScene = (PackedScene)ResourceLoader.LoadThreadedGet(EnemyScenePath);
        // Instantiate the enemy scene and add it to the current scene.
        var enemy = enemyScene.Instantiate();
        AddChild(enemy);
    }
}
```

**Best Practices**
------------------

*   Use `load_threaded_request` to queue requests for resources, allowing them to load in the background.
*   Check the status of the load using `load_threaded_get_status`.
*   Obtain progress using an array variable passed to `load_threaded_get`.
*   Ensure there is enough time between requesting the load and retrieving the resource to avoid blocking.
