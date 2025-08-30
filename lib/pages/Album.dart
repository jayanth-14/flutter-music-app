import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Album extends StatefulWidget {
  const Album({super.key, required this.albumId, required this.type});

  final String albumId;
  final String type;

  @override
  State<Album> createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  List<Map<String, dynamic>> albumImage = [];
  List<Map<String, dynamic>> songs = [];
  String albumName = "";
  String artist = "";
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAlbum();
  }

  Future<void> fetchAlbum() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://rhythm-api.vercel.app/${widget.type}?id=${widget.albumId}",
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData != null && jsonData['data'] != null) {
          setState(() {
            albumImage = jsonData['data']['image'] ?? [];
            artist = jsonData['data']['artist'] ?? 'Unknown Artist';
            albumImage =
                (jsonData['data']['image'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [];

            songs =
                (jsonData['data']['songs'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [];

            isLoading = false;
          });
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Failed to load album: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      // print(songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Album")),
        body: Center(
          child: Text("Error: $errorMessage \n with id ${widget.albumId}"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(albumName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          albumImage.isNotEmpty
              ? Image.network(
                  albumImage.last["link"] ?? "",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note, size: 50),
                ),
          const SizedBox(height: 20),
          Text(
            albumName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(artist, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
