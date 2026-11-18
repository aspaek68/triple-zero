# Audio — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/audio/index.html
- **Fetched**: 2026-11-18T03:04:48

**Audio in Godot Engine**
========================

**Overview**
------------

The Audio section in Godot Engine provides functionality for handling audio in the game. This includes audio buses, effects, streams, and more.

**Audio Buses**
---------------

*   An audio bus is a group of audio streams that can be edited and processed together.
*   You can create multiple audio buses in the Project Settings > Audio > Audio Buses section.
*   Each bus can have multiple streams added to it, allowing for complex audio routing.

**Audio Effects**
-----------------

*   Audio effects are plugins that can be applied to audio streams to modify their behavior.
*   Examples of audio effects include reverb, echo, and distortion.
*   Effects can be created using the Audio Effects node in the Scene Hierarchy or by importing custom effects from external plugins.

**Audio Streams**
-----------------

*   An audio stream is a single audio source that can be played back in the game.
*   You can create multiple audio streams using the AudioStreamPlayer node or by loading audio files using the Load() function.
*   Streams can be added to audio buses for further processing and routing.

**Syncing Gameplay with Audio and Music**
-----------------------------------------

*   To sync gameplay with audio and music, use the BeatSynchronizer node.
*   This node can be used to synchronize the audio playback with the game's music and sound effects.

**Recording with Microphone**
-----------------------------

*   To record audio with the microphone, use the AudioRecorder node.
*   This node allows you to record audio from the microphone and save it to a file.

**Text to Speech**
-----------------

*   To use text-to-speech functionality, use the SpeechSynthesis node.
*   This node allows you to convert text to speech and play it back in the game.

**API Documentation**
---------------------

For more information on the audio API in Godot Engine, see the official documentation: [Audio API Documentation](https://docs.godotengine.org/en/stable/appendix/audio/index.html)

**Example Use Case**
--------------------

Here's an example of how to create an audio bus and add an audio stream to it:

```gdscript
var audio_bus = AudioBus.new()
add_child(audio_bus)

var audio_stream = AudioStreamPlayer.new()
audio_stream.stream = load("res://example.mp3")
audio_bus.add_stream(audio_stream)
```

This code creates a new audio bus, adds an audio stream to it, and loads an audio file from the `res://` directory.
