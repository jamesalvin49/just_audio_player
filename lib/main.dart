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

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            //const Spacer(),
            CurrentSongTitle(),
            Playlist(),
            AddRemoveSongButtons(),
            AudioProgressBar(),
            AudioControlButtons(),
          ],
        ),
      ),
    );
  }
}

class Playlist extends ConsumerWidget {
  const Playlist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);
    return Expanded(
      child: ListView.builder(
        itemCount: audioState.playlist.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Song $index"),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class AddRemoveSongButtons extends ConsumerWidget {
  const AddRemoveSongButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the playlistNotifier to get methods for adding and removing songs
    final playlistNotifier = ref.read(audioStateProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () => playlistNotifier.addSong(),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => playlistNotifier.removeSong(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class AudioProgressBar extends ConsumerWidget {
  const AudioProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);
    final audioNotifier = ref.read(audioStateProvider.notifier);
    return ProgressBar(
      progress: audioState.currentPosition,
      buffered: audioState.bufferedPosition,
      total: audioState.totalDuration,
      onSeek: audioNotifier.seek,
    );
  }
}

class CurrentSongTitle extends ConsumerWidget {
  const CurrentSongTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        audioState.currentSongTitle,
        style: const TextStyle(fontSize: 40),
      ),
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RepeatButton(),
          PreviousButton(),
          PlayPauseButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class RepeatButton extends ConsumerWidget {
  const RepeatButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the audioStateProvider to get the current state
    final audioState = ref.watch(audioStateProvider);
    final audioNotifier = ref.read(audioStateProvider.notifier);

    Icon icon;
    switch (audioState.repeatState) {
      case RepeatState.off:
        icon = const Icon(Icons.repeat, color: Colors.grey);
        break;
      case RepeatState.repeatSong:
        icon = const Icon(Icons.repeat_one);
        break;
      case RepeatState.repeatPlaylist:
        icon = const Icon(Icons.repeat);
        break;
    }

    return IconButton(
      icon: icon,
      onPressed: () {
        audioNotifier.onRepeatButtonPressed();
      },
    );
  }
}

class PreviousButton extends ConsumerWidget {
  const PreviousButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the audioStateProvider to get the current state
    final audioState = ref.watch(audioStateProvider);

    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: audioState.isFirstSong
          ? null
          : () => ref
              .read(audioStateProvider.notifier)
              .onPreviousSongButtonPressed(),
    );
  }
}

class PlayPauseButton extends ConsumerWidget {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the audioStateProvider to get the current state
    final audioState = ref.watch(audioStateProvider);
    final audioNotifier = ref.read(audioStateProvider.notifier);

    switch (audioState.buttonState) {
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

class NextSongButton extends ConsumerWidget {
  const NextSongButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the audioStateProvider to get the current state
    final audioState = ref.watch(audioStateProvider);

    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: audioState.isLastSong
          ? null
          : () =>
              ref.read(audioStateProvider.notifier).onNextSongButtonPressed(),
    );
  }
}

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the audioStateProvider to get the current state
    final audioState = ref.watch(audioStateProvider);

    return IconButton(
      icon: audioState.isShuffleModeEnabled
          ? const Icon(Icons.shuffle)
          : const Icon(Icons.shuffle, color: Colors.grey),
      onPressed: ref.read(audioStateProvider.notifier).onShuffleButtonPressed,
    );
  }
}
