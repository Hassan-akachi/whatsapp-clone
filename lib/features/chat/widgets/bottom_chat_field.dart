import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enums.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';

import '../../../colors.dart';
import '../../../common/util/utils.dart';

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
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, _messageController.text.trim(), widget.receiverUserId);
      setState(() {
        _messageController.text = "";
      });
    }
  }

  void selectFileMessage(File file, MessageEnum messageEnum) {
    // get the file to send e.g image,video,audio e.t.c
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.receiverUserId, messageEnum);
  }

  void selectImage() async {
    //get image from gallery
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      selectFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    //get image from gallery
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      selectFileMessage(video, MessageEnum.video);
    }
  }

  void toggleEmojiContainer() {
    setState(() {
      isShowEmojiContainer = !isShowEmojiContainer;
    });
  }

  void toggleKeyboard() {
    isShowEmojiContainer ? focusNode.requestFocus() : focusNode.unfocus();
  }

  void toggleEmojiKeyboardContainer() {
    toggleKeyboard();
    toggleEmojiContainer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
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
                            onPressed: toggleEmojiKeyboardContainer,
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
                          onPressed: selectImage,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                          onPressed: selectVideo,
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
                onTap: toggleEmojiKeyboardContainer,
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
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  //emoji picker
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text += emoji.emoji;
                    });
                    if(!isShowSendButton){
                      setState(() {
                        isShowSendButton =true;
                      });
                    }
                  },
                ),
              )
            : const SizedBox()
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }
}
