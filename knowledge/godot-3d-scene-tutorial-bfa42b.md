# Godot 3D scene tutorial

- **Source**: https://docs.godotengine.org/en/4.6/tutorials/3d/introduction_to_3d.html
- **Fetched**: 2026-11-17T21:18:21

**Godot 3D Scene Tutorial**
==========================

### Introduction to 3D

Godot 3D scenes are edited in the 3D workspace, which can be selected manually or automatically when a `Node3D` node is selected. The 3D workspace is similar to the 2D workspace, with similar tabs and functionality.

### 3D Workspace

*   The 3D workspace can be selected manually or automatically when a `Node3D` node is selected.
*   The tabs below the workspace selector are used to change between currently opened scenes or create a new one using the plus (+) button.
*   The left and right docks are familiar from the editor introduction.
*   Below the scene selector, the main toolbar is visible, and beneath the main toolbar is the 3D viewport.

### Main Toolbar

*   The main toolbar has several buttons with default shortcuts:
    *   `Q`: Allows selection of nodes in the viewport. Left clicking on a node to select one, left clicking and dragging a rectangle selects all nodes within the rectangle's boundaries, once released.
    *   `W`: Enables move (or translate) mode for the selected nodes.
    *   `E`: Enables rotation mode for the selected nodes.
    *   `R`: Enables scaling and displays scaling gizmos in different axes for the selected nodes.
    *   `Ctrl + L`: Locks the selected nodes, preventing selection and movement in the viewport.
    *   `Ctrl + Shift + L`: Unlocks the selected nodes.
    *   `Ctrl + G`: Selects the root node if any of the children are selected.
    *   `M`: Enables Ruler Mode, which allows clicking and dragging to measure distance in the scene in meters.
    *   `T`: Enables Use Local Space, which draws gizmos using the current node's rotation angle instead of the global viewport axes.
    *   `Y`: Enables Use Snap, which snaps movement and rotation to grid. Snapping can also be temporarily activated using `Ctrl` while performing the action.

### Transform Menu

*   The Transform menu has three options:
    *   `Snap Object to Floor`: Snaps an object to a solid floor.
    *   `Transform Dialog`: Opens a dialog to adjust transform parameters (translate, rotate, scale, and transform) manually.
    *   `Snap Settings`: Allows you to change transform, rotate snap (in degrees), and scale snap (in percent) settings.

### View Menu

*   The View menu controls the view options and enables additional viewports:
    *   Shows/hides grids, which are set to 1x1 meter by default.
    *   Shows/hides the origin, where the blue, green, and red axis lines intersect.
    *   Toggles specific types of gizmos.

### View Menu of Viewport

*   The View menu of the viewport allows hiding all shown gizmos, as well as quick adjustment of the viewport's viewing angle and options to modify the viewport's viewing angle.

### Additional Tools

*   Some additional tools are available in the toolbar image at the beginning of this chapter, such as the Mesh button, which provides some quick actions or tools to work on a specific node or selection.

### API Documentation

For more information on the 3D scene tutorial, refer to the following API documentation:

*   `Node3D`
*   `Node`
*   `VectorMath`
*   `Transform`

### Example Use Cases

*   Create a new 3D scene and add nodes, such as `MeshInstance3D` and `DirectionalLight3D`.
*   Use the `Ruler Mode` and `Use Snap` options to measure distance in the scene and snap movement and rotation to grid.
*   Use the `Transform Menu` to adjust the transform parameters of a node manually.
