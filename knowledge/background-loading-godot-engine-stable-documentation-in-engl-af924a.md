# Background loading — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html
- **Fetched**: 2026-11-17T18:06:29

Background loading — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
File and data I/O
Background loading
Edit on GitHub
Learn how to contribute!
Background loading
Commonly, games need to load resources asynchronously.
When switching the main scene of your game (e.g. going to a new
The standard load method
ResourceLoader.load
One way around this is using
ResourceLoader
Using ResourceLoader
Generally, you queue requests to load resources for a path using
ResourceLoader.load_threaded_request
You can check the status with
ResourceLoader.load_threaded_get_status
Finally, you retrieve loaded resources by calling
ResourceLoader.load_threaded_get

---

Background loading — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
File and data I/O
Background loading
Edit on GitHub
Learn how to contribute!
Background loading

Commonly, games need to load resources asynchronously.
When switching the main scene of your game (e.g. going to a new
level), you might want to show a loading screen with some indication
that progress is being made, or you may want to load additional resources
during gameplay.
The standard load method
(
ResourceLoader.load
or GDScript's simpler
load
) blocks your
thread, making your game appear unresponsive while the resource is being loaded.
One way around this is using
ResourceLoader
to load resources asynchronously
in background threads.
Using ResourceLoader

Generally, you queue requests to load resources for a path using
ResourceLoader.load_threaded_request
,
which will then be loaded in threads in the background.
You can check the status with
ResourceLoader.load_threaded_get_status
.
Progress can be obtained by passing an array variable via progress which will return
a one element array containing the percentage.
Finally, you retrieve loaded resources by calling
ResourceLoader.load_threaded_get
.
Once you call
load_threaded_get()
, either the resource finished loading in
the background and will be returned instantly or the load will block at this point like
load()
would. If you want to guarantee this does not block,
you either need to ensure there is enough time between requesting the load and
retrieving the resource or you need to check the status manually.
Example

This example demonstrates how to load a scene in the background.
We will have a button spawn an enemy when pressed.
The enemy will be
Enemy.tscn
which we will load on
_ready
and instantiate when pressed.
The path will be
"Enemy.tscn"
which is located at
res://Enemy.tscn
.
First, we will start a request to load the resource and connect the button:
GDScript
C#
const
ENEMY_SCENE_PATH
:
String


[... truncated ...]
