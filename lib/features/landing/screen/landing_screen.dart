import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'package:whatsapp_ui/features/auth/screen/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  "Welcome to WhatzApp",
                  style: TextStyle(fontSize: 33, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: size.height / 9,
                ),
                Image.asset(
                  "assets/bg.png",
                  height: 340,
                  width: 340,
                  color: tabColor,
                ),
                SizedBox(
                  height: size.height / 9,
                ),
                const Text(
                  "Read our private Policy.Tap \" Agree and Continue \" \nTo accept terms of services",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(width: size.width*.8,
                  child: CustomButton(
                      text: "Agree and Continue",
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
