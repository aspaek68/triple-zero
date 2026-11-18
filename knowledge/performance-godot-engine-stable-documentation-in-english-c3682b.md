# Performance — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/optimization/index.html
- **Fetched**: 2026-11-18T14:22:52

**Performance Optimization in Godot Engine**
=====================================================

**Introduction**
---------------

Godot Engine follows a balanced performance philosophy, which means there are tradeoffs between speed, usability, and flexibility. This section aims to help you get the maximum performance out of Godot Engine.

**Performance Principles**
-------------------------

*   Godot prioritizes balance and flexibility over performance.
*   Game engines strive to be general-purpose, which means using balanced algorithms.

**General Optimization Tips**
-----------------------------

*   Start with the [General optimization tips](#general-optimization-tips) section.

**Optimization Strategies**
---------------------------

### CPU Optimization

*   [CPU optimization](#cpu-optimization)
*   Use multi-threading to improve performance.

### GPU Optimization

*   [GPU optimization](#gpu-optimization)
*   Reduce stutter from shader (pipeline) compilations.

### MultiMeshes Optimization

*   [Optimization using MultiMeshes](#optimization-using-multimesh)
*   Use MultiMeshes to reduce rendering time.

### 3D Performance Optimization

*   [Optimizing 3D performance](#3d-performance-optimization)
*   Animate thousands of objects efficiently.
*   Use thread-safe APIs.

### Using Multiple Threads

*   Use multi-threading to improve performance.

### Thread-Safe APIs

*   Use thread-safe APIs to ensure safe and efficient multithreading.

**APIs and Examples**
---------------------

*   [ Godot's API documentation](https://godotengine.org/doc/current/reference/classref.html)

**Additional Resources**
-------------------------

*   [GitHub repository for Godot Engine](https://github.com/godotengine/godot)
*   [Godot Engine documentation](https://godotengine.org/doc/current/)
