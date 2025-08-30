import 'package:flutter/material.dart';
import 'package:gaana/components/drawer.dart';
import 'package:gaana/pages/Album.dart';
import 'package:gaana/pages/AudioPlayer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../main.dart';

class Home extends StatelessWidget {
  final Box box;
  const Home({super.key, required this.box});

  Future<Map<String, dynamic>> fetchModules() async {
    final langs = List<String>.from(box.get("languages", defaultValue: []));
    final joinedLangs = langs.join(",");
    final response = await http.get(
      Uri.parse("https://rhythm-api.vercel.app/modules?lang=$joinedLangs"),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Map<String, dynamic>.from(json["data"] ?? {});
    } else {
      throw Exception("Failed to load modules (${response.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      drawer: appDrawer(),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: fetchModules(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No modules available"));
                }

                final sections = snapshot.data!;
                return ListView.builder(
                  itemCount: sections.length,
                  itemBuilder: (context, sectionIndex) {
                    final sectionTitle = sections.keys.elementAt(sectionIndex);
                    final items = (sections[sectionTitle]?["data"] as List?) ?? [];
                    final String? newSectionTitle = sections[sectionTitle]?["title"];

                    // Skip this section if the title is null or empty
                    if (newSectionTitle == null || newSectionTitle.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              newSectionTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index] ?? {};

                                final String id = item["id"]?.toString() ?? "";
                                final String type = item["type"]?.toString() ?? "";
                                final List? downloads = item["download_url"] as List?;
                                final String url = (downloads != null &&
                                        downloads.isNotEmpty &&
                                        downloads.last is Map &&
                                        downloads.last["link"] != null)
                                    ? downloads.last["link"].toString()
                                    : "";

                                final List<dynamic> artists =
                                    item["artist_map"]?["artists"] ?? [];
                                final String artist = (artists.isNotEmpty)
                                    ? artists.first["name"]
                                    : "";

                                String imageUrl = "";
                                final imageField = item["image"];
                                if (imageField is String) {
                                  imageUrl = imageField;
                                } else if (imageField is List && imageField.isNotEmpty) {
                                  final lastImage = imageField.last;
                                  if (lastImage is Map && lastImage.containsKey("link")) {
                                    imageUrl = lastImage["link"].toString();
                                  }
                                }

                                final title = item["name"]?.toString() ?? "No Title";

                                return GestureDetector(
                                  onTap: () {
                                    if (type == "song") {
                                      audioProvider.play(url, title, imageUrl, artist);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AudioPlayerScreen(
                                            url: url,
                                            title: title,
                                            imageUrl: imageUrl,
                                            artist: artist,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Album(albumId: id, type: type),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            imageUrl,
                                            height: 140,
                                            width: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              height: 140,
                                              width: 140,
                                              color: Colors.grey[900],
                                              child: const Icon(Icons.music_note,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Mini Player
          if (audioProvider.currentUrl != null)
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                leading: audioProvider.currentImage != null
                    ? Image.network(audioProvider.currentImage!,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.music_note),
                title: Text(audioProvider.currentTitle ?? ''),
                subtitle: Text(audioProvider.currentArtist ?? ''),
                trailing: IconButton(
                  icon: Icon(audioProvider.player.playing
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () {
                    if (audioProvider.player.playing) {
                      audioProvider.pause();
                    } else {
                      audioProvider.resume();
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AudioPlayerScreen(
                        url: audioProvider.currentUrl ?? "",
                        title: audioProvider.currentTitle ?? "",
                        imageUrl: audioProvider.currentImage ?? "",
                        artist: audioProvider.currentArtist ?? "",
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
