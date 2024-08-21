import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/auth/repository/AuthRepository.dart';
import 'package:whatsapp_ui/model/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});
final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserCurrentData();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  });

  Future<UserModel?> getUserCurrentData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    print("Fetched user data: $user");
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void verifyPhoneNumber(
      BuildContext context, String verificationId, String userOTP) {
    authRepository.verifyOtp(
        context: context, verificationId: verificationId, userOTP: userOTP);
  }

  void saveUserDataToFirebase(
      BuildContext context, String name, File? profilePic) {
    authRepository.saveUserDataToFirebase(
        name: name, profilePic: profilePic, ref: ref, context: context);
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }
}
