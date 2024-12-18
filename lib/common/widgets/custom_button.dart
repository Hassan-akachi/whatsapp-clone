import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),style: ElevatedButton.styleFrom(
      backgroundColor: tabColor,
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
    ),);
  }
}
