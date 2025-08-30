import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? title;
  String? artist;
  String? imageUrl;
  String? url;

  AudioPlayer get player => _player;

  void playSong({
    required String url,
    required String title,
    required String artist,
    required String imageUrl,
  }) async {
    this.url = url;
    this.title = title;
    this.artist = artist;
    this.imageUrl = imageUrl;

    await _player.setUrl(url);
    _player.play();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
    notifyListeners();
  }
}
