# Godot particle editor

- **Source**: https://github.com/tvenclovas96/particle-scene-compositor
- **Fetched**: 2026-11-18T17:10:41

**Godot Particle Editor**
==========================

**Overview**
------------

The Godot Particle Editor is a plugin that adds new nodes and editor tools to help create and use particle scenes in Godot 4.

**Features**
------------

* **Particle Control Panel**: A QoL feature that provides a controlled environment to preview and manage particle scenes.
* **SyncNode**: A lightweight runtime node that can play and restart all child particle nodes in a synchronized manner.
* **Stand-alone components**: Each component of the plugin is optional and can be installed separately.
* **SyncNode versions**: Available for both GPU and CPU particles, as well as 2D and 3D.

**APIs and Methods**
-------------------

* **SyncNode**:
	+ `start()`: Starts the particle emission.
	+ `stop()`: Stops the particle emission.
	+ `restart()`: Restart the particle emission.
	+ `loop_finished`: Signal emitted when the particle emission loop finishes.
	+ `finished`: Signal emitted when the particle emission finishes.
	+ `emitting`: Property that tracks the number of emitting particles.
	+ `time_elapsed`: Property that tracks the time elapsed.

**Usage**
----------

* **Editor**: The particle control panel will appear whenever a compatible node type is selected in the editor.
* **Copy Particle**: Copies the selected particle node, making the process material unique if necessary.
* **Play Once**: Immediately (re)starts particle emission of either all or only the selected particle node in the scene.
* **Autoplay**: Continuously replays particle emissions of either all or only the selected particle node in the scene.
* **Preprocess**: Sets the preprocess value of any particle nodes to be played to the set value.
* **Time-base autoplay**: Replays all/this node based on time, rather than the finished signals.

**Installation**
----------------

* Download directly from the Godot asset library: https://godotengine.org/asset-library/asset/3352
* Download the repository and copy the `addons` folder into your Godot project.

**Example Code**
----------------

```gdscript
var sync_node = SyncNode.new()
sync_node.start()
sync_node.stop()
```

```csharp
using Godot;

public class Example : Node2D
{
    public SyncNode sync_node;

    public void _Ready()
    {
        sync_node = (SyncNode)GetNode("SyncNode");
        sync_node.start();
    }

    public void _Process(float delta)
    {
        sync_node.stop();
    }
}
```
