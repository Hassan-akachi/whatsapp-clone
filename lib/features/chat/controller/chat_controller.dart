import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enums.dart';
import 'package:whatsapp_ui/common/provider/message_reply_provider.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/group.dart';

import '../../../model/message.dart';
import '../repository/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  //sends the message
  void sendTextMessage(
    BuildContext context,
    String text,
    String recieverUserId,
      bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendTextMessage(
            context: context,
            text: text,
            recieverUserId: recieverUserId,
            senderUser: value!,
            messageReply: messageReply,
        isGroupChat: isGroupChat));
    ref.read(messageReplyProvider.notifier).update((state) => null);//this make the reply provide empty or null after sending data
  }

  //sends file to the database
  void sendFileMessage(BuildContext context,
      File file,
      String recieverUserId,
      MessageEnum messageEnum
      ,bool isGroupChat,) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendFileMessage(
            context: context,
            file: file,
            recieverUserId: recieverUserId,
            senderUserData: value!,
            messageEnum: messageEnum,
            ref: ref,
            messageReply: messageReply,
        isGroupChat: isGroupChat));
    ref.read(messageReplyProvider.notifier).update((state) => null);//this make the reply provide empty or null after sending data
  }

  //gets the  chat list for the contacts
  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  //gets the  chat list for the contacts
  Stream<List<GroupModel>> chatGroups() {
    return chatRepository.getChatGroups();
  }


  //get the the messages for the chat list
  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }


  Stream<List<Message>> groupChatStream(String groupId) {
    return chatRepository.getGroupChatStream(groupId);
  }

  void setChatMessageSeen(BuildContext context, String receiverUserId,String messageId){
    return chatRepository.setChatMessageSeen(context, receiverUserId, messageId);
  }
}
