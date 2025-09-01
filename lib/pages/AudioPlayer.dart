import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

class AudioPlayerScreen extends StatefulWidget {
  final int index;
  const AudioPlayerScreen({super.key, required this.index});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioHandler audioHandler;
  bool _isSeeking = false;
  double _seekValue = 0.0;

  @override
  void initState() {
    super.initState();
    audioHandler = GetIt.instance<AudioHandler>();
    // Removed skipToQueueItem here — AlbumScreen already does it
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Text('Now Playing',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          if (mediaItem == null) {
            return const Center(child: Text("No song is currently playing."));
          }

          return Column(
            children: [
              const SizedBox(height: 30),
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: mediaItem.artUri != null
                    ? Image.network(mediaItem.artUri.toString(),
                        width: 300, height: 300, fit: BoxFit.cover)
                    : Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey,
                        child: const Icon(Icons.music_note, size: 100),
                      ),
              ),
              const SizedBox(height: 30),
              // Song Title & Artist
              Text(mediaItem.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(mediaItem.artist ?? 'Unknown Artist',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 30),

              // Progress Bar with live updates
              StreamBuilder<Duration>(
                stream: AudioService.position, // updates every 200ms
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = mediaItem.duration ?? Duration.zero;

                  return Column(
                    children: [
                      Slider(
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        inactiveColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3),
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        value: position.inMilliseconds
                            .clamp(0, duration.inMilliseconds)
                            .toDouble(),
                        onChanged: (value) {
                          audioHandler.seek(
                              Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(position)),
                            Text(_formatTime(duration)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Player Controls with disabled next/prev
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final playing = state?.playing ?? false;

                  return StreamBuilder<List<MediaItem>>(
                    stream: audioHandler.queue,
                    builder: (context, queueSnap) {
                      final queue = queueSnap.data ?? [];
                      final currentIndex =
                          queue.indexWhere((item) => item.id == mediaItem.id);

                      final hasPrevious = currentIndex > 0;
                      final hasNext =
                          currentIndex >= 0 && currentIndex < queue.length - 1;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 40,
                            color: hasPrevious
                                ? Theme.of(context).iconTheme.color
                                : Colors.grey.withOpacity(0.5),
                            onPressed:
                                hasPrevious ? audioHandler.skipToPrevious : null,
                          ),
                          IconButton(
                            icon: Icon(playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled),
                            iconSize: 70,
                            onPressed:
                                playing ? audioHandler.pause : audioHandler.play,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 40,
                            color: hasNext
                                ? Theme.of(context).iconTheme.color
                                : Colors.grey.withOpacity(0.5),
                            onPressed: hasNext ? audioHandler.skipToNext : null,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
