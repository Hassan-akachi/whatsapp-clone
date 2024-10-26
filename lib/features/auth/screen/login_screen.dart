import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/util/utils.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String routeName = "/login-screen";

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController phoneNumbercontroller = TextEditingController();
  Country? country;

  void countryPicker() => showCountryPicker(
        context: context,
        showPhoneCode: true,
        // optional. Shows phone code before the country name.
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
          print("$country yessssss");
        },
      );

  void sendPhone() { //check country and send data to provider
    String phoneNumber = phoneNumbercontroller.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref.read(authControllerProvider).signInWithPhone(context,"+${country!.phoneCode}$phoneNumber" );
    }
    else{
      showSnackBar(context: context, content: "check number");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Enter your phone number"),
          centerTitle: true,
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("WhatzApp wiil need to verify your phone number"),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: countryPicker,
                      child: const Text(
                        "Pick Country",
                        style: TextStyle(fontSize: 20),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      country != null
                          ? Text("+${country!.phoneCode}    ",
                              style: const TextStyle(fontSize: 20))
                          : const SizedBox(),
                      // if(country !=null)Text("+${country!.countryCode}"),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: size.width * .5,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: phoneNumbercontroller,
                          decoration: const InputDecoration(
                            hintText: "phone number",
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                  width: size.width * .3,
                  child: CustomButton(
                      text: "NEXT",
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        sendPhone();
                      }))
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    phoneNumbercontroller.dispose();
  }
}
