import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/select_contacts/repository/select_contact_repository.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactsController = ref.watch(selectContactRepositoryProvider);
  return selectContactsController.getUserContacts();
});
final selectContactControllerProvider = Provider((ref) {
  final selectContactRepo = ref.watch(selectContactRepositoryProvider);
  return SelectContactController(
      selectContactRepository: selectContactRepo, ref: ref);
});

class SelectContactController {
  final SelectContactRepository selectContactRepository;
  final ProviderRef ref;

  SelectContactController(
      {required this.selectContactRepository, required this.ref});

  void selectedContact(BuildContext context, Contact selectedContact) {
    selectContactRepository.selectContact(context, selectedContact);
  }
}
