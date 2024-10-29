import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

//pick video
Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final ImagePicker videoPicker = ImagePicker();
// Pick an image.
    final pickedVideo = await videoPicker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}
pickGIF(BuildContext context) async {
// watch from 6: to ,to hav understanding of file add
      showSnackBar(context: context, content:"coming soon");

}
