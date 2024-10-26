import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/enums/message_enums.dart';

class DisplayTextImagesGif extends StatelessWidget {
  final String message;
  final MessageEnum messageType;

  const DisplayTextImagesGif(
      {super.key, required this.message, required this.messageType});

  @override
  Widget build(BuildContext context) {
    return messageType == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16),
          )
        : CachedNetworkImage(imageUrl: message);// this a dependency that help cache the to avoid multiple recall
  }
}
