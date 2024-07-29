import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  final buttonNotifier = ValueNotifier<ButtonState>(
    ButtonState.paused,
  );

  // The song is a freely available mp3 from SoundHelix.
  static const url =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

  late AudioPlayer _audioPlayer;

  PageManager() {
    _init();
  }
  // Since _init is called from the constructor, the AudioPlayer will
  // start up as soon as this state management class is created.
  // That's done in the initState method in main.dart.
  void _init() async {
    _audioPlayer = AudioPlayer();

    // Since you can't perform an async task inside of a constructor,
    // you moved it to an _init method. There you created the AudioPlayer
    // object and set the URL for the song it will play.
    await _audioPlayer.setUrl(url);

    /// This code listens to the state changes of an audio player and updates the UI accordingly.
    /// The [playerStateStream] stream emits the current state of the player.
    /// The code begins by setting up a listener on the _audioPlayer.playerStateStream.
    /// This stream emits events whenever the state of the audio player changes.
    /// The listener function takes a playerState parameter, which contains information about the current state of the player.
    ///
    /// Inside the listener, two key pieces of information are extracted from playerState:
    /// isPlaying: A boolean indicating whether the audio player is currently playing.
    ///
    /// processingState: An enum value representing the current processing state of the player (e.g., loading, buffering, completed).
    ///
    /// If the processingState is either ProcessingState.loading or ProcessingState.buffering,
    /// it means the player is in the process of loading or buffering audio data.
    /// In this case, the buttonNotifier.value is set to ButtonState.loading,
    /// likely to show a loading indicator in the UI.
    ///
    /// If the player is not playing (!isPlaying), the buttonNotifier.value is set to ButtonState.paused,
    /// indicating that playback is paused.
    ///
    /// If the player is playing and the processingState is not ProcessingState.completed,
    /// the buttonNotifier.value is set to ButtonState.playing, indicating that
    /// audio is currently being played.
    /// If the processingState is ProcessingState.completed, it means the audio playback has finished.
    ///
    /// The code then seeks the audio player back to the start (Duration.zero)
    /// and pauses it, effectively resetting the player for potential future playback.
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;

      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    /// listens to a stream of audio player position updates and updates 
    /// a notifier with the current progress of the audio playback.
    /// 
    /// Next we retrieve the current value of progressNotifier and stores it in oldState. 
    /// progressNotifier is presumably a ValueNotifier that holds the state of the progress bar.
    /// 
    /// We then update the value of progressNotifier with a new ProgressBarState object.
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    /// The bufferedPositionStream is likely a stream that emits updates about 
    /// the buffered position of the audio playback. 
    /// This stream provides information on how much of the audio has been buffered, 
    /// which is useful for displaying buffering progress in a media player.
    /// 
    /// You can listen to the bufferedPositionStream to get updates on the buffered position. 
    /// This is typically done using the listen method.
    /// 
    /// The buffered position information can be used to update the UI, 
    /// such as a progress bar that shows how much of the audio has been buffered.
    /// 
    /// By listening to this stream, you can handle buffering events, 
    /// such as showing a loading indicator when buffering is in progress.
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    /// The durationStream is likely a stream that emits updates about the total 
    /// duration of the audio being played. 
    /// This stream provides information on the length of the audio track, 
    /// which is essential for various functionalities in a media player, 
    /// such as displaying the total duration and calculating the progress of playback.
    /// 
    /// You can listen to the durationStream to get updates on the total 
    /// duration of the audio. This is typically done using the listen method.
    /// 
    /// The total duration information can be used to update the UI, 
    /// such as displaying the total length of the audio track in a progress bar or a timer.
    /// 
    /// By listening to this stream, you can handle changes in the duration, 
    /// which might occur if the audio source changes or if the duration is 
    /// initially unknown and later determined.
    /// 
    /// When a new duration is emitted, it updates the progressNotifier with 
    /// the new total duration while keeping the current position and buffered position unchanged.
    /// If the duration is null, it defaults to Duration.zero.
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState {
  paused,
  playing,
  loading,
}
