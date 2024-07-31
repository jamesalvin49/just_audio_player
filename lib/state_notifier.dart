import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// This enum represents the different states of a play/pause button in an audio player.
/// 
/// - `paused`: Indicates that the audio is currently paused.
/// - `playing`: Indicates that the audio is currently playing.
/// - `loading`: Indicates that the audio is in the process of loading.
enum ButtonState {
  paused,
  playing,
  loading,
}
/// This enum represents the different repeat states for an audio player.
/// 
/// - `off`: Indicates that repeat is turned off.
/// - `repeatSong`: Indicates that the current song will be repeated.
/// - `repeatPlaylist`: Indicates that the entire playlist will be repeated.
enum RepeatState {
  off,
  repeatSong,
  repeatPlaylist,
}

/// The `AudioState` class represents the state of the audio player.
/// 
/// It contains various properties that describe the current state of the audio player:
/// 
/// - `currentPosition`: The current playback position of the audio.
/// - `bufferedPosition`: The position up to which the audio has been buffered.
/// - `totalDuration`: The total duration of the current audio track.
/// - `buttonState`: The state of the play/pause button, represented by the `ButtonState` enum.
/// - `repeatState`: The repeat mode of the audio player, represented by the `RepeatState` enum.
/// - `isShuffleModeEnabled`: A boolean indicating whether shuffle mode is enabled.
/// - `currentSongTitle`: The title of the currently playing song.
/// - `playlist`: A list of song titles in the current playlist.
/// - `isFirstSong`: A boolean indicating whether the current song is the first in the playlist.
/// - `isLastSong`: A boolean indicating whether the current song is the last in the playlist.
/// 
/// The class also provides a `copyWith` method to create a copy of the current state with updated values.
class AudioState {
  final Duration currentPosition;
  final Duration bufferedPosition;
  final Duration totalDuration;
  final ButtonState buttonState;
  final RepeatState repeatState;
  final bool isShuffleModeEnabled;
  final String currentSongTitle;
  final List<String> playlist;
  final bool isFirstSong;
  final bool isLastSong;

  AudioState({
    this.currentPosition = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.buttonState = ButtonState.paused,
    this.repeatState = RepeatState.off,
    this.isShuffleModeEnabled = false,
    this.currentSongTitle = '',
    this.playlist = const [],
    this.isFirstSong = true,
    this.isLastSong = true,
  });

  AudioState copyWith({
    Duration? currentPosition,
    Duration? bufferedPosition,
    Duration? totalDuration,
    ButtonState? buttonState,
    RepeatState? repeatState,
    bool? isShuffleModeEnabled,
    String? currentSongTitle,
    List<String>? playlist,
    bool? isFirstSong,
    bool? isLastSong,
  }) {
    return AudioState(
      currentPosition: currentPosition ?? this.currentPosition,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      buttonState: buttonState ?? this.buttonState,
      repeatState: repeatState ?? this.repeatState,
      isShuffleModeEnabled: isShuffleModeEnabled ?? this.isShuffleModeEnabled,
      currentSongTitle: currentSongTitle ?? this.currentSongTitle,
      playlist: playlist ?? this.playlist,
      isFirstSong: isFirstSong ?? this.isFirstSong,
      isLastSong: isLastSong ?? this.isLastSong,
    );
  }
}

class AudioStateNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConcatenatingAudioSource _playlist;

  AudioStateNotifier() : super(AudioState()) {
    _init();
  }

  void _init() async {
    _setInitialPlaylist();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }

