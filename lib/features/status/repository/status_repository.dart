import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/repository/common_firebase_storage_repository.dart';
import '../../../common/util/utils.dart';
import '../../../model/status.dart';
import '../../../model/user_model.dart';


final statusRepositoryProvider = Provider(
      (ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Ref ref;
  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      // Generate unique status ID
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;

      // Upload status image to Firebase storage
      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('/status/$statusId$uid', statusImage);

      // Fetch user contacts if permission granted
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      // Identify users who can view the status
      List<String> uidWhoCanSee = [];
      for (var contact in contacts) {
        var userSnapshot = await firestore
            .collection('users')
            .where('phoneNumber',
            isEqualTo: contact.phones.isNotEmpty
                ? contact.phones[0].number.replaceAll(' ', '')
                : '')
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          var user = UserModel.fromMap(userSnapshot.docs[0].data());
          uidWhoCanSee.add(user.uid);
        }
      }

      // Check if user already has statuses
      var existingStatusSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: uid)
          .get();

      List<String> statusImageUrls = [];
      if (existingStatusSnapshot.docs.isNotEmpty) {
        // Update existing status
        var existingStatus = Status.fromMap(existingStatusSnapshot.docs[0].data());
        statusImageUrls = existingStatus.photoUrl;
        statusImageUrls.add(imageUrl);

        await firestore
            .collection('status')
            .doc(existingStatusSnapshot.docs[0].id)
            .update({'photoUrl': statusImageUrls});

        print('Existing status updated successfully.');
        return;
      } else {
        // Create a new status
        statusImageUrls = [imageUrl];
      }

      // Prepare status object
      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      // Save status to Firestore
      await firestore.collection('status').doc(statusId).set(status.toMap());
      print('New status uploaded successfully.');
    } catch (e) {
      // Handle errors and show feedback
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }



  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnapshot = await firestore
            .collection('status')
            .where(
          'phoneNumber',
          isEqualTo: contacts[i].phones[0].number.replaceAll(
            ' ',
            '',
          ),
        )
            .where(
          'createdAt',
          isGreaterThan: DateTime.now()
              .subtract(const Duration(hours: 24))
              .millisecondsSinceEpoch,
        )
            .get();
        for (var tempData in statusesSnapshot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }

}