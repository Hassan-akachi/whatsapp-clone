import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/common/enums/message_enums.dart';
import 'package:whatsapp_ui/common/provider/message_reply_provider.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/my_message_card.dart';
import 'package:whatsapp_ui/features/chat/widgets/sender_message_card.dart';

import '../../../common/widgets/CustomLoader.dart';
import '../../../model/message.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;

  const ChatList({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();
  int previousMessageCount = 0;

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    //update the replied data(username,message,message type
    ref
        .read(messageReplyProvider.notifier)
        .update((state) => // if state stops working use notifier
            MessageReply(message, isMe, messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream:widget.isGroupChat ? ref.read(chatControllerProvider).groupChatStream(widget.receiverUserId)
         : ref.read(chatControllerProvider).chatStream(widget.receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoader();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          // Only jump if there are new messages
          if (snapshot.data!.length > previousMessageCount) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);
            if(!messageData.isSeen && messageData.recieverid == FirebaseAuth.instance.currentUser!.uid){
              ref.read(chatControllerProvider).setChatMessageSeen(context, widget.receiverUserId, messageData.messageId);
            }
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                messageType: messageData.type,
                onLeftSwipe: () =>
                    onMessageSwipe(messageData.text, true, messageData.type),
                username: messageData.repliedTo,
                repliedText: messageData.repliedMessage,
                repliedMessageType: messageData.repliedMessageType,
                isSeen : messageData.isSeen
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              messageType: messageData.type,
              onRightSwipe: () {
                return onMessageSwipe(
                    messageData.text, false, messageData.type);
              },
              username: messageData.repliedTo,
              repliedText: messageData.repliedMessage,
              repliedMessageType: messageData.repliedMessageType,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }
}
