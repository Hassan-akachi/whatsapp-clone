
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

import 'package:whatsapp_ui/features/status/repository/status_repository.dart';

import '../../../common/util/utils.dart';
import '../../../model/status.dart';


final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);
  return StatusController(
    statusRepository: statusRepository,
    ref: ref,
  );
});

class StatusController {
  final StatusRepository statusRepository;
  final ProviderRef ref;
  StatusController({
    required this.statusRepository,
    required this.ref,
  });

  void addStatus(File file, BuildContext context) {
    ref.watch(userDataAuthProvider).whenData((userData) {
      if (userData != null) {
        statusRepository.uploadStatus(
          username: userData.name,
          profilePic: userData.profilePic,
          phoneNumber: userData.phoneNumber,
          statusImage: file,
          context: context,
        );
      } else {
        if (context.mounted) {
          showSnackBar(context: context, content: 'User data is not available.');
        }
      }
    });
  }


  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statuses = await statusRepository.getStatus(context);
    return statuses;
  }
}
