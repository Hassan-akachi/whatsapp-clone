import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commonFirebaseStorageRepositoryProvider = Provider((ref) =>
    CommonFirebaseStorageRepository(firebaseStorage: FirebaseStorage.instance));

class CommonFirebaseStorageRepository {
  final FirebaseStorage firebaseStorage;

  CommonFirebaseStorageRepository({required this.firebaseStorage});

  Future<String> storeFileToFirebase(String ref, File file) async {// upload and download imageurl from firebase
    UploadTask uploadTask = firebaseStorage
        .ref()
        .child(ref)
        .putFile(file); //upload to location in firebase
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
