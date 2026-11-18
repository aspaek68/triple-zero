# Navigation — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/navigation/index.html
- **Fetched**: 2026-11-18T03:03:36

Navigation in Godot Engine
==========================

Navigation is a crucial feature in Godot Engine that enables characters and agents to navigate through the game world. It provides a flexible and extensible way to manage navigation, allowing developers to create complex and realistic navigation systems.

### Navigation Overviews

*   **2D Navigation**: Used for 2D games and projects that require navigation in a flat plane.
*   **3D Navigation**: Used for 3D games and projects that require navigation in a three-dimensional space.

### Navigation Components

#### NavigationServer

A top-level node that manages navigation for all navigation regions in a node tree.

#### NavigationMaps

Represents a map that contains navigation data, such as obstacles and regions.

#### NavigationRegions

A region that contains navigation data, such as obstacles and points of interest.

#### NavigationMeshes

A collection of navigation data points that form a mesh, used to define the navigation space.

#### NavigationPaths

A path that connects two navigation data points, used to define a route between two points.

#### NavigationPathQueryObjects

Used to query navigation data, such as finding the shortest path between two points.

#### NavigationAgents

Represents an agent that uses navigation to move around the game world.

#### NavigationObstacles

Represents an obstacle that blocks the navigation path.

#### NavigationLinks

Represents a link between two navigation data points, used to define a connection between two points.

#### NavigationLayers

A layer that contains navigation data, such as obstacles and regions.

### Navigation Debug Tools

Godot provides several debug tools for navigation, including:

*   **Navigation debug visualizer**: A visual tool that displays navigation data in the scene tree.
*   **Navigation debug map**: A tool that displays navigation data on a map.

### Best Practices

#### Connecting Navigation Meshes

To connect navigation meshes, use the `connect` function on the `NavigationMesh` node.

#### Supporting Different Actor Types

Use the `set_affected_types` function on the `Navigation` node to support different actor types.

#### Supporting Different Actor Locomotion

Use the `set_locomotion` function on the `Navigation` node to support different actor locomotion.

#### Optimizing Navigation Performance

Use the following tips to optimize navigation performance:

*   Use caching to reduce the number of calculations.
*   Use spatial partitioning to reduce the number of queries.
*   Use optimization techniques, such as raycasting, to reduce the number of calculations.

Example Code
------------

```gdscript
extends NavigationServer

func _ready():
    # Create a new navigation map
    var navigation_map = NavigationMap.new()
    navigation_map.add_obstacle(Vector2(0, 0), Vector2(0, 1))
    navigation_map.add_region(Vector2(0, 1), Vector2(1, 1))
    add_map(navigation_map)
```

This code creates a new navigation map and adds an obstacle and a region to it. The `add_map` function is then called to add the map to the navigation server.
