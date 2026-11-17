# Audio — Godot Engine (stable) documentation in English

- **Source**: https://docs.godotengine.org/en/stable/tutorials/audio/index.html
- **Fetched**: 2026-11-17T20:40:24

**Audio in Godot Engine**
==========================

The Godot Engine provides an efficient and feature-rich audio system for creating immersive game experiences.

**Audio Buses**
---------------

Audio buses allow you to manipulate audio signals at the scene level. A scene can have multiple audio buses, which can be used to mix and manipulate audio signals.

*   **Create a new audio bus**: `AudioBus.new()`
*   **Assign an audio source to an audio bus**: `audio_bus.add_source(audio_source)`
*   **Mix audio signals on an audio bus**: `audio_bus.mix()`

**Audio Effects**
----------------

Audio effects can be applied to audio sources to modify their behavior. Audio effects can be used to add reverb, delay, and distortion to audio signals.

*   **Create a new audio effect**: `AudioEffect.new()`
*   **Assign an audio source to an audio effect**: `audio_effect.add_source(audio_source)`
*   **Apply an audio effect to an audio source**: `audio_source.add_effect(audio_effect)`

**Audio Streams**
-----------------

Audio streams allow you to play and manipulate audio files in Godot.

*   **Create a new audio stream**: `AudioStream.new()`
*   **Load an audio file into an audio stream**: `audio_stream.load("path/to/audio/file.wav")`
*   **Play an audio stream**: `audio_stream.play()`

**Syncing Gameplay with Audio and Music**
-----------------------------------------

To sync gameplay with audio and music, you can use the `AudioStream` class in conjunction with the `AudioEffect` class.

*   **Create an audio stream**: `AudioStream.new()`
*   **Load an audio file into the audio stream**: `audio_stream.load("path/to/audio/file.wav")`
*   **Apply an audio effect to the audio stream**: `audio_stream.add_effect(audio_effect)`
*   **Use the audio stream in your game**: `audio_stream.play()`

**Recording with Microphone**
------------------------------

To record audio with a microphone, you can use the `AudioRecord` class in conjunction with the `AudioEffect` class.

*   **Create an audio record**: `AudioRecord.new()`
*   **Assign a microphone to the audio record**: `audio_record.set_microphone(microphone)`
*   **Record audio**: `audio_record.record()`

**Text to Speech**
-----------------

To convert text to speech, you can use the `TTSPlayer` class in conjunction with the `AudioStream` class.

*   **Create a TTS player**: `TTSPlayer.new()`
*   **Load a text file into the TTS player**: `tts_player.load("path/to/text/file.txt")`
*   **Play the text to speech audio**: `tts_player.play()`

These are some of the key concepts and APIs for working with audio in Godot Engine. By mastering these features, you can create immersive and engaging game experiences that take advantage of the power of audio.
