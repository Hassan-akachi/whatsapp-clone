import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/widgets/custom_error.dart';
import 'package:whatsapp_ui/features/auth/screen/login_screen.dart';
import 'package:whatsapp_ui/features/auth/screen/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screen/user_information_screen.dart';
import 'package:whatsapp_ui/features/select_contacts/screens/select_contact_screen.dart';
import 'package:whatsapp_ui/model/user_model.dart';
import 'package:whatsapp_ui/features/chat/screen/mobile_chat_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const LoginScreen());

    case OTPScreen.routeName:
      final verificationId = routeSettings.arguments as String;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => OTPScreen(
                verificationId: verificationId,
              ));

    case UserInformationScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const UserInformationScreen());

    case SelectContactScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const SelectContactScreen());
    // case CCConversionScreen.routeName:
    //   var index = routeSettings.arguments as int;
    //   return PageRouteBuilder(
    //     settings: routeSettings,
    //     transitionDuration: const Duration(milliseconds: 500),
    //     reverseTransitionDuration: const Duration(milliseconds: 200),
    //     pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
    //       opacity: animation,
    //       child: CCConversionScreen(start: index),
    //     ),
    //   );

    case MobileChatScreen.routeName:
      final arguments = routeSettings.arguments as Map<String,dynamic>;
      final String name=arguments['name'];
      final String uid =arguments['uid'];
      return PageRouteBuilder(
        settings: routeSettings,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: MobileChatScreen(name: name,uid: uid,),
        ),
      );

    default:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const CustomError(
                text: 'Screen does not exist!',
              ));
  }
}
