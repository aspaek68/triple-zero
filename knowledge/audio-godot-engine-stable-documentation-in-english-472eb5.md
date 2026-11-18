# Audio — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/audio/index.html
- **Fetched**: 2026-11-18T14:21:25

# Audio in Godot Engine
=====================================

## Audio Buses
---------------

*   Audio buses are used to route audio signals between nodes in a scene.
*   Each audio bus has a source node that defines the audio signal.

## Audio Effects
----------------

*   Audio effects are used to modify the audio signal in a node.
*   Examples of audio effects include volume, pitch, and reverb.

## Audio Streams
----------------

*   Audio streams are used to play and control audio files.
*   Examples of audio streams include WAV and MP3 files.

## Synchronizing Audio and Gameplay
------------------------------------

*   To synchronize audio and gameplay, use the `play_audio()` function to play audio files at specific times.
*   Use the `get_duration()` function to get the duration of an audio stream.

## Recording with Microphone
---------------------------

*   To record with a microphone, use the `AudioRecorder` node.
*   Configure the `AudioRecorder` node to record audio from the correct device.

## Text-to-Speech
-----------------

*   To use text-to-speech, use the `TextToSpeech` node.
*   Configure the `TextToSpeech` node to play the text.

## API Examples
----------------

### Audio Bus API

```gdscript
var audio_bus = AudioBus.new()
add_child(audio_bus)

audio_bus.set_source(Node.get_node("MySourceNode"))
```

### Audio Effect API

```gdscript
var audio_effect = AudioEffect.new()
add_child(audio_effect)

audio_effect.set_value(1.5)  # Set volume to 1.5
```

### Audio Stream API

```gdscript
var audio_stream = AudioStream.new()
audio_stream.load("res://my_audio_file.wav")

var player = Node.get_node("MyPlayerNode")
player.play_audio(audio_stream)
```

Note: These examples are just a starting point and can be modified to fit your specific use case.
