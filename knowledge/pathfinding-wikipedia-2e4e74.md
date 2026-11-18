# Pathfinding - Wikipedia

- **Source**: https://en.wikipedia.org/wiki/Pathfinding
- **Fetched**: 2026-11-18T03:12:32

**Pathfinding**
================

### Overview

Pathfinding is the search for the shortest route between two points in a graph or network. It is a fundamental problem in computer science and has numerous applications in fields such as computer graphics, video games, and logistics.

### Algorithms

#### Basic Algorithms

*   Breadth-First Search (BFS): exhausts all possibilities by iterating over all potential paths until a destination node is reached.
*   Depth-First Search (DFS): exhausts all possibilities by exploring as far as possible along each branch before backtracking.

#### Optimal Path Algorithms

*   Bellman-Ford Algorithm: exhaustive approach that examines all possible paths to find the optimal one, with a time complexity of O(V \* E).
*   Dijkstra's Algorithm: uses heuristics or dynamic programming to eliminate impossible paths, achieving a time complexity of O(E \* log(V)).
*   A\* Algorithm: uses a heuristic function to guide the search, eliminating longer paths and achieving a time complexity of O(E \* log(V)).

#### Contraction Hierarchies

*   A more advanced algorithm that can pre-process the graph to achieve better performance.

#### Heuristics

*   Heuristic functions are used to estimate the distance between a node and the finish point.
*   A* algorithm uses these heuristic functions to eliminate longer paths and achieve faster performance.

### Key Concepts

*   **Graph**: a set of nodes and edges that represent a network or graph structure.
*   **Weighted Edge**: an edge with a numerical value representing its weight or cost.
*   **Vertex**: a node in the graph.

### Code Examples

*   Dijkstra's Algorithm:
    ```python
import heapq

def dijkstra(graph, start):
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    open_set = [start]

    while open_set:
        current_node = heapq.heappop(open_set)
        for neighbor, weight in graph[current_node].items():
            distance = distances[current_node] + weight
            if distance < distances[neighbor]:
                distances[neighbor] = distance
                heapq.heappush(open_set, neighbor)

    return distances
```

*   A\* Algorithm:
    ```python
import heapq

def a_star(graph, start, finish, heuristic):
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    open_set = [start]

    while open_set:
        current_node = heapq.heappop(open_set)
        for neighbor, weight in graph[current_node].items():
            distance = distances[current_node] + weight
            estimated_distance = distance + heuristic(neighbor, finish)
            if estimated_distance < distances[neighbor]:
                distances[neighbor] = estimated_distance
                heapq.heappush(open_set, neighbor)

    return distances
```

Note: These code examples are simplified and may not be suitable for production use.
