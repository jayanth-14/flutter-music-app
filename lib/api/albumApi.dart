import 'dart:convert';
import 'dart:developer' as d;
import 'package:http/http.dart' as http;
import 'package:gaana/api/api.dart';

abstract class ContentData {
  final String name;
  final String artist;
  final List<Map<String, dynamic>> songs;
  final String imageLink;

  ContentData({
    required this.name,
    required this.artist,
    required this.songs,
    required this.imageLink,
  });
}

class AlbumData extends ContentData {
  AlbumData({
    required super.name,
    required super.artist,
    required super.songs,
    required super.imageLink,
  });

  factory AlbumData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    final albumImage = (data['image'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];

    final songs = (data['songs'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];

    String artistName;
    if (data['artist_map'] != null && data['artist_map']['primary_artists'] != null) {
      final primaryArtists = data['artist_map']['primary_artists'] as List<dynamic>;
      artistName = primaryArtists.isNotEmpty ? primaryArtists.first['name'] as String : 'Unknown Artist';
    } else {
      artistName = 'Unknown Artist';
    }

    return AlbumData(
      name: data['name'] ?? 'Unknown Album',
      artist: artistName,
      songs: songs,
      imageLink: albumImage.isNotEmpty ? albumImage.last["link"] ?? "" : "",
    );
  }
}

class PlaylistData extends ContentData {
  PlaylistData({
    required super.name,
    required super.artist,
    required super.songs,
    required super.imageLink,
  });

  factory PlaylistData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    final songs = (data['songs'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];

    // In the Playlist JSON, the image link is a direct string
    final imageLink = data['image'] as String? ?? "";
    
    // The playlist API response doesn't have a dedicated 'artist' field at the top level
    // so we'll use a descriptive string or leave it blank
    final artists = data['artists'] as List<dynamic>?;
    final artistName = artists != null && artists.isNotEmpty
        ? (artists.first['name'] as String? ?? 'Various Artists')
        : 'Various Artists';

    return PlaylistData(
      name: data['name'] ?? 'Unknown Playlist',
      artist: artistName,
      songs: songs,
      imageLink: imageLink,
    );
  }
}

Future<ContentData> fetchContent({required String id, required String type}) async {
  try {
    final url = '${ApiClient.baseUrl}/$type?id=$id';
    d.log("Url : $url");
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData != null && jsonData['data'] != null) {
        if (type == 'album') {
          return AlbumData.fromJson(jsonData);
        } else if (type == 'playlist') {
          return PlaylistData.fromJson(jsonData);
        } else {
          throw Exception("Unsupported content type: $type");
        }
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception("Failed to load content: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Failed to fetch content data: $e");
  }
}
