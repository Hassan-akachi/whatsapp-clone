import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/util/custom_snackbar.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/message.dart';
import 'package:whatsapp_ui/model/user_model.dart';

import '../../../common/enums/message_enums.dart';
import '../../auth/repository/AuthRepository.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));


class ChatRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ChatRepository({required this.auth, required this.firestore});

  void _saveDataToContactSubCollection(
      UserModel senderUserData,
      UserModel receivedUserData,
      String text,
      DateTime timeSent,
      String receiverUserId) async {
    // users -> receiver user id -> chats -> current user id -> set data
    var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);
    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());
    // users -> current user id -> chats -> receiver user id -> set data

    var SenderChatContact = ChatContact(
        name: receivedUserData.name,
        profilePic: receivedUserData.profilePic,
        contactId: receivedUserData.uid,
        timeSent: timeSent,
        lastMessage: text);
    await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(recieverChatContact.toMap());
  }

  void _saveMessageToMessageSubcollection(
      {required String receiverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String username,
      required receiverUsername,
      required MessageEnum messageType}) async {
    final message = Message(
        senderId: auth.currentUser!.uid,
        receiverId: receiverUserId,
        messageId: messageId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        isSeen: false);
    // users -> sender id -> receiver id -> messages -> message id -> store message
    await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection("messages")
        .doc(messageId)
        .set(
          message.toMap(),
        );
    // users ->  receiver id -> sender id -> messages -> message id -> store message

    await firestore
        .collection("users")
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection("messages")
        .doc(messageId)
        .set(
      message.toMap(),
    );
  }



  void sendTextMessage(
      // send to firebase
      {required BuildContext context,
      required String text,
      required String receiverUserId,
      required UserModel senderUser}) async {
    // users -> sender id -> receiver id -> messages -> message id -> store message
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var userDataMap = await firestore
          .collection('users')
          .doc(receiverUserId)
          .get(); // getting receiver data
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      // users -> receiver user id -> chats -> current user id -> set data

      var messageId =
          const Uuid().v1(); //to generate unique id (v1 is based on time)

      _saveDataToContactSubCollection(
          senderUser, receiverUserData, text, timeSent, receiverUserId);

      _saveMessageToMessageSubcollection(
          receiverUserId: receiverUserId,
          text: text,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUser.name,
          receiverUsername: receiverUserData.name,
          messageType: MessageEnum.text);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
