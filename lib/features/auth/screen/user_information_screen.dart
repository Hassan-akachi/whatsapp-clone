import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/util/constants.dart';
import 'package:whatsapp_ui/common/util/custom_snackbar.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = "/user-info-screen";

  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  TextEditingController nameController = TextEditingController();
  File? image;

  void pickedImage(BuildContext context) async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserDataToFirebase(context, name, image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                image == null
                    // ? const Icon(
                    //     Icons.account_circle,
                    //     size: 100,
                    //   )
                    ? const CircleAvatar(
                        backgroundImage:
                            NetworkImage(defaultBackgroundImageUrl),
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
                          pickedImage(context);
                        },
                        icon: const Icon(
                          Icons.add_a_photo_outlined,
                        )))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.all(15),
                    child: TextField(
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter your username",
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: storeUserData,
                  icon: const Icon(
                    Icons.check,
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }
}
