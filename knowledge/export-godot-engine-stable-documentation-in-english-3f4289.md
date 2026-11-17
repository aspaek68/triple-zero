# Export — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/export/index.html
- **Fetched**: 2026-11-17T20:49:52

Exporting Projects in Godot Engine
================================

Overview
--------

Exporting a build of your project allows you to create a distributable package that can be shared with others or deployed on a target platform.

### Types of Exports

*   Packs: Exporting the entire project as a single package.
*   Patches: Exporting a set of changes to the project.
*   Mods: Exporting additional content for the project, such as levels or assets.

### Exporting for Different Platforms

*   **Windows**: Manually change application icon using the `ApplicationIcon` node.
*   **Linux**: Run Godot apps on macOS using the `export` command in the terminal.
*   **macOS**: Run Godot apps on macOS using the `export` command in the terminal.
*   **Android**: Use Gradle builds to deploy the app.
*   **iOS**: Use Xcode to deploy the app.
*   **visionOS**: Use the `export` command in the terminal.
*   **Web**: Export the project to be run in a web browser.

### One-Click Deploy

Godot provides a one-click deploy feature for dedicated servers.

### Example Code

```gdscript
// Exporting the entire project as a pack
extends Export

func _ready():
    export_pack("my_project_pack.gdpack")
```

```gdscript
// Exporting a set of changes to the project (patches)
extends ExportPatch

func _ready():
    export_patch("my_patch.patch")
```

```gdscript
// Exporting additional content for the project (mods)
extends ExportMod

func _ready():
    export_mod("my_mod.mod")
```

Note: The provided example code snippets are for illustrative purposes only and may require modifications to suit your specific use case.
