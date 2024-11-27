import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/util/utils.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/group/widgets/select_contact_group.dart';

import '../../../common/util/constants.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group-screen';

  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  TextEditingController groupNameController = TextEditingController();
  File? image;

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
          context,
          groupNameController.text.trim(),
          image!,
          ref.read(selectedGroupContact));
      ref.read(selectedGroupContact.notifier).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                image == null
                    // ? const Icon(
                    //     Icons.account_circle,
                    //     size: 100,
                    //   )
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(defaultBackgroundImageUrl.trim()),
                        radius: 64,
                      )
                    // https://png.pngitem.com/pimgs/s/24-248226_computer-icons-user-profile-clip-art-login-user.png
                    : CircleAvatar(
                        backgroundImage: FileImage(image!),
                        radius: 64,
                      ),
                Positioned(
                    bottom: -10,
                    right: -10,
                    child: IconButton(
                        onPressed: () {
                          selectImage();
                        },
                        icon: const Icon(
                          Icons.add_a_photo_outlined,
                        )))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(hintText: "Enter Group Name"),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Select Contacts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SelectContactGroup()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: createGroup,
          backgroundColor: tabColor,
          child: const Icon(
            Icons.done,
            color: Colors.white,
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }
}
