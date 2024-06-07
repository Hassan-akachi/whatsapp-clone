import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/features/landing/screen/landing_screen.dart';
import 'package:whatsapp_ui/firebase_options.dart';
import 'package:whatsapp_ui/routes.dart';
import 'package:whatsapp_ui/screens/web_layout_screen.dart';
import 'package:whatsapp_ui/utils/responsive_layout.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(backgroundColor: appBarColor)),
      home: const ResponsiveLayout(
        mobileScreenLayout: LandingScreen(), //MobileLayoutScreen()
        webScreenLayout: WebLayoutScreen(),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
    );
  }
}
