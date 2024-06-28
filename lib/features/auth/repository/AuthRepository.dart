import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/repository/common_firebase_storage_repository.dart';
import 'package:whatsapp_ui/common/util/constants.dart';
import 'package:whatsapp_ui/common/util/custom_snackbar.dart';
import 'package:whatsapp_ui/features/auth/screen/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screen/user_information_screen.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

final authRepositoryProvider = Provider((ref) =>
    AuthRepository(
        auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    // setting phone
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            throw Exception(e.message);
          },
          codeSent: ((String verificationId, int? resendToken) async {
            Navigator.pushNamed(context, OTPScreen.routeName,
                arguments: verificationId);
          }),
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void verifyOtp( //
          {
        required BuildContext context,
        required String verificationId,
        required String userOTP,
      }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: "${e.message}");
    }
  }

  void saveUserDataToFirebase({required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context}) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = defaultBackgroundImageUrl;
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase('profilePic/$uid', profilePic);
      }

      var user = UserModel(name: name,
          uid: uid,
          profilePic: photoUrl,
          isOnline: true,
          phoneNumber: auth.currentUser!.phoneNumber!,
          groupId: []);
      await firestore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MobileLayoutScreen()), (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }



  Future<UserModel?> getUserCurrentData()async{// get the user data for the login user
    var userdata = await firestore.collection('user').doc(auth.currentUser?.uid).get(); //get user data form database
    UserModel? user;
    if(userdata.data() != null){
      user =UserModel.fromMap(userdata.data()!);

    }
    return user;
  }

}
