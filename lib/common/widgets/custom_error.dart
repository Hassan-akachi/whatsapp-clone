import 'package:flutter/material.dart';


class CustomError extends StatelessWidget {
  final String text ;
  const CustomError({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text(text),
      ),
    );
  }
}
