# Pathfinding - Wikipedia

- **Source**: https://en.wikipedia.org/wiki/Pathfinding
- **Fetched**: 2026-11-18T14:28:30

**Pathfinding**
================

**Definition**
---------------

Pathfinding, also known as pathing, is the search for the shortest route between two points in a graph or network.

**Algorithms**
----------------

### Basic Algorithms

*   **Breadth-First Search (BFS)**: Explores all possible paths from the start node until the destination node is reached.
*   **Depth-First Search (DFS)**: Explores as far as possible along each branch before backtracking.

### Optimal Algorithms

*   **Bellman-Ford Algorithm**: Exhaustively searches all possible paths to find the optimal shortest path.
*   **Dijkstra's Algorithm**: Eliminates impossible paths using heuristics or dynamic programming.
*   **A\* (A-Star) Algorithm**: Uses a heuristic function to eliminate longer paths and improve performance.

### Time Complexity

*   BFS: O(|V| + |E|) = linear time
*   DFS: O(|V| + |E|) = linear time
*   Bellman-Ford Algorithm: O(|V| \* |E|) = quadratic time
*   Dijkstra's Algorithm: O(|E| \* log|V|) = O(|E| \* log|V|)
*   A\* Algorithm: O(|E| \* log|V|) = O(|E| \* log|V|)

**Example Use Cases**

*   **Travel-Routing Systems**: Dijkstra's Algorithm and A\* Algorithm are commonly used to find the shortest route between two points.
*   **Video Games**: A\* Algorithm is often used to find the shortest path between two points in a game environment.

**APIs and Implementations**

*   **Python**: `networkx`, `dijkstra`, and `a*` libraries
*   **Java**: `Graph`, `Dijkstra`, and `AStar` classes
*   **C++**: `Graph`, `Dijkstra`, and `AStar` functions

**Heuristics**

*   **Manhattan Distance**: Calculates the sum of the horizontal and vertical distances between two points.
*   **Euclidean Distance**: Calculates the straight-line distance between two points.
*   **Diagonal Distance**: Calculates the distance between two points in a diagonal direction.

Note: This is a concise summary of the key concepts and algorithms related to pathfinding. For more information, please refer to the original text or other reliable sources.
