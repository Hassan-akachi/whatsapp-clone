import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/repository/common_firebase_storage_repository.dart';
import 'package:whatsapp_ui/common/util/utils.dart';
import 'package:whatsapp_ui/model/chat_contact.dart';
import 'package:whatsapp_ui/model/message.dart';
import 'package:whatsapp_ui/model/user_model.dart';

import '../../../common/enums/message_enums.dart';
import '../../../common/provider/message_reply_provider.dart';
import '../../../model/group.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class ChatRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ChatRepository({required this.auth, required this.firestore});

  void _saveDataToContactSubCollection(
      //only save data to display on the chat contact list
      UserModel senderUserData,
      UserModel? receivedUserData,
      String text,
      DateTime timeSent,
      String receiverUserId
      ,bool isGroupChat
      ) async {
    if(isGroupChat){
      await firestore.collection('group').doc(receiverUserId).update({ 'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {


    // users -> receiver user id -> chats -> current user id -> set data
    var receiverChatContact = ChatContact(
        name: senderUserData!.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(receiverChatContact.toMap());
    // users -> current user id -> chats -> receiver user id -> set data

    var senderChatContact = ChatContact(
        name: receivedUserData!.name,
        profilePic: receivedUserData.profilePic,
        contactId: receivedUserData.uid,
        timeSent: timeSent,
        lastMessage: text);
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(senderChatContact.toMap());
  }}

  void _saveMessageToMessageSubcollection(
      //this method save the messages for each contact chat list /history
      {
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    // required receiverUsername,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUserName,
    required String? receiverUserName,
        required bool isGroupChat
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverid: receiverUserId,
      messageId: messageId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUserName
              : receiverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if(isGroupChat){
      // groups -> group id -> chat -> message
      await firestore
          .collection('groups')
          .doc(receiverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
        message.toMap(),
      );
    }
    else{
    // users -> sender id -> receiver id -> messages -> message id -> store message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
    // users ->  receiver id -> sender id -> messages -> message id -> store message

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }}

  void sendTextMessage( // send to firebase
      {
        required BuildContext context,
        required String text,
        required String recieverUserId,
        required UserModel senderUser,
        required MessageReply? messageReply,
        required bool isGroupChat,
      }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
        await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactSubCollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        receiverUserName: recieverUserData?.name,
        senderUserName: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  //gets the  chat list
  Stream<List<ChatContact>> getChatContacts() {
    //stream of list of latest chat form firebase
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        /// watch video from 4:39:00-4:50:00
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }
      return contacts;
    });
  }

  //gets the  group list
  Stream<List<GroupModel>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<GroupModel> groups = [];
      for (var document in event.docs) {
        var group = GroupModel.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  //update message screen
  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent',
            descending: false) // Sort by time sent in descending order
        .limit(100) // Retrieve the 100 latest messages
        .snapshots()
        .map((snapshot) {
      List<Message> messages = [];
      for (var document in snapshot.docs) {
        try {
          messages.add(Message.fromMap(document.data()));
        } catch (e) {
          // Handle any parsing errors
          print('Error parsing message: $e');
        }
      }
      return messages;
    });
  }

  Stream<List<Message>> getGroupChatStream(String groudId) {
    return firestore
        .collection('groups')
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

// sending image or file
  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String recieverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required MessageEnum messageEnum,
      required MessageReply? messageReply,
      required bool isGroupChat}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(
              commonFirebaseStorageRepositoryProvider) //send file to the firebase storage
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/${recieverUserId}/$messageId',
              file);

      UserModel? recieverUserData;


      if (!isGroupChat) {
        var userDataMap =
        await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 photo';
          break;
        case MessageEnum.video:
          contactMsg = '📹 video';
          break;
        case MessageEnum.audio:
          contactMsg = '🕪 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = "GIF";
          break;
        default:
          contactMsg = "MISTAKE";
      }
      _saveDataToContactSubCollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        receiverUserName: recieverUserData?.name,
        senderUserName: senderUserData.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
  void setChatMessageSeen(
      BuildContext context, String receiverUserId, String messageId) async {
    try {
      // update the seen feature for the sender, users -> sender id -> receiver id -> messages -> message id -> store message
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
      //update the seen feature for the receiver, users ->  receiver id -> sender id -> messages -> message id -> store message

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
