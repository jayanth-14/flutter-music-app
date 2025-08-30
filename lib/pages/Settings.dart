import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaana/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class Settings_page extends StatelessWidget {
  const Settings_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("S E T T I N G S")),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dark Mode", style: TextStyle(
              fontWeight: FontWeight.bold
            ),),

            CupertinoSwitch(
              value: Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}
