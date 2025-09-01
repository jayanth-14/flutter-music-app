import 'package:flutter/material.dart';
import 'package:gaana/pages/home.dart';
import 'package:gaana/services/serviceLoacator.dart';
import 'package:gaana/theme/dark_mode.dart';
import 'package:gaana/theme/light_mode.dart';
import 'package:gaana/theme/theme_provider.dart';
import 'package:gaana/utils/permissions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox("settings");
  
  await requestNotificationPermission();
  await setupServiceLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(box: box),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box box;
  const MyApp({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Gaana',
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: themeProvider.themeData == lightMode ? ThemeMode.light : ThemeMode.dark,
          home: Home(box: box),
        );
      },
    );
  }
}
