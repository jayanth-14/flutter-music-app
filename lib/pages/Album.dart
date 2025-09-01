import 'dart:developer' as d;
import 'package:flutter/material.dart';
import 'package:gaana/api/albumApi.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:gaana/pages/AudioPlayer.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key, required this.albumId, required this.type});

  final String albumId;
  final String type;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late Future<ContentData> _contentDataFuture;
  final AudioHandler _audioHandler = GetIt.instance<AudioHandler>();

  @override
  void initState() {
    super.initState();
    d.log(
      'Fetching content for type: ${widget.type} and id: ${widget.albumId}',
    );
    _contentDataFuture = fetchContent(id: widget.albumId, type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<ContentData>(
        future: _contentDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final content = snapshot.data!;
          final songs = content.songs;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                automaticallyImplyLeading: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: content.imageLink.isNotEmpty
                      ? Image.network(content.imageLink, fit: BoxFit.cover)
                      : Container(color: Colors.grey),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.artist,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Songs',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  ...songs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final song = entry.value;

                    return ListTile(
                      leading: Image.network(
                        song['image'].last['link'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) =>
                            const Icon(Icons.music_note, size: 50),
                      ),
                      title: Text(song['name'] ?? 'Unknown Song'),
                      subtitle: Text(
                        (song['artist_map']['primary_artists'] as List)
                                .isNotEmpty
                            ? song['artist_map']['primary_artists'][0]['name']
                            : 'Various Artists',
                      ),
                      onTap: () async {
                        // Always call addTracks with playlistId (handler will decide whether to reload)
                        await (_audioHandler as dynamic).addTracks(
                          songs,
                          playlistId: widget.albumId,
                        );

                        // Jump to the tapped index
                        await _audioHandler.skipToQueueItem(index);
                        await _audioHandler.play();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AudioPlayerScreen(index: index),
                          ),
                        );
                      },
                    );
                  }),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