/// The `_setInitialPlaylist` function initializes the audio player's playlist with a set of predefined songs.
/// 
/// This function performs the following steps:
/// 
/// 1. Defines a constant `prefix` which is the base URL for the audio files.
/// 2. Creates three `Uri` objects (`song1`, `song2`, `song3`) by appending the specific song filenames to the `prefix`.
/// 3. Initializes the `_playlist` variable as a `ConcatenatingAudioSource` with the three songs as its children. Each song is represented as an `AudioSource.uri` with a corresponding tag ('Song 1', 'Song 2', 'Song 3').
/// 4. Asynchronously sets the audio source of the `_audioPlayer` to the newly created `_playlist`.
/// 
/// This function is marked as `async` because it performs an asynchronous operation (`_audioPlayer.setAudioSource`), which sets the audio source for the player and prepares it for playback.
  void _setInitialPlaylist() async {
    const prefix = 'https://www.soundhelix.com/examples/mp3';
    final song1 = Uri.parse('$prefix/SoundHelix-Song-1.mp3');
    final song2 = Uri.parse('$prefix/SoundHelix-Song-2.mp3');
    final song3 = Uri.parse('$prefix/Soundhelix-Song-3.mp3');
    _playlist = ConcatenatingAudioSource(children: [
      AudioSource.uri(song1, tag: 'Song 1'),
      AudioSource.uri(song2, tag: 'Song 2'),
      AudioSource.uri(song3, tag: 'Song 3'),
    ]);
    await _audioPlayer.setAudioSource(_playlist);
  }

  // The _listenForChangesInPlayerState function is a private method designed to monitor changes in the state of the audio player. 
  // This function is crucial for keeping the application's UI and internal state in sync with the actual state of the audio player. 
  // Here is a detailed breakdown of its purpose and functionality:
  // 
  // Purpose:
  // The primary purpose of _listenForChangesInPlayerState is to listen for various state changes in the audio player 
  // and update the application's state accordingly. This ensures that the UI reflects the current status of the audio playback, 
  // such as whether a song is playing, paused, or loading.
  // 
  // Functionality:
  // 1. Subscribing to Player State Changes: The function subscribes to the audio player's state changes. 
  //    This typically involves listening to a stream or a notifier provided by the audio player library.
  // 2. Handling Different States: The function handles different states of the audio player, such as playing, paused, 
  //    buffering, or completed. Each state triggers specific actions or updates in the application's state.
  // 3. Updating UI State: Based on the current state of the audio player, the function updates the UI state. 
  //    For example, if the player is buffering, the UI might show a loading indicator. If the player is playing, the UI 
  //    might show a pause button.
  // 4. Error Handling: The function may also handle errors or unexpected states, ensuring that the application can 
  //    gracefully recover or inform the user of any issues.
  // 
  // Integration with State Management:
  // The function is typically integrated with a state management solution, Riverpod. 
  // It updates the state notifier or state management object with the latest player state, ensuring that the rest 
  // of the application can react to these changes.
  // 
  // Asynchronous Operations:
  // Since the function deals with real-time state changes, it often involves asynchronous operations. 
  // It might use async/await patterns or stream subscriptions to handle these changes efficiently.
  // 
  // Private Scope:
  // The function is marked as private (with a leading underscore), indicating that it is intended for internal use within 
  // the class or module. This encapsulation helps maintain a clean and manageable codebase.
  // 
  // By listening for changes in the player state, _listenForChangesInPlayerState ensures that the audio player's 
  // behavior is accurately reflected in the application's UI and state, providing a seamless and responsive user experience.
  void _listenForChangesInPlayerState() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      ButtonState buttonState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonState = ButtonState.loading;
      } else if (!isPlaying) {
        buttonState = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonState = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        buttonState = ButtonState.paused;
      }

      state = state.copyWith(buttonState: buttonState);
    });
  }

  /// The primary purpose of _listenForChangesInPlayerPosition is to listen for updates to the playback position of the audio player and update the application's state accordingly. This allows the UI to display the current playback position accurately, such as in a progress bar or time display.
  /// Subscribing to Position Stream: The function subscribes to the positionStream of the _audioPlayer. This stream emits updates whenever the playback position changes.
  /// Listening for Position Changes: The function listens to the stream and receives the current playback position as a Duration object.
  /// Updating State: Upon receiving a new position, the function updates the application's state by creating a new state object with the updated currentPosition. This is typically done using a copyWith method to ensure immutability and state consistency.
  /// The function is integrated with a state management solution, where state represents the current state of the audio player. By updating the state with the new playback position, the rest of the application can react to these changes and update the UI accordingly.
  /// The function handles asynchronous updates from the position stream. It uses a listener to react to each new position emitted by the stream in real-time.
  /// The function is marked as private (with a leading underscore), indicating that it is intended for internal use within the class or module. This encapsulation helps maintain a clean and manageable codebase.
  /// By listening for changes in the playback position, _listenForChangesInPlayerPosition ensures that the application's state is always in sync with the audio player's current position, providing a responsive and accurate user experience.
  
  void _listenForChangesInPlayerPosition() {
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(currentPosition: position);
    });
  }

  /// The primary purpose of _listenForChangesInBufferedPosition is to listen for updates to the buffered position of the audio player and update the application's state accordingly. This allows the UI to display the current buffered position accurately, such as in a progress bar indicating how much of the audio has been buffered.
  /// Subscribing to Buffered Position Stream: The function subscribes to the bufferedPositionStream of the _audioPlayer. This stream emits updates whenever the buffered position changes.
  /// Listening for Buffered Position Changes: The function listens to the stream and receives the current buffered position as a Duration object.
  /// Updating State: Upon receiving a new buffered position, the function updates the application's state by creating a new state object with the updated bufferedPosition. This is typically done using a copyWith method to ensure immutability and state consistency.
  /// The function is integrated with a state management solution, where state represents the current state of the audio player. By updating the state with the new buffered position, the rest of the application can react to these changes and update the UI accordingly.
  /// The function handles asynchronous updates from the buffered position stream. It uses a listener to react to each new buffered position emitted by the stream in real-time.
  /// The function is marked as private (with a leading underscore), indicating that it is intended for internal use within the class or module. This encapsulation helps maintain a clean and manageable codebase.
  /// By listening for changes in the buffered position, _listenForChangesInBufferedPosition ensures that the application's state is always in sync with the audio player's current buffered position, providing a responsive and accurate user experience.
  void _listenForChangesInBufferedPosition() {
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      state = state.copyWith(bufferedPosition: bufferedPosition);
    });
  }
  /// The primary purpose of _listenForChangesInTotalDuration is to listen for updates to the total duration of the audio player and update the application's state accordingly. This allows the UI to display the total duration of the audio track, which is essential for features like progress bars and time displays.
  /// Subscribing to Duration Stream: The function subscribes to the durationStream of the _audioPlayer. This stream emits updates whenever the total duration of the audio changes.
  /// Listening for Duration Changes: The function listens to the stream and receives the current total duration as a Duration object.
  /// Handling Null Values: If the totalDuration is null, it defaults to Duration.zero. This ensures that the state is always updated with a valid Duration object.
  /// Updating State: Upon receiving a new total duration, the function updates the application's state by creating a new state object with the updated totalDuration. This is typically done using a copyWith method to ensure immutability and state consistency.
  /// The function is integrated with a state management solution, where state represents the current state of the audio player. By updating the state with the new total duration, the rest of the application can react to these changes and update the UI accordingly.
  /// The function handles asynchronous updates from the duration stream. It uses a listener to react to each new total duration emitted by the stream in real-time.
  /// The function is marked as private (with a leading underscore), indicating that it is intended for internal use within the class or module. This encapsulation helps maintain a clean and manageable codebase.
  /// By listening for changes in the total duration, _listenForChangesInTotalDuration ensures that the application's state is always in sync with the audio player's current total duration, providing a responsive and accurate user experience.
  void _listenForChangesInTotalDuration() {
    _audioPlayer.durationStream.listen((totalDuration) {
      state = state.copyWith(totalDuration: totalDuration ?? Duration.zero);
    });
  }

  /// Listen to Sequence State Stream: The method _listenForChangesInSequenceState listens to changes in the sequence state of an audio player.
  /// Check for Null Sequence State: If the sequence state is null, the method returns immediately.
  /// Update Current Song Title: Extract the current item from the sequence state and update the state with the current song title.
  /// Update Playlist: Extract the playlist from the sequence state, map the items to their titles, and update the state with the playlist.
  /// Update Shuffle Mode: Update the state with the shuffle mode status from the sequence state.
  /// Update First and Last Song Indicators: Determine if the current item is the first or last song in the playlist and update the state accordingly.
  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // Update current song title
      final currentItem = sequenceState.currentSource;
      final title = currentItem?.tag as String?;
      state = state.copyWith(currentSongTitle: title ?? '');

      // Update playlist
      final playlist = sequenceState.effectiveSequence;
      final titles = playlist.map((item) => item.tag as String).toList();
      state = state.copyWith(playlist: titles);

      // Update shuffle mode
      state = state.copyWith(
          isShuffleModeEnabled: sequenceState.shuffleModeEnabled);

      // Update first and last song indicators
      final isFirstSong = playlist.first == currentItem;
      final isLastSong = playlist.last == currentItem;
      state = state.copyWith(isFirstSong: isFirstSong, isLastSong: isLastSong);
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
  /// Determine Next Repeat State: Calculate the next repeat state by incrementing the current state's index and using modulo to cycle through the available states.
  /// Update State: Update the state with the new repeat state.
  /// Set Loop Mode: Based on the new repeat state, set the appropriate loop mode on the audio player.
  void onRepeatButtonPressed() {
    final next = (state.repeatState.index + 1) % RepeatState.values.length;
    final nextRepeatState = RepeatState.values[next];
    state = state.copyWith(repeatState: nextRepeatState);

    switch (nextRepeatState) {
      case RepeatState.off:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatState.repeatSong:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  void onPreviousSongButtonPressed() {
    _audioPlayer.seekToPrevious();
  }

  void onNextSongButtonPressed() {
    _audioPlayer.seekToNext();
  }

  void onShuffleButtonPressed() async {
    final enable = !_audioPlayer.shuffleModeEnabled;
    if (enable) {
      await _audioPlayer.shuffle();
    }
    await _audioPlayer.setShuffleModeEnabled(enable);
    state = state.copyWith(isShuffleModeEnabled: enable);
  }

  void addSong() {
    final songNumber = _playlist.length + 1;
    const prefix = 'https://www.soundhelix.com/examples/mp3';
    final song = Uri.parse('$prefix/Soundhelix-Song-$songNumber.mp3');
    print(song);
    _playlist.add(AudioSource.uri(song, tag: 'Song $songNumber'));
  }

  void removeSong() {
    final index = _playlist.length - 1;
    if (index < 0) return;
    _playlist.removeAt(index);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

final audioStateProvider =
    StateNotifierProvider<AudioStateNotifier, AudioState>(
  (ref) => AudioStateNotifier(),
);
