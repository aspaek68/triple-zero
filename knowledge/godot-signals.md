# godot signals

- **Source**: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Fetched**: 2026-11-17T17:07:35

Using signals — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
Step by step
Using signals
Edit on GitHub
Learn how to contribute!
Using signals
In this lesson, we will look at signals. They are messages that nodes emit when
For example, you might have a life bar on the screen that represents the
Like methods (
Callable
Signal
See also
As mentioned in the introduction, signals are Godot's version of the
Game Programming Patterns
We will now use a signal to make our Godot icon from the previous lesson
Listening to player input
Note
For this project, we will be following the Godot naming conventions.
GDScript

---

Using signals — Godot Engine (stable) documentation in English
Godot Engine 4.7 documentation in English
Step by step
Using signals
Edit on GitHub
Learn how to contribute!
Using signals

In this lesson, we will look at signals. They are messages that nodes emit when
something specific happens to them, like a button being pressed. Other nodes can
connect to that signal and call a function when the event occurs.
Signals are a delegation mechanism built into Godot that allows one game object to
react to a change in another without them referencing one another. Using signals
limits
coupling
and keeps your
code flexible.
For example, you might have a life bar on the screen that represents the
player's health. When the player takes damage or uses a healing potion, you want
the bar to reflect the change. To do so, in Godot, you would use signals.
Like methods (
Callable
), signals are a first-class type since Godot
4.0. This means you can pass them around as method arguments directly without
having to pass them as strings, which allows for better autocompletion and is
less error-prone. See the
Signal
class reference for a list of
what you can do with the Signal type directly.
See also
As mentioned in the introduction, signals are Godot's version of the
observer pattern. You can learn more about it in
Game Programming Patterns
.
We will now use a signal to make our Godot icon from the previous lesson
(
Listening to player input
) move and stop by pressing a button.
Note
For this project, we will be following the Godot naming conventions.
GDScript
: Classes (nodes) use PascalCase, variables and
functions use snake_case, and constants use ALL_CAPS (See
GDScript style guide
).
C#
: Classes, export variables and methods use PascalCase,
private fields use _camelCase, local variables and parameters use
camelCase (See
C# style guide
). Be careful to type
the method names precisely when connecting signals.
Scene setup

To add a button to our game, we will create a new scene which

[... truncated ...]
