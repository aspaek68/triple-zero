# Godot particle editor

- **Source**: https://godotengine.org/asset-library/asset/3352
- **Fetched**: 2026-11-18T17:09:59

**Godot Particle Editor Plugin**
================================

**Overview**
------------

The Godot Particle Editor Plugin is a tool that enhances the particle scene compositor in Godot, providing a more intuitive and efficient way to create and manage particle scenes.

**Key Features**
----------------

*   **Particle Control Panel**: A quality-of-life feature that provides a centralized control panel for all particle nodes in the editor.
*   **SyncNode Runtime Nodes**: A new type of runtime node that can play and restart all child particle nodes in a synchronized manner. This feature is available for both GPU and CPU particles, as well as 2D and 3D.
*   **SyncNode Variants**: The plugin provides SyncNode variants for both GDScript and C# languages.
*   **Stand-alone Components**: Each component of the plugin works fully stand-alone, allowing for flexible installation and configuration.

**API Documentation**
---------------------

### SyncNode

*   **SyncNode(Gpu/ Cpu, 2D/3D)**: Creates a new SyncNode instance for the specified particle type and dimension.
*   **autoplay()**: Starts the autoplay behavior of the SyncNode.
*   **play()**: Plays the SyncNode from the beginning.
*   **restart()**: Restarts the SyncNode.

**Example Use Case**
---------------------

```gdscript
var sync_node = SyncNode.new("gpu", "2d")
sync_node.autoplay()
sync_node.play()
```

This example creates a new SyncNode instance for a GPU-based 2D particle system, starts the autoplay behavior, and plays the system from the beginning.

**Installation**
----------------

The plugin can be installed by following these steps:

1.  Open the Godot Editor and navigate to the "Assets" tab.
2.  Click on the "Library" button and search for the "Godot Particle Editor Plugin".
3.  Click on the "Install" button to install the plugin.
4.  A popup will appear asking which components to keep and which to omit. Select the desired components and click "Install".
