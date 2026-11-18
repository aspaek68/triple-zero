# Performance — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/performance/index.html
- **Fetched**: 2026-11-18T03:03:06

**Performance Optimization in Godot Engine**
=============================================

**Introduction**
---------------

Godot Engine follows a balanced performance philosophy, where tradeoffs are made between speed, usability, and flexibility. This documentation will guide you on how to get the maximum performance out of Godot Engine.

**General Optimization Tips**
---------------------------

### Optimization using Servers

*   Use a server for rendering large scenes or objects to reduce the load on the client's machine.

### CPU Optimization

*   Optimize CPU performance by:
    *   Minimizing unnecessary computations
    *   Using multi-threading to take advantage of multiple CPU cores
    *   Using thread-safe APIs

### GPU Optimization

*   Optimize GPU performance by:
    *   Minimizing unnecessary GPU computations
    *   Using multi-threading to take advantage of multiple GPU cores
    *   Using GPU-specific features like multi-threading and multi-threading

### Optimization using MultiMeshes

*   Reduce stutter from shader (pipeline) compilations by:
    *   Batching multiple objects together
    *   Reducing the number of shader changes

### 3D Performance Optimization

*   Optimize 3D performance by:
    *   Minimizing unnecessary 3D computations
    *   Using multi-threading to take advantage of multiple CPU cores
    *   Reducing the number of physics objects

### Animating Thousands of Objects

*   Optimize animating thousands of objects by:
    *   Using multi-threading to take advantage of multiple CPU cores
    *   Reducing the number of animation objects

### Using Multiple Threads

*   Use multiple threads to:
    *   Take advantage of multiple CPU cores
    *   Improve performance in CPU-bound tasks

### Thread-Safe APIs

*   Use thread-safe APIs to:
    *   Ensure safe access to shared resources
    *   Improve performance in multi-threaded applications

**APIs and Examples**
--------------------

### CPU Optimization APIs

*   `Thread` API: Used to create and manage threads.
*   `Task` API: Used to schedule tasks for execution.

### GPU Optimization APIs

*   `Mesh` API: Used to create and manage meshes.
*   `Shader` API: Used to create and manage shaders.

### MultiMesh Optimization APIs

*   `MultiMesh` API: Used to create and manage multi-meshes.

### 3D Physics Optimization APIs

*   `Physics` API: Used to create and manage physics objects.

### Animating Thousands of Objects APIs

*   `AnimationPlayer` API: Used to create and manage animation players.

### Using Multiple Threads APIs

*   `Thread` API: Used to create and manage threads.
*   `Task` API: Used to schedule tasks for execution.

**Example Code**
-------------

```gdscript
// CPU Optimization Example
func _process(delta):
    for i in range(10000):
        # Perform CPU-intensive computation
        pass

// GPU Optimization Example
func _process(delta):
    var mesh = Mesh.new()
    mesh.add_vertex(Vector3(0, 0, 0))
    mesh.add_vertex(Vector3(1, 0, 0))

    # Use GPU-specific features
    var shader = Shader.new()
    shader.compile()

    # Use multi-threading to take advantage of multiple GPU cores
    var thread = Thread.new()
    thread.call_func(self, "_gpu_thread", [mesh, shader])

func _gpu_thread(mesh, shader):
    # Perform GPU-intensive computation
    pass

// MultiMesh Optimization Example
func _process(delta):
    var multi_mesh = MultiMesh.new()
    multi_mesh.add_mesh(Mesh.new())
    multi_mesh.add_mesh(Mesh.new())

    # Batching multiple objects together
    multi_mesh.add_vertex(Vector3(0, 0, 0))
    multi_mesh.add_vertex(Vector3(1, 0, 0))

    # Reducing stutter from shader (pipeline) compilations
    var shader = Shader.new()
    shader.compile()

    # Using multi-threading to take advantage of multiple GPU cores
    var thread = Thread.new()
    thread.call_func(self, "_gpu_thread", [multi_mesh, shader])

func _gpu_thread(multi_mesh, shader):
    # Perform GPU-intensive computation
    pass
```

Note: This is a summary of the provided text and may not cover all the topics and examples.
