import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/widgets/my_message_card.dart';
import 'package:whatsapp_ui/widgets/sender_message_card.dart';

import '../../../common/widgets/CustomLoader.dart';
import '../../../model/message.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;

  const ChatList({
    Key? key,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream:
            ref.read(chatControllerProvider).chatStream(widget.receiverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoader();
          }
          SchedulerBinding.instance.addPostFrameCallback((_){
            //this method let it scrollup to the max level i.e show the last message
            messageController.jumpTo(messageController.position.maxScrollExtent);
          });
          return ListView.builder(
            controller: messageController  ,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messagesData = snapshot.data![index];
              var timeSent = DateFormat.Hm().format(messagesData.timeSent);
              if (messagesData.senderId ==
                  FirebaseAuth.instance.currentUser!.uid) { //for my message
                return MyMessageCard(
                  message: messagesData.text,
                  date: timeSent,
                );
              }
              return SenderMessageCard(
                message: messagesData.text,
                date: timeSent,
              );
            },
          );
        });
  }
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
