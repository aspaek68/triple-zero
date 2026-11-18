# Export — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/export/index.html
- **Fetched**: 2026-11-18T14:24:49

Exporting Projects
====================

Overview
--------

Exporting a build of your project allows you to share or distribute your game, application, or other content with others. This section explains how to export projects, as well as the specific requirements for each platform.

### Exporting Projects

To export a project, follow these general steps:

1. Open the Godot project file (.gdproj)
2. Go to **Build** > **Export** or use the shortcut `Ctrl + Alt + E` (Windows) or `Cmd + Alt + E` (Mac)
3. Choose the export type (e.g., `.exe` for Windows, `.app` for macOS)
4. Select the platform and target device
5. Configure any additional settings as needed

### Platform-Specific Export Requirements

#### Windows

* Manually change application icon using `Manifest.json`
* Run Godot apps using `bin/` directory

#### Linux

* No specific requirements

#### macOS

* Run Godot apps using `bin/` directory

#### Android

* Use Gradle builds
* Run Godot apps using `bin/` directory

#### iOS

* Use Xcode to create and export projects
* Run Godot apps using `bin/` directory

#### visionOS

* Use Xcode to create and export projects
* Run Godot apps using `bin/` directory

#### Web

* Export as a web app using `bin/` directory

### One-Click Deploy

Godot provides a one-click deploy feature for exporting and deploying projects to various platforms. This feature can be enabled in the project settings.

### Dedicated Servers

Exporting for dedicated servers requires additional configuration and setup. Consult the Godot documentation for more information on exporting for dedicated servers.

APIs and Examples
-----------------

No specific APIs are mentioned in this section. However, the following example shows how to export a project:

```gdscript
var export_file = export_project("My Project")
```

Note: This example assumes you have already set up the export project in Godot.
