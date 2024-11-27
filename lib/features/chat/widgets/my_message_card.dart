import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/features/chat/widgets/display_text_files.dart';

import '../../../common/enums/message_enums.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum messageType;
  final VoidCallback onLeftSwipe;
  final String username;
  final String repliedText;
  final MessageEnum repliedMessageType;
  final bool isSeen;

  const MyMessageCard(
      {Key? key,
      required this.message,
      required this.date,
      required this.messageType,
      required this.onLeftSwipe,
      required this.username,
      required this.repliedText,
      required this.repliedMessageType,
      required this.isSeen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying =
        repliedText.isNotEmpty; // check if the the message is replying

    return SwipeTo(
      onLeftSwipe: (details) {
        onLeftSwipe();
        print("swipe ${isReplying}");
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageColor,
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
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                       Icon(
                        isSeen ? Icons.done_all :Icons.done,
                        size: 20,
                        color: isSeen ? Colors.blue : Colors.white60,
                      ),
                    ],
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
