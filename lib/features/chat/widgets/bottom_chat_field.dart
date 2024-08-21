import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';

import '../../../colors.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;

  const BottomChatField({
    Key? key,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  final TextEditingController _messageController = TextEditingController();
  bool isShowSendButton = false; // toggle btw send and audio rec

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, _messageController.text.trim(), widget.receiverUserId);
      setState(() {
        _messageController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            // focusNode: focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: mobileChatBoxColor,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.emoji_emotions,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.gif,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              suffixIcon: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              hintText: 'Type a message!',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
            controller: _messageController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() {
                  isShowSendButton = true;
                });
              } else {
                setState(() {
                  isShowSendButton = false;
                });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: InkWell(
              child: CircleAvatar(
                  backgroundColor: whatsappGreen,
                  radius: 25,
                  child: GestureDetector(
                    child: Icon(isShowSendButton ? Icons.send : Icons.mic,
                        color: Colors.white),
                    onTap: sendTextMessage,
                  ))),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }
}
