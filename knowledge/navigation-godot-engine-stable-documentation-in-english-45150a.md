# Navigation — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/navigation/index.html
- **Fetched**: 2026-11-17T20:38:21

**Navigation in Godot Engine**
================================

Navigation is a system in Godot Engine that enables efficient navigation and collision detection for 2D and 3D scenes. It provides a range of features and tools to support navigation in different scenarios.

**Key Concepts**
----------------

### Navigation Types

* **2D Navigation**: Used for 2D scenes with colliders.
* **3D Navigation**: Used for 3D scenes with colliders.

### Navigation Server

* A central node that manages navigation data and queries.

### Navigation Maps

* A data structure that stores navigation information for a specific map.

### Navigation Regions

* A way to define areas in a scene where navigation is enabled.

### Navigation Meshes

* A mesh-based representation of navigation data.

### Navigation Paths

* A data structure that stores navigation information for a specific path.

### Navigation Path Query Objects

* Used to query navigation data along a specific path.

### Navigation Agents

* Entities that use navigation data to move around in a scene.

### Navigation Obstacles

* Used to prevent navigation agents from passing through certain areas.

### Navigation Links

* Used to connect navigation meshes and regions.

### Navigation Layers

* A way to organize navigation data into layers.

**APIs and Examples**
--------------------

### Navigation APIs

* `NavigationServer`: Manages navigation data and queries.
* `NavigationMap`: Stores navigation information for a specific map.
* `NavigationRegion`: Defines areas in a scene where navigation is enabled.
* `NavigationMesh`: A mesh-based representation of navigation data.

### Example Use Cases

* Use `NavigationServer` to manage navigation data and queries.
* Use `NavigationMap` to store navigation information for a specific map.
* Use `NavigationRegion` to define areas in a scene where navigation is enabled.
* Use `NavigationMesh` to create a mesh-based representation of navigation data.

**Optimizing Navigation Performance**
-------------------------------------

* Use `NavigationLayers` to organize navigation data into layers.
* Use `NavigationObstacles` to prevent navigation agents from passing through certain areas.
* Use `NavigationPaths` to store navigation information for a specific path.
