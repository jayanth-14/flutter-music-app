import 'package:flutter/material.dart';

class AlbumCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String type;
  final String artist;
  const AlbumCard({super.key, required this.name, required this.type, required this.artist, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Image.network(imageUrl, width: 150, height: 150),
          Text(name, style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis
          ),),
          Row(  
            children: [
              Text(type),
              VerticalDivider(),
              Text(artist)
            ],
          )
        ],
      ),
    );
  }
}