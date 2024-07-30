import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_player/state_notifier.dart';

void main() => runApp(
      const ProviderScope(
        child: AudioApp(),
      ),
    );

class AudioApp extends StatelessWidget {
  const AudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AudioPage(),
    );
  }
}

class AudioPage extends ConsumerWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);
    final audioNotifier = ref.read(audioStateProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Spacer(),
            ProgressBar(
              progress: audioState.currentPosition,
              buffered: audioState.bufferedPosition,
              total: audioState.totalDuration,
            ),
            buildPlayPauseButton(audioState.buttonState, audioNotifier),
          ],
        ),
      ),
    );
  }

  Widget buildPlayPauseButton(
      ButtonState buttonState, AudioStateNotifier audioNotifier) {
    switch (buttonState) {
      case ButtonState.loading:
        return Container(
          margin: const EdgeInsets.all(8.0),
          width: 32.0,
          height: 32.0,
          child: const CircularProgressIndicator(),
        );
      case ButtonState.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 32.0,
          onPressed: audioNotifier.play,
        );
      case ButtonState.playing:
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 32.0,
          onPressed: audioNotifier.pause,
        );
      default:
        return Container();
    }
  }
}
