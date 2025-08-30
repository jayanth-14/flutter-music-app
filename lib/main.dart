import 'package:flutter/material.dart';
import 'package:gaana/pages/Home.dart';
import 'package:gaana/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './pages/Start.dart';
import 'package:just_audio/just_audio.dart';

// Player state manager
class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? currentTitle;
  String? currentImage;
  String? currentArtist;
  String? currentUrl;

  AudioPlayer get player => _player;

  Future<void> play(String url, String title, String image, String artist) async {
    currentUrl = url;
    currentTitle = title;
    currentImage = image;
    currentArtist = artist;
    await _player.setUrl(url);
    _player.play();
    notifyListeners();
  }

  void pause() {
    _player.pause();
    notifyListeners();
  }

  void resume() {
    _player.play();
    notifyListeners();
  }

  void stop() {
    _player.stop();
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('myBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('myBox');
    bool hasUserData = box.get('username') != null;

    return MaterialApp(
      title: 'Gaana',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: hasUserData ? Home(box: Hive.box("myBox")) : const StartPage(),
    );
  }
}
