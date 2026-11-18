# Performance — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/optimization/index.html
- **Fetched**: 2026-11-18T03:06:26

**Godot Engine Performance Optimization**
=====================================

**Introduction**
---------------

Godot Engine follows a balanced performance philosophy, which means making tradeoffs between speed, usability, and flexibility. This section aims to help you get the maximum performance out of Godot Engine.

**Principles**
-------------

*   Godot prioritizes balance and flexibility over performance.
*   Game engines strive to be general-purpose, which requires balanced algorithms.

**General Optimization Tips**
-----------------------------

1.  **Optimization using Servers**: Using servers can improve performance by reducing the load on the client-side.
2.  **CPU Optimization**: Optimize CPU performance by using:
    *   **Caching**: Use caching to reduce the number of times the CPU needs to access data.
    *   **Multithreading**: Use multiple threads to take advantage of multi-core processors.
3.  **GPU Optimization**: Optimize GPU performance by:
    *   **Reducing stutter from shader (pipeline) compilations**: Use techniques like caching and multi-threading to reduce the time spent compiling shaders.
4.  **Optimization using MultiMeshes**: Use multiMeshes to reduce the number of draws and improve performance.
5.  **Reducing stutter from shader (pipeline) compilations**: Use techniques like caching and multi-threading to reduce the time spent compiling shaders.
6.  **3D Performance Optimization**: Optimize 3D performance by:
    *   **Animating thousands of objects**: Use techniques like batching and level of detail (LOD) to reduce the number of objects being animated.
7.  **Threads**: Use multiple threads to take advantage of multi-core processors.
8.  **Thread-safe APIs**: Use thread-safe APIs to ensure that your code can be safely executed in multiple threads.

**APIs and Examples**
--------------------

*   For CPU optimization, use the `Engine::get_thread_count()` function to get the number of threads available.
*   For GPU optimization, use the `GL` class to access GPU-specific functions.
*   For 3D performance optimization, use the `Mesh` class to optimize mesh data.
*   For multi-threading, use the `Thread` class to create and manage threads.

**Example Code**
----------------

```gdscript
# CPU Optimization
func _process(delta):
    # Get the number of threads available
    var thread_count = Engine.get_thread_count()
    print("Thread count:", thread_count)

# GPU Optimization
func _process(delta):
    # Get the GPU device
    var gpu = GL.get_current_device()
    print("GPU device:", gpu.name)

# 3D Performance Optimization
func _process(delta):
    # Create a new mesh
    var mesh = Mesh.new()
    mesh.add_surface(0, [Vector2(0, 0), Vector2(1, 0)])
    print("Mesh created:", mesh)

# Multi-Threaded Code
func _process(delta):
    # Create a new thread
    var thread = Thread.new()
    thread.add_task(self._thread_function)
    thread.start()
```

Note: This is not an exhaustive list of optimization techniques and APIs. For more information, please refer to the official Godot Engine documentation.
