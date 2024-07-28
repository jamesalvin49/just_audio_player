import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const AudioApp());

class AudioApp extends StatefulWidget {
  const AudioApp({super.key});

  @override
  State<AudioApp> createState() => _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _player.setAsset('assets/audio/moo.mp3');
                  _player.play();
                },
                child: const Text('Cow'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async{
                  await _player.setAsset('assets/audio/horse.mp3');
                  _player.play();
                },
                child: const Text('Horse'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async{
                  await _player.setUrl('https://www.applesaucekids.com/sound%20effects/moo.mp3');
                  _player.play();
                },
                child: const Text('Cow (From Web)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}