import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/util/custom_snackbar.dart';

class UserInformationScreen extends StatefulWidget {
  static const String routeName = "/user-info-screen";

  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  TextEditingController nameController = TextEditingController();
  File? image;

  void pickedImage(BuildContext context) async {
    image = await pickImageFromGallery(context);
    setState(() {});
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
                    ? const Icon(
                        Icons.account_circle,
                        size: 100,
                      )
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
                  onPressed: () {},
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
