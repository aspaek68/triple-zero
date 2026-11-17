# Performance — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/optimization/index.html
- **Fetched**: 2026-11-17T20:44:16

Performance Optimization in Godot Engine
=====================================

**Introduction**
---------------

Godot Engine follows a balanced performance philosophy, prioritizing tradeoffs between speed, usability, and flexibility. This section aims to guide you on how to maximize performance in Godot.

**General Optimization Tips**
-----------------------------

*   Start with the [General optimization tips](#general-optimization-tips) section for a comprehensive overview.
*   Familiarize yourself with optimization using [Servers](#optimization-using-servers) and [MultiMeshes](#optimization-using-multimeshes).

**CPU Optimization**
------------------

*   [CPU optimization](#cpu-optimization) is crucial for improving performance in Godot.
*   Use multi-threading to utilize multiple CPU cores, as demonstrated in the [Threads](#threads) section.

**GPU Optimization**
------------------

*   [GPU optimization](#gpu-optimization) is essential for enhancing graphics performance in Godot.
*   Reduce stutter from shader (pipeline) compilations to improve overall rendering efficiency.

**Optimizing 3D Performance**
---------------------------

*   [Optimizing 3D performance](#optimizing-3d-performance) involves several techniques to improve rendering efficiency.
*   Animating thousands of objects requires careful planning and optimization.
*   Use thread-safe APIs to ensure safe and efficient multi-threading.

**Optimization using MultiMeshes**
---------------------------------

*   [Optimization using MultiMeshes](#optimization-using-multimeshes) can significantly improve performance.
*   Reduce the number of materials and objects in your scene to minimize rendering overhead.

**APIs and Examples**
---------------------

*   Use the following APIs for multi-threading and thread-safe programming:
    *   `Thread` API
    *   `Queue` API
*   Example use cases:
    *   Animating thousands of objects using multi-threading
    *   Optimizing 3D performance using MultiMeshes and GPU optimization

**Additional Resources**
----------------------

*   Consult the [Godot Engine documentation](https://docs.godotengine.org/en/stable/) for more information on performance optimization.
*   Explore the [GitHub repository](https://github.com/godotengine/godot) for contributed optimization scripts and examples.
