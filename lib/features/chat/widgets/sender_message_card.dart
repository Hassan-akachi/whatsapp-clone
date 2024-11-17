import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/message_enums.dart';

import 'display_text_files.dart';

class SenderMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum messageType;
  final VoidCallback onRightSwipe;
  final String username;
  final String repliedText;
  final MessageEnum repliedMessageType;

  const SenderMessageCard(
      {Key? key,
      required this.message,
      required this.date,
      required this.messageType,
      required this.onRightSwipe,
      required this.username,
      required this.repliedText,
      required this.repliedMessageType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying =
        repliedText.isNotEmpty; // check if the the message is replying

    return SwipeTo(
      onRightSwipe: (details){onRightSwipe();},
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: senderMessageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: messageType == MessageEnum.text
                      ? const EdgeInsets.only(
                          left: 10,
                          right: 30,
                          top: 5,
                          bottom: 20,
                        )
                      : const EdgeInsets.only(
                          top: 5, left: 5, right: 5, bottom: 25),
                  child: Column(
                    children: [
                      if (isReplying) ...[ // cascade operator -enable to return multiple widgets
                        Text(
                          username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3,),
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration:  BoxDecoration(
                                color: backgroundColor.withOpacity(0.5),
                                borderRadius: const BorderRadius.all(Radius.circular(5))
                            ),
                            child: DisplayTextImagesGif(
                                message: repliedText,
                                messageType: repliedMessageType)),
                        const SizedBox(height: 8,)
                      ],

                      DisplayTextImagesGif(
                          message: message, messageType: messageType),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 10,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
