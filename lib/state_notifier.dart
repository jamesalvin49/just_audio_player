import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum ButtonState {
  paused,
  playing,
  loading,
}

class AudioState {
  final Duration currentPosition;
  final Duration bufferedPosition;
  final Duration totalDuration;
  final ButtonState buttonState;

  AudioState({
    this.currentPosition = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.buttonState = ButtonState.paused,
  });

  AudioState copyWith({
    Duration? currentPosition,
    Duration? bufferedPosition,
    Duration? totalDuration,
    ButtonState? buttonState,
  }) {
    return AudioState(
      currentPosition: currentPosition ?? this.currentPosition,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      buttonState: buttonState ?? this.buttonState,
    );
  }
}

class AudioStateNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioStateNotifier() : super(AudioState()) {
    _init();
  }

  void _init() async {
    String url =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

    await _audioPlayer.setUrl(url);
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        state = state.copyWith(buttonState: ButtonState.loading);
      } else if (!isPlaying) {
        state = state.copyWith(buttonState: ButtonState.paused);
      } else if (processingState != ProcessingState.completed) {
        state = state.copyWith(buttonState: ButtonState.playing);
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(currentPosition: position);
    });

    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      state = state.copyWith(bufferedPosition: bufferedPosition);
    });

    _audioPlayer.durationStream.listen((totalDuration) {
      state = state.copyWith(totalDuration: totalDuration ?? Duration.zero);
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
