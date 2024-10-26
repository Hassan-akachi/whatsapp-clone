
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/util/utils.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/features/chat/screen/mobile_chat_screen.dart';

final selectContactRepositoryProvider = Provider((ref) {
  return SelectContactRepository(firebaseStore: FirebaseFirestore.instance);
});

class SelectContactRepository {
  final FirebaseFirestore firebaseStore;

  SelectContactRepository({required this.firebaseStore});

  Future<List<Contact>> getUserContacts() async {
    List<Contact> contacts = [];
    // Request contact permission
    try {
      if (await FlutterContacts.requestPermission()) {
        // Get all contacts (lightly fetched)
        contacts = await FlutterContacts.getContacts();

        // Get all contacts (fully fetched)
        contacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(
      BuildContext context, Contact selectedContact) async {
    try {
      var userCollection = await firebaseStore.collection('users').get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document
            .data()); //the convert the list of snapshots of users  to a map for each user
        String selectedPhoneNUmber =
            selectedContact.phones[0].number.replaceAll(" ", "").toLowerCase(); // get the selected number and replace the space with empty i.e remove empty space
        print( selectedContact.phones[0].number.toLowerCase());
        if (selectedPhoneNUmber == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(context, MobileChatScreen.routeName,arguments: {'name': userData.name,'uid':userData.uid});
        }
      }
      if (!isFound) {
        showSnackBar(
            context: context, content: "contact is not registered in the app ${selectedContact.phones[0].number.toLowerCase()}");
      }
    } catch (e) {

      showSnackBar(context: context, content:  e.toString());

    }
  }
}
