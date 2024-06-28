import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/CustomLoader.dart';
import 'package:whatsapp_ui/common/widgets/custom_error.dart';
import 'package:whatsapp_ui/features/select_contacts/repository/select_contact_repository.dart';

import '../select_contact_controller.dart';

class SelectContactScreen extends ConsumerWidget {
  static const String routeName = "/select-contact";

  const SelectContactScreen({Key? key}) : super(key: key);

  void selectContact(
      WidgetRef ref, BuildContext context, Contact selectedContact) {
    ref
        .read(selectContactControllerProvider)
        .selectedContact(context, selectedContact);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select contact"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: (ref).watch(getContactsProvider).when(
          data: (contactList) {
            return ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (BuildContext context, int i) {
                  final contact = contactList[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      child: ListTile(
                        title: Text(
                          contact.name.first.toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          contact.name.last.toString(),
                          style: TextStyle(fontSize: 10),
                        ),
                        leading: contact.photo == null
                            ? null
                            : CircleAvatar(
                                backgroundImage: MemoryImage(contact.photo!),
                                // memoryImage get from file
                                radius: 30,
                              ),
                      ),
                      onTap: () {
                        return selectContact(ref, context, contact);
                      },
                    ),
                  );
                });
          },
          error: (error, trace) {
            return CustomError(
              text: error.toString(),
            );
          },
          loading: () => const CustomLoader()),
    );
  }
}
