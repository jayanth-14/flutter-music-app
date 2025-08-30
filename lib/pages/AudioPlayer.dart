import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.url, required this.title, required this.imageUrl, required this.artist});
  final String url, title, artist, imageUrl;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.url);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Album Art Placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.imageUrl,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          // Song Title & Artist
           Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
           Text(
            widget.artist,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 30),
          // Progress Bar
          StreamBuilder<Duration?>(
            stream: _audioPlayer.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > duration) position = duration;
                  return Column(
                    children: [
                      Slider(
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        value: position.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatTime(position), style: const TextStyle(color: Colors.white)),
                            Text(formatTime(duration), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 30),
          // Player Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                iconSize: 40,
                onPressed: () {},
              ),
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return IconButton(
                    icon: Icon(
                      playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    iconSize: 70,
                    onPressed: () {
                      if (playing) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                iconSize: 40,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
