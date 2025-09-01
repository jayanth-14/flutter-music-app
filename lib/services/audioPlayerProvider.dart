import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
    ),
  );
}
class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final List<MediaItem> _mediaItems = [];
  String? _currentPlaylistId;

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();

    // Keep mediaItem in sync with player index
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _mediaItems.length) {
        mediaItem.add(_mediaItems[index]);
      }
    });
  }

  Future<void> addTracks(List<Map<String, dynamic>> content, {String? playlistId}) async {
    if(_currentPlaylistId == playlistId && _mediaItems.isNotEmpty) {
      return;
    }
    _currentPlaylistId = playlistId;
    _mediaItems.clear();
    final audioSources = <AudioSource>[];

    for (final song in content) {
      try {
        final songUrl = (song["download_url"] as List).last["link"];
        final imageUrl = (song["image"] as List).last["link"];
        final rawDuration = song["duration"];

        final item = MediaItem(
          id: songUrl,
          title: song["name"] ?? "Unknown",
          artist: (song["artist_map"]["primary_artists"] as List).isNotEmpty
              ? song["artist_map"]["primary_artists"][0]["name"]
              : "Unknown Artist",
          album: song["album"] ?? "",
          artUri: Uri.tryParse(imageUrl),
          duration: rawDuration is int ? Duration(seconds: rawDuration) : null,
        );

        _mediaItems.add(item);
        audioSources.add(AudioSource.uri(Uri.parse(songUrl)));
      } catch (e, st) {
        print("Skipping bad song: $e\n$st");
      }
    }

    // Update queue for UI + notification
    queue.add(List.unmodifiable(_mediaItems));

    // Load all sources at once
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
    );
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _mediaItems.length) return;
    await _player.seek(Duration.zero, index: index);
    await play();
  }
  @override  
  Future<void> seek(Duration sec) async {
    _player.seek(sec);
  }

  @override 
  Future<void> skipToPrevious() async {
    var previousIndex = _player.previousIndex;
    if (previousIndex == null) {
      return;
    }
    skipToQueueItem(previousIndex.toInt());
  }

  @override 
  Future<void> skipToNext() async {
    var nextIndex = _player.nextIndex;
    if (nextIndex == null) {
      return;
    }
    skipToQueueItem(nextIndex.toInt());
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            _player.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          playing: _player.playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
        ),
      );
    });
  }
}
