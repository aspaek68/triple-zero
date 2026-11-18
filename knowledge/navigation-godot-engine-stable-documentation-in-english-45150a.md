# Navigation — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/navigation/index.html
- **Fetched**: 2026-11-18T14:20:35

Navigation in Godot Engine
===========================

Overview
--------

Godot Engine provides a robust navigation system for 2D and 3D environments, enabling efficient pathfinding and obstacle avoidance. This document covers the various aspects of navigation in Godot, including the different types of navigation, APIs, and best practices.

2D Navigation Overview
---------------------

Godot provides a 2D navigation system that allows for efficient pathfinding and obstacle avoidance. The 2D navigation system is designed to handle large numbers of actors and obstacles.

3D Navigation Overview
---------------------

Godot also provides a 3D navigation system that allows for efficient pathfinding and obstacle avoidance in 3D environments. The 3D navigation system is designed to handle complex 3D scenes with multiple actors and obstacles.

Using NavigationServer
---------------------

The `NavigationServer` is a high-level API for navigation that allows for easy integration with other Godot features, such as `NavigationMaps`, `NavigationRegions`, and `NavigationAgents`.

Using NavigationMaps
--------------------

A `NavigationMap` is a 2D or 3D map that defines the layout of an environment. Navigation maps can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationRegions
----------------------

A `NavigationRegion` is a region of a navigation map that defines a specific area of interest. Navigation regions can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationMeshes
---------------------

A `NavigationMesh` is a 3D mesh that defines the layout of an environment. Navigation meshes can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationPaths
---------------------

A `NavigationPath` is a path that defines a specific route or route segment. Navigation paths can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationPathQueryObjects
---------------------------------

A `NavigationPathQueryObject` is an object that is used to query the navigation system for the shortest path between two points.

Using NavigationAgents
----------------------

A `NavigationAgent` is an agent that is used to navigate the environment. Navigation agents can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationObstacles
------------------------

A `NavigationObstacle` is an obstacle that is used to block navigation. Navigation obstacles can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationLinks
---------------------

A `NavigationLink` is a link that is used to connect two navigation regions. Navigation links can be used to optimize navigation performance and reduce the number of collisions.

Using NavigationLayers
---------------------

A `NavigationLayer` is a layer that is used to manage navigation data. Navigation layers can be used to optimize navigation performance and reduce the number of collisions.

Navigation Debug Tools
---------------------

Godot provides several debug tools for navigation, including:

*   `NavigationDebugNode`: a node that displays the navigation mesh.
*   `NavigationDebugPath`: a path that displays the shortest path between two points.

Connecting Navigation Meshes
---------------------------

Connecting navigation meshes can be done using the `NavigationMesh::connect` method.

Supporting Different Actor Types
------------------------------

Godot provides several APIs for supporting different actor types, including:

*   `NavigationAgent::add_actor`: a method that adds an actor to the navigation system.
*   `NavigationAgent::remove_actor`: a method that removes an actor from the navigation system.

Supporting Different Actor Locomotion
-----------------------------------

Godot provides several APIs for supporting different actor locomotion, including:

*   `NavigationAgent::set_locomotion`: a method that sets the locomotion of an actor.
*   `NavigationAgent::get_locomotion`: a method that gets the locomotion of an actor.

Supporting Different Actor Area Access
-------------------------------------

Godot provides several APIs for supporting different actor area access, including:

*   `NavigationAgent::set_area_access`: a method that sets the area access of an actor.
*   `NavigationAgent::get_area_access`: a method that gets the area access of an actor.

Optimizing Navigation Performance
----------------------------------

Godot provides several APIs for optimizing navigation performance, including:

*   `NavigationServer::optimize`: a method that optimizes the navigation system.
*   `NavigationAgent::optimize`: a method that optimizes the navigation agent.

Example Code
------------

Here is an example of how to use the `NavigationServer` API:
```gd
extends NavigationServer

func _ready():
    # Create a navigation map
    var map = NavigationMap.new()
    map.create_map()

    # Create a navigation server
    var server = NavigationServer.new()
    server.add_map(map)

    # Create a navigation agent
    var agent = NavigationAgent.new()
    agent.add_actor(map)

    # Optimize the navigation system
    server.optimize()
```
This code creates a navigation map, navigation server, and navigation agent, and then optimizes the navigation system.
