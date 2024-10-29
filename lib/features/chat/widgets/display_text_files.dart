import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/enums/message_enums.dart';
import 'package:whatsapp_ui/common/widgets/video_player_item.dart';

class DisplayTextImagesGif extends StatelessWidget {
  final String message;
  final MessageEnum messageType;

  const DisplayTextImagesGif(
      {super.key, required this.message, required this.messageType});

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    return messageType == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16),
          )
        : messageType == MessageEnum.image
            ? CachedNetworkImage(
                imageUrl:
                    message) // this a dependency that help cache the to avoid multiple recall
            : messageType == MessageEnum.video
                ? VideoPlayerItem(videoUrl: message)
                : StatefulBuilder(builder: (context, setState) {
                    return IconButton(
                        constraints: const BoxConstraints(minWidth: 120),
                        onPressed: () async {
                          if (isPlaying) {//if audio is playing stop
                            await audioPlayer.pause();
                            setState(() {
                              isPlaying = false;
                            });
                          } else {
                            audioPlayer.play(UrlSource(message));
                            setState(() {
                              isPlaying = true;
                            });
                          }
                        },
                        icon: isPlaying ? const Icon(Icons.play_circle)
                            :const Icon(Icons.stop_circle));
                  });
  }
}
