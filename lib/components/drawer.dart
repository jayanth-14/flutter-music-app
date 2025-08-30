import 'package:flutter/material.dart';
import 'package:gaana/pages/Settings.dart';

class appDrawer extends StatelessWidget {
  const appDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(child: Center(
            child: Icon(
              Icons.music_note,
              size: 40,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          )),
          Padding(padding: const EdgeInsets.only(left:25.0, top: 25),
          child: ListTile(
            title: Text("H O M E"),
            leading: Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ),

          Padding(padding: const EdgeInsets.only(left:25.0, top: 25),
          child: ListTile(
            title: Text("S E T T I N G S"),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings_page()));
            },
          ),
          ),
        ],
      ),
    );
  }
}