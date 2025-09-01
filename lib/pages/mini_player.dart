// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'audio_player_provider.dart';
// import 'AudioPlayer.dart';

// class MiniPlayer extends StatelessWidget {
//   const MiniPlayer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final audioProvider = context.watch<AudioPlayerProvider>();

//     if (audioProvider.url == null) return const SizedBox(); // Hide if nothing playing

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => AudioPlayerScreen(),
//           ),
//         );
//       },
//       child: Container(
//         height: 70,
//         color: Theme.of(context).colorScheme.surfaceVariant,
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 audioProvider.imageUrl ?? "",
//                 height: 50,
//                 width: 50,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(
//                   height: 50,
//                   width: 50,
//                   color: Colors.grey[900],
//                   child: const Icon(Icons.music_note, color: Colors.white),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 audioProvider.title ?? "",
//                 style: const TextStyle(fontSize: 16),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             IconButton(
//               icon: Icon(
//                 audioProvider.player.playing ? Icons.pause : Icons.play_arrow,
//               ),
//               onPressed: audioProvider.togglePlayPause,
//             ),
//             IconButton(
//               icon: Icon(
//                 audioProvider.player.playing ? Icons.pause : Icons.play_arrow,
//               ),
//               onPressed: audioProvider.togglePlayPause,
//             ),
//             IconButton(
//               icon: Icon(
//                 audioProvider.player.playing ? Icons.pause : Icons.play_arrow,
//               ),
//               onPressed: audioProvider.togglePlayPause,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
